"""Authenticated LAN service; no paid APIs, query storage, or cloud inference."""
import asyncio
import base64
import binascii
import hmac
import json
import os
from pathlib import Path

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from starlette.concurrency import run_in_threadpool

from engine import LanguageError, LocalEngine

ROOT = Path(__file__).resolve().parent
app = FastAPI(title="Voice2Law local languages", docs_url=None, redoc_url=None, openapi_url=None)
engine = LocalEngine()
gate = asyncio.Semaphore(1)


def pairing_key():
    key = os.environ.get("VOICE2LAW_PAIRING_KEY", "").strip()
    if not key and (ROOT / ".pairing-key").is_file():
        key = (ROOT / ".pairing-key").read_text().strip()
    if len(key) < 16:
        raise HTTPException(503, "Run start.ps1 to create a pairing key.")
    return key


@app.middleware("http")
async def protect(request, call_next):
    # No cookies, wildcard CORS, proxy trust, or unauthenticated health route.
    try:
        expected = pairing_key()
    except HTTPException as exc:
        return JSONResponse({"error": exc.detail}, status_code=exc.status_code)
    supplied = request.headers.get("authorization", "")
    if not hmac.compare_digest(supplied, "Bearer " + expected):
        return JSONResponse({"error": "Pairing key incorrect. Check your PC connection settings."}, status_code=401)
    response = await call_next(request)
    response.headers["Cache-Control"] = "no-store"
    return response


async def body(request):
    data = bytearray()
    async for chunk in request.stream():
        data.extend(chunk)
        if len(data) > 2_700_000:
            raise HTTPException(413, "Recording too large. Maximum duration is 60 seconds.")
    try:
        value = json.loads(data)
        if not isinstance(value, dict):
            raise ValueError()
        return value
    except (ValueError, UnicodeDecodeError):
        raise HTTPException(400, "Invalid JSON request.")


async def infer(fn, *args):
    try:
        await asyncio.wait_for(gate.acquire(), timeout=0.1)
    except TimeoutError:
        raise HTTPException(429, "PC is processing another request. Please try again shortly.")
    try:
        return await run_in_threadpool(fn, *args)
    except LanguageError as exc:
        raise HTTPException(422, str(exc))
    except Exception:
        # Do not return tracebacks or user text to the client/logs.
        raise HTTPException(503, "Local model could not run. Check model installation and available PC memory.")
    finally:
        gate.release()


@app.exception_handler(HTTPException)
async def error_response(request, exc):
    return JSONResponse({"error": str(exc.detail)}, status_code=exc.status_code)


@app.get("/health")
def health():
    return {"service": "voice2law-local", "version": 1, **engine.capabilities()}


@app.post("/translate")
async def translate(request: Request):
    data = await body(request)
    text, source, target = (data.get(k) for k in ("text", "source", "target"))
    if not all(isinstance(v, str) for v in (text, source, target)):
        raise HTTPException(400, "Text, source and target are required.")
    translated = await infer(engine.translate, text, source, target)
    return {"text": translated, "target": target, "machine_translation": True}


@app.post("/transcribe")
async def transcribe(request: Request):
    data = await body(request)
    try:
        audio = base64.b64decode(data.get("audio", ""), validate=True)
    except (binascii.Error, ValueError, TypeError):
        raise HTTPException(400, "Invalid recording data.")
    language = data.get("language")
    if not isinstance(language, str):
        raise HTTPException(400, "Select a recording language.")
    text = await infer(engine.transcribe, audio, language)
    return {"text": text, "language": language}
