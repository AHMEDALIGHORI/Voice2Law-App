import json, re

CORPUS = "assets/data/legal_corpus.json"
TOKEN_STRIP = re.compile(r"[^0-9a-z\u0600-\u06ff\s]")

def tokenise(text):
    t = TOKEN_STRIP.sub(" ", text.lower())
    return [w for w in re.split(r"\s+", t) if w and not (len(w) < 2 and not w.isdigit())]

# Probe: find sections whose heading OR body contains any of these keywords,
# so I map concepts to tokens that REALLY exist in the corpus.
KEYWORDS = [
    "hurt", "grievous", "assault", "cruelty", "dacoity", "extortion",
    "electronic", "cyber", "information", "succession", "inheritance",
    "juvenile", "minor", "guardian", "custody", "imputation", "reputation",
    "fraud", "dishonestly", "deceiving", "abduction", "witness", "evidence",
    "burden", "proof", "dower", "maintenance", "polygamy", "talaq",
    "intoxication", "public", "drunken", "bail", "arrest", "warrant",
]

c = json.load(open(CORPUS, encoding="utf-8"))
hits = {k: [] for k in KEYWORDS}
for cat in c["categories"]:
    if cat.get("kind", "statute") == "qa":
        continue
    name = cat.get("name", "")
    for e in cat.get("entries", []):
        h = (e.get("h", "") or "").lower()
        t = (e.get("t", "") or "").lower()
        blob = h + " " + t
        for k in KEYWORDS:
            if k in blob:
                hits[k].append((name, e.get("s", ""), e.get("h", "")))

for k in KEYWORDS:
    hs = hits[k]
    # show heading-only matches preferentially (cleaner signal)
    head_hits = [(n, s, hh) for (n, s, hh) in hs if k in hh.lower()]
    print(f"\n### '{k}'  (heading hits: {len(head_hits)} / any: {len(hs)})")
    for (n, s, hh) in head_hits[:4]:
        print(f"   [{n} §{s}] {hh}")
