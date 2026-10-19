"""Faithful offline benchmark: keyword engine (current) vs. embedding retriever.

The keyword engine is a 1:1 port of lib/services/statute_corpus.dart search().
The candidate uses paraphrase-multilingual-MiniLM-L12-v2 for semantic match.
Ground truth = known (category, section) pairs, scored with Recall@k and MRR.
"""
import re
import json
from collections import Counter

import numpy as np
from sentence_transformers import SentenceTransformer

CORPUS = "assets/data/legal_corpus.json"
MODEL = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"

TOKEN_SPLIT = re.compile(r"\s+")
TOKEN_STRIP = re.compile(r"[^0-9a-z\u0600-\u06ff\s]")
SINGLE_DIGIT = re.compile(r"^\d$")
SECTION_REF = re.compile(r"(?:section|sec\.?|دفعہ|دفعۃ)\s*([0-9]{1,3}[a-z]?)", re.IGNORECASE)
MAX_SECTION_NUM = 999

URDU_EXPANSION = {
    "طلاق": ["divorce", "talaq"], "خلع": ["khula"], "نکاح": ["marriage", "nikah"],
    "مہر": ["dower", "mehr"], "نفقہ": ["maintenance"], "حضانت": ["custody", "guardian"],
    "وراثت": ["inheritance", "succession"], "وصیت": ["will"], "قتل": ["murder", "culpable homicide"],
    "چوری": ["theft"], "ڈکیتی": ["robbery", "dacoity"], "اغوا": ["kidnapping", "abduction"],
    "جھگڑا": ["assault", "hurt"], "ضمانت": ["bail"], "گرفتاری": ["arrest"], "تھان": ["police", "fir"],
    "ایفآئیآر": ["fir", "police report"], "پولیس": ["police"], "جیل": ["imprisonment"],
    "جرمانہ": ["fine", "punishment"], "سزا": ["punishment"], "گواہ": ["witness", "evidence"],
    "ثبوت": ["evidence", "proof"], "جھوٹ": ["false", "fabrication"], "جائیداد": ["property"],
    "زمین": ["land", "property"], "مکان": ["house", "premises"], "دکان": ["shop", "premises"],
    "کرایہ": ["rent", "tenancy"], "مالک": ["landlord", "owner"], "قرض": ["debt"], "سود": ["interest"],
    "دھوکہ": ["cheating", "fraud"], "خریداری": ["sale", "transfer"], "بیع": ["sale", "transfer"],
    "رجسٹری": ["registration"], "عدالت": ["court"], "مقدمہ": ["case", "suit"], "وکیل": ["advocate"],
    "حق": ["right"], "آئین": ["constitution"], "آزادی": ["liberty", "freedom"], "عورت": ["woman", "women"],
    "بچہ": ["child", "minor"], "حقوق": ["rights"], "صحافت": ["press"], "سائبر": ["cyber", "electronic"],
}


def tokenise(text):
    t = TOKEN_STRIP.sub(" ", text.lower())
    out = []
    for w in TOKEN_SPLIT.split(t):
        if not w:
            continue
        if len(w) < 2 and not SINGLE_DIGIT.match(w):
            continue
        out.append(w)
    return out


def term_freq(text):
    return Counter(tokenise(text))


def load_index():
    c = json.load(open(CORPUS, encoding="utf-8"))
    index = []
    for cat in c["categories"]:
        kind = cat.get("kind", "statute")
        name = cat.get("name", "")
        for e in cat.get("entries", []):
            if kind == "qa":
                q, a = e.get("q", ""), e.get("a", "")
                index.append(dict(cat=name, kind="qa", section="Q&A", heading=q, text=a,
                                  headingFreq=term_freq(q), bodyFreq=term_freq(a),
                                  embed=f"{q} {a[:600]}"))
            else:
                s, h, t = e.get("s", ""), e.get("h", ""), e.get("t", "")
                index.append(dict(cat=name, kind="statute", section=s, heading=h, text=t,
                                  headingFreq=term_freq(f"{h} {s}"), bodyFreq=term_freq(f"{t} {h}"),
                                  embed=f"{s}. {h}. {t[:600]}"))
    return index


def keyword_search(query, index, limit=5):
    q = query.strip().lower()
    if not q or not index:
        return []
    expanded = set()
    for urdu, engs in URDU_EXPANSION.items():
        if urdu in q:
            expanded.update(engs)
    section_ref = None
    for m in SECTION_REF.finditer(query):
        raw = m.group(1).lower()
        clean = re.sub(r"[^0-9]", "", raw)
        n = int(clean) if clean else -1
        if 0 < n <= MAX_SECTION_NUM:
            section_ref = raw
            break
    qtokens = tokenise(q)
    qtokens += list(expanded)
    if not qtokens:
        return []
    joined = " ".join(qtokens)
    scored = []
    for doc in index:
        score = 0.0
        for tok in qtokens:
            ih = doc["headingFreq"].get(tok, 0)
            ib = doc["bodyFreq"].get(tok, 0)
            if ih > 0:
                score += 5.0 * min(max(ih, 1), 3)
            if ib > 0:
                score += 0.9 * min(max(ib, 1), 4)
        if score <= 0:
            continue
        score /= 1 + (len(doc["bodyFreq"]) / 400)
        if joined in doc["heading"].lower():
            score += 4
        if section_ref is not None and doc["section"].lower() == section_ref:
            score += 6
        scored.append((score, doc))
    scored.sort(key=lambda x: -x[0])
    return [d for _, d in scored[:limit]]



# Ground truth: natural phrasing -> expected (category, section). Alternates allowed.
GT = [
    ("punishment for intentionally killing someone", "en", [("Penal Code", "302")]),
    ("someone stole my mobile phone", "en", [("Penal Code", "379"), ("Penal Code", "378")]),
    ("armed robbery at my house", "en", [("Penal Code", "392"), ("Penal Code", "390")]),
    ("how do I get bail for a non-bailable offence", "en", [("Criminal Procedure", "497")]),
    ("when can police arrest without a warrant", "en", [("Criminal Procedure", "54")]),
    ("character assassination and public insult", "en", [("Penal Code", "499")]),
    ("fraud and deception to take my money", "en", [("Penal Code", "420"), ("Penal Code", "415")]),
    ("abducting a minor child", "en", [("Penal Code", "359"), ("Penal Code", "362")]),
    ("wife maintenance after divorce", "en", [("Muslim Family", "9")]),
    ("dower amount fixed at marriage", "en", [("Muslim Family", "10")]),
    ("permission for a second marriage polygamy", "en", [("Muslim Family", "6")]),
    ("who has to prove the case burden of proof", "en", [("Shahadat", "117")]),
    ("gift of immovable property", "en", [("Property", "122")]),
    ("legal definition of a sale", "en", [("Property", "54")]),
    ("qatal ki saza kya hai", "roman", [("Penal Code", "302")]),
    ("meri chori ho gayi kya karun", "roman", [("Penal Code", "379"), ("Penal Code", "378")]),
    ("dakaiti ka masla kya hai", "roman", [("Penal Code", "392"), ("Penal Code", "390")]),
    ("talaq ka tareeqa kya hai", "roman", [("Muslim Family", "7")]),
    ("mehr kitni honi chahiye", "roman", [("Muslim Family", "10")]),
    ("zamanat kaise milti hai", "roman", [("Criminal Procedure", "497"), ("Criminal Procedure", "496")]),
    ("قتل کی سزا کیا ہے", "urdu", [("Penal Code", "302")]),
    ("چوری کا طریقہ", "urdu", [("Penal Code", "379"), ("Penal Code", "378")]),
    ("طلاق کا قانون", "urdu", [("Muslim Family", "7")]),
    ("نفقہ کا حق", "urdu", [("Muslim Family", "9")]),
    ("مہر کیا ہے", "urdu", [("Muslim Family", "10")]),
    ("ضمانت کب مل سکتی ہے", "urdu", [("Criminal Procedure", "497")]),
    ("ڈکیتی", "urdu", [("Penal Code", "392"), ("Penal Code", "390")]),
]


def is_correct(doc, expected):
    if doc["kind"] != "statute":
        return False
    for cat_sub, sec in expected:
        if cat_sub.lower() in doc["cat"].lower() and doc["section"].strip() == sec:
            return True
    return False



def evaluate(name, ranked_fn):
    per_lang = {}
    rr_sum = 0.0
    r1 = r5 = 0
    rows = []
    for query, lang, expected in GT:
        ranked = ranked_fn(query)
        rank = 0
        for i, doc in enumerate(ranked[:10]):
            if is_correct(doc, expected):
                rank = i + 1
                break
        rr = 1.0 / rank if rank else 0.0
        rr_sum += rr
        r1 += 1 if rank == 1 else 0
        r5 += 1 if 0 < rank <= 5 else 0
        st = per_lang.setdefault(lang, dict(n=0, r1=0, r5=0, rr=0.0))
        st["n"] += 1
        st["r1"] += 1 if rank == 1 else 0
        st["r5"] += 1 if 0 < rank <= 5 else 0
        st["rr"] += rr
        top = ranked[0] if ranked else None
        rows.append((lang, query, rank,
                     f"{top['cat'][:18]}/{top['section']}" if top else "-"))
    n = len(GT)
    print(f"\n===== {name} =====")
    print(f"{'lang':6} {'n':>2} {'R@1':>6} {'R@5':>6} {'MRR':>6}")
    for lang in ["en", "roman", "urdu"]:
        s = per_lang.get(lang, dict(n=0, r1=0, r5=0, rr=0.0))
        if s["n"] == 0:
            continue
        print(f"{lang:6} {s['n']:>2} {s['r1']/s['n']:>6.2f} {s['r5']/s['n']:>6.2f} {s['rr']/s['n']:>6.2f}")
    print("-" * 34)
    print(f"{'ALL':6} {n:>2} {r1/n:>6.2f} {r5/n:>6.2f} {rr_sum/n:>6.2f}")
    return dict(r1=r1 / n, r5=r5 / n, mrr=rr_sum / n, rows=rows)


def main():
    print("Loading corpus + building runtime index ...")
    index = load_index()
    n_st = sum(1 for d in index if d["kind"] == "statute")
    n_qa = sum(1 for d in index if d["kind"] == "qa")
    print(f"  {n_st} statute docs, {n_qa} QA docs, {len(index)} total")

    kw = evaluate("BASELINE: keyword engine (current Dart port)",
                  lambda q: keyword_search(q, index, 5))

    print("\nLoading multilingual embedding model (CPU) ...")
    model = SentenceTransformer(MODEL)
    print("Encoding corpus ...")
    embs = model.encode([d["embed"] for d in index], normalize_embeddings=True,
                        show_progress_bar=False, batch_size=64)

    def emb_search(query, limit=5):
        qv = model.encode([query], normalize_embeddings=True)[0]
        sims = embs @ qv
        order = np.argsort(-sims)[:limit]
        return [index[i] for i in order]

    eb = evaluate("CANDIDATE: paraphrase-multilingual-MiniLM embeddings",
                  lambda q: emb_search(q, 5))

    print("\n===== SIDE-BY-SIDE (rank of correct doc; 0 = miss in top10) =====")
    print(f"{'lang':6} {'query':44} {'kw':>3} {'emb':>4}  kw-top1")
    krow = {r[1]: r for r in kw["rows"]}
    erow = {r[1]: r for r in eb["rows"]}
    for query, lang, _ in GT:
        k = krow[query][2]
        e = erow[query][2]
        flag = "  <-- emb wins" if (e and (not k or e < k)) else ""
        print(f"{lang:6} {query[:44]:44} {k:>3} {e:>4}  {krow[query][3]}{flag}")

    print("\n===== VERDICT =====")
    print(f"keyword  R@1={kw['r1']:.2f}  R@5={kw['r5']:.2f}  MRR={kw['mrr']:.2f}")
    print(f"embed    R@1={eb['r1']:.2f}  R@5={eb['r5']:.2f}  MRR={eb['mrr']:.2f}")
    d = eb["mrr"] - kw["mrr"]
    print(f"delta MRR = {d:+.2f}  ({'embedding helps' if d > 0.02 else 'no meaningful gain'})")


if __name__ == "__main__":
    main()

