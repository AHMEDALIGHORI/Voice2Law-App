"""Ground-truth probe: show real corpus heading/body tokens for the sections the
concept map must bridge, and check which candidate user words are ABSENT from the
corpus (so we know which need mapping). Temporary; deleted after use."""
import json
import re

TOKEN_STRIP = re.compile(r"[^0-9a-z\u0600-\u06ff\s]")


def tok(text):
    t = TOKEN_STRIP.sub(" ", text.lower())
    return [w for w in t.split() if len(w) >= 2]


c = json.load(open("assets/data/legal_corpus.json", encoding="utf-8"))

# Flatten: (cat, section, heading, text)
docs = []
for cat in c["categories"]:
    kind = cat.get("kind", "statute")
    name = cat.get("name", "")
    if kind == "qa":
        continue
    for e in cat.get("entries", []):
        docs.append((name, e.get("s", ""), e.get("h", ""), e.get("t", "")))

TARGETS = [
    ("Penal Code", "302"), ("Penal Code", "304"), ("Penal Code", "378"),
    ("Penal Code", "379"), ("Penal Code", "390"), ("Penal Code", "392"),
    ("Penal Code", "415"), ("Penal Code", "420"), ("Penal Code", "499"),
    ("Penal Code", "500"), ("Penal Code", "504"), ("Penal Code", "359"),
    ("Penal Code", "362"), ("Criminal Procedure", "54"), ("Criminal Procedure", "496"),
    ("Criminal Procedure", "497"), ("Shahadat", "117"), ("Property", "54"),
    ("Property", "122"), ("Muslim Family", "6"), ("Muslim Family", "7"),
    ("Muslim Family", "9"), ("Muslim Family", "10"),
]

print("===== TARGET HEADING + BODY TOKENS =====")
for csub, sec in TARGETS:
    for name, s, h, t in docs:
        if csub.lower() in name.lower() and s.strip() == sec:
            print(f"\n[{csub} {sec}] {h}")
            print("   body:", " ".join(tok(t)[:40]))
            break

# Which candidate user-facing words are ABSENT from the whole corpus vocab?
all_tokens = set()
for name, s, h, t in docs:
    all_tokens.update(tok(f"{h} {s} {t}"))

CANDIDATES = [
    # English user words -> do they exist in corpus?
    "murder", "kill", "killed", "homicide", "steal", "stole", "stolen",
    "robbery", "robbed", "burglar", "fraud", "scam", "cheated", "deception",
    "defame", "defamation", "insult", "insulted", "slander", "kidnap",
    "abduction", "maintenance", "dower", "polygamy", "bail", "arrest",
    "proof", "gift", "sale", "assault", "hurt", "custody", "witness",
    # Roman Urdu
    "qatal", "qatl", "khoon", "chori", "chore", "dakaiti", "loot", "talaq",
    "mehr", "zamanat", "nafaqa", "dhoka", "saza", "ki", "kya", "hai", "ka", "meri",
]
print("\n===== CANDIDATE WORD -> IN CORPUS? =====")
for w in CANDIDATES:
    print(f"   {w:12} {'YES' if w in all_tokens else 'no'}")
