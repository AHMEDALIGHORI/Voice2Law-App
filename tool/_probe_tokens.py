# -*- coding: utf-8 -*-
"""Confirm candidate concept tokens actually exist in the corpus, so the Dart
concept map targets real tokens (not guesses). Tokenises exactly like Dart
_tokenise: lowercase, strip non [0-9a-z Urdu], split on ws, drop <2 len."""
import json, re
from pathlib import Path

c = json.load(open('assets/data/legal_corpus.json', encoding='utf-8'))

def toks(t):
    t = t.lower()
    t = re.sub(r"[^0-9a-z\u0600-\u06ff\s]", " ", t)
    out = []
    for w in t.split():
        if len(w) < 2 and not re.match(r'^\d$', w):
            continue
        out.append(w)
    return out

# heading-token set (high-signal) and body-token set, with a sample section per token
head = {}
body = {}
for cat in c['categories']:
    if cat.get('kind') != 'statute':
        continue
    for e in cat.get('entries', []):
        s, h, txt = e.get('s',''), e.get('h',''), e.get('t','')
        for tk in set(toks(f"{h} {s}")):
            head.setdefault(tk, f"{cat['name']} {s}")
        for tk in set(toks(f"{txt} {h}")):
            body.setdefault(tk, f"{cat['name']} {s}")

# candidate corpus target tokens for each concept (what we HOPE exists)
targets = {
  'murder': ['qatl','amd','murder','homicide','khoon','intentionally','death'],
  'theft': ['theft','stolen','steals','stole','dishonestly'],
  'robbery': ['robbery','dacoity','dakaiti','daka'],
  'cheating/fraud': ['cheating','fraud','forgery','forged','cheat','dishonestly'],
  'defamation': ['defamation','defame','reputation','slander'],
  'kidnap': ['kidnapping','abduction','abducts','kidnap'],
  'assault/hurt': ['hurt','assault','grievous','beaten','battery','criminal-force','force'],
  'cruelty': ['cruelty','cruel','domestic','harassment'],
  'rape': ['rape','assault','modesty','outraging'],
  'bail': ['bail','bailable','offence'],
  'fir': ['fir','information','police','cognizable','arrest'],
  'cyber': ['cyber','electronic','information','computer','data'],
  'inheritance': ['inheritance','succession','share','shares','heirs'],
  'maintenance': ['maintenance','nafaqa','wife','dower'],
  'juvenile': ['juvenile','child','minor','minority'],
  'traffic': ['driving','vehicle','rash','negligent','traffic'],
  'bribery': ['bribery','corruption','gratification','undue'],
  'trespass': ['trespass','house-trespass','property','entry'],
  'intimidation': ['criminal-intimidation','threat','insult','annoy'],
}

print("=== TOKEN EXISTENCE (heading / body) ===")
for concept, cands in targets.items():
    print(f"\n[{concept}]")
    for w in cands:
        h = head.get(w)
        b = body.get(w)
        where = []
        if h: where.append(f"HEAD@{h}")
        if b: where.append(f"body@{b}")
        status = "OK " if (h or b) else "MISS"
        print(f"  {status} {w:18} {' | '.join(where) if where else '--'}")

# Confirm remaining concept tokens
