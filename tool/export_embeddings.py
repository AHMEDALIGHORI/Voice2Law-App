"""Export the benchmark's MiniLM embedding model to ONNX and validate it.

Why a manual export instead of `optimum`?
  - `optimum` is not installed here, and its export API shifts across versions.
  - More importantly, SentenceTransformer.encode() does MEAN POOLING over the
    token embeddings + L2 NORMALISATION. We bake exactly that into the ONNX
    graph so the on-device output matches encode() to within float tolerance.

We validate by comparing ONNX output to SentenceTransformer.encode() on the
same sentences: max abs diff must be tiny and cosine similarity ~1.0. If this
passes, the on-device path is provably faithful.
"""
from __future__ import annotations

import json
from pathlib import Path

import numpy as np
import torch
from torch import nn
from sentence_transformers import SentenceTransformer

ROOT = Path(__file__).resolve().parent.parent
MODEL_NAME = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
OUT_ONNX = ROOT / "assets" / "ml" / "legal_minilm.onnx"


class MiniLMEmbedder(nn.Module):
    """Transformer + mean-pool (attention-masked) + L2 normalise."""

    def __init__(self, st: SentenceTransformer) -> None:
        super().__init__()
        # First module of a sentence-transformers pipeline is the transformer.
        self.transformer = st._first_module()
        self.auto = self.transformer.auto_model

    def forward(self, input_ids, attention_mask, token_type_ids):
        out = self.auto(
            input_ids=input_ids,
            attention_mask=attention_mask,
            token_type_ids=token_type_ids,
        )
        tok = out.last_hidden_state  # [B, T, H]
        mask = attention_mask.unsqueeze(-1).to(tok.dtype)  # [B, T, 1]
        summed = (tok * mask).sum(dim=1)
        counts = mask.sum(dim=1).clamp(min=1e-9)
        mean = summed / counts
        return torch.nn.functional.normalize(mean, p=2, dim=1)


def main() -> None:
    OUT_ONNX.parent.mkdir(parents=True, exist_ok=True)
    st = SentenceTransformer(MODEL_NAME)
    st.eval()

    model = MiniLMEmbedder(st).eval()

    sample = [
        "What is the punishment for murder in Pakistan?",
        "meri chori ho gayi mobile phone",
        "طلاق کا طریقہ کیا ہے؟",
        "defamation law",
    ]
    # Reference vectors from the official encode().
    ref = st.encode(sample, convert_to_numpy=True, normalize_embeddings=True)

    tok = st.tokenize(sample)
    input_ids = tok["input_ids"]
    attention_mask = tok["attention_mask"]
    token_type_ids = tok.get(
        "token_type_ids",
        torch.zeros_like(input_ids),
    )

    with torch.no_grad():
        onnx_ref = model(input_ids, attention_mask, token_type_ids).cpu().numpy()

    print("dim:", ref.shape[1])

    dummy = (
        input_ids[:1],
        attention_mask[:1],
        token_type_ids[:1],
    )
    torch.onnx.export(
        model,
        dummy,
        str(OUT_ONNX),
        input_names=["input_ids", "attention_mask", "token_type_ids"],
        output_names=["embeddings"],
        dynamic_axes={
            "input_ids": {0: "batch", 1: "seq"},
            "attention_mask": {0: "batch", 1: "seq"},
            "token_type_ids": {0: "batch", 1: "seq"},
            "embeddings": {0: "batch"},
        },
        opset_version=14,
        do_constant_folding=True,
        dynamo=False,  # legacy TorchScript exporter: ORT-friendly, embeds weights
    )
    size_mb = OUT_ONNX.stat().st_size / (1024 * 1024)
    print(f"exported fp32: {OUT_ONNX} ({size_mb:.1f} MB)")
    if size_mb < 20:
        raise SystemExit(
            f"Export is only {size_mb:.1f} MB -- weights were not embedded. "
            "Expected hundreds of MB fp32 (quantisation comes later)."
        )

    # ---- int8 dynamic quantisation. fp32 MiniLM is ~450 MB (dominated by the
    # 250k multilingual embedding table). Dynamic int8 lands ~110-130 MB, the
    # floor for this vocab size. We quantise the ops that carry the mass. ----
    from onnxruntime.quantization import quantize_dynamic, QuantType

    OUT_Q = ROOT / "assets" / "ml" / "legal_minilm.int8.onnx"
    quantize_dynamic(
        model_input=str(OUT_ONNX),
        model_output=str(OUT_Q),
        weight_type=QuantType.QInt8,
        op_types_to_quantize=[
            "MatMul",
            "Gather",
            "Attention",
            "EmbedLayerNormalization",
        ],
    )
    q_mb = OUT_Q.stat().st_size / (1024 * 1024)
    print(f"quantised int8: {OUT_Q} ({q_mb:.1f} MB)")
    OUT_ONNX.unlink()  # fp32 is now just an intermediate; keep the repo lean.

    # Validate the QUANTISED model -- this is the artifact that actually ships.
    import onnxruntime as ort

    sess = ort.InferenceSession(str(OUT_Q), providers=["CPUExecutionProvider"])
    feeds = {
        "input_ids": input_ids.cpu().numpy().astype(np.int64),
        "attention_mask": attention_mask.cpu().numpy().astype(np.int64),
        "token_type_ids": token_type_ids.cpu().numpy().astype(np.int64),
    }
    onnx_out = sess.run(["embeddings"], feeds)[0]

    diff = np.abs(onnx_out - onnx_ref).max()
    cos = (onnx_out * ref).sum(axis=1)
    print("max|onnx - torch_wrapper| =", float(diff))
    print("cosine(onnx, encode) =", [round(float(c), 6) for c in cos])
    ok = diff < 1e-3 and cos.min() > 0.999
    print("EXPORT VALID:", ok)
    if not ok:
        raise SystemExit("ONNX export does not match SentenceTransformer.encode()")


if __name__ == "__main__":
    main()
