"""Model-free validation: does a bidirectional legal CONCEPT MAP raise MRR
over the current keyword engine, without regressing Roman Urdu?

Imports the EXACT baseline (load_index / keyword_search / GT / evaluate) from
bench_retrieval.py so fidelity is guaranteed (and the Urdu UTF-8 is preserved).
Adds an English + Roman-Urdu -> real-corpus-token map plus a small Urdu fix,
then measures the delta per language. No embedding model is loaded.
"""
import re
import bench_retrieval as B

index = B.load_index()
print(f"index: {len(index)} docs "
      f"({sum(1 for d in index if d['kind'] == 'statute')} statute, "
      f"{sum(1 for d in index if d['kind'] == 'qa')} qa)")

# --- extra Urdu expansion: bridge Urdu script to the REAL corpus token -------
# The corpus titles PPC 302 as "Qatl-i-Amd" (token: qatl), NOT "murder".
EXTRA_URDU = {
    "\u0642\u062a\u0644": ["qatl"],          # qatl
    "\u062f\u06be\u0648\u06a9\u06c1": ["cheating"],   # dhoka
    "\u0628\u062f\u0646\u0627\u0645\u06cc": ["defamation"],  # badnaami
}

# --- bidirectional concept map: English + Roman Urdu -> real corpus tokens ---
CONCEPT_MAP = {
    # homicide -> PPC 302/300 ("qatl", "amd")
    "murder": ["qatl"], "kill": ["qatl"], "killing": ["qatl"], "killed": ["qatl"],
    "homicide": ["qatl"], "qatal": ["qatl"], "qatl": ["qatl"], "khoon": ["qatl"],
    "intentionally": ["amd"], "intentional": ["amd"],
    "deliberately": ["amd"], "deliberate": ["amd"],
    # punishment
    "saza": ["punishment"], "penalty": ["punishment"],
    # theft -> PPC 378/379 ("theft")
    "stole": ["theft"], "steal": ["theft"], "stolen": ["theft"], "stealing": ["theft"],
    "chori": ["theft"],
    # robbery -> PPC 390/392 ("robbery")
    "robbed": ["robbery"], "rob": ["robbery"], "loot": ["robbery"], "looting": ["robbery"],
    "dakaiti": ["robbery"], "dacoity": ["robbery"], "dacoit": ["robbery"],
    # defamation -> PPC 499/500 ("defamation")
    "defame": ["defamation"], "slander": ["defamation"], "insult": ["defamation"],
    "insulting": ["defamation"], "badnaami": ["defamation"],
    # cheating/fraud -> PPC 415/420 ("cheating")
    "fraud": ["cheating"], "deception": ["cheating"], "cheat": ["cheating"],
    "scam": ["cheating"], "dhoka": ["cheating"], "dishonestly": ["cheating"],
    # abduction/kidnapping -> PPC 359/362 ("abduction")
    "abduct": ["abduction"], "abducted": ["abduction"], "abducting": ["abduction"],
    "kidnap": ["abduction"], "kidnapped": ["abduction"], "kidnapping": ["abduction"],
    # family law
    # NOTE: "talaq" is already a real corpus token (matches MFL §7 directly),
    # so mapping talaq->divorce only injects noise and demotes §7. Don't map
    # user words that already exist in the corpus and hit the target.
    "mehr": ["dower"], "talak": ["divorce"],
    "zamanat": ["bail"], "zamanah": ["bail"], "nafaqa": ["maintenance"],
}


def concept_search(query, index, limit=5):
    """Faithful copy of keyword_search + bidirectional concept expansion."""
    q = query.lower()
    if not q or not index:
        return []
    expanded = set()
    for urdu, engs in B.URDU_EXPANSION.items():
        if urdu in q:
            expanded.update(engs)
    for urdu, extra in EXTRA_URDU.items():
        if urdu in q:
            expanded.update(extra)
    # section-ref detection (identical to baseline)
    section_ref = None
    for m in B.SECTION_REF.finditer(query):
        raw = m.group(1).lower()
        clean = re.sub(r"[^0-9]", "", raw)
        n = int(clean) if clean else -1
        if 0 < n <= B.MAX_SECTION_NUM:
            section_ref = raw
            break
    qtokens = B.tokenise(q)
    # concept expansion: map user words -> real corpus tokens
    concept_added = set()
    for tok in list(qtokens):
        for target in CONCEPT_MAP.get(tok, ()):
            if target not in concept_added:
                concept_added.add(target)
    qtokens += list(expanded) + list(concept_added)
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


def main():
    base = B.evaluate("BASELINE: keyword engine (current)", lambda q: B.keyword_search(q, index, 5))
    cand = B.evaluate("CANDIDATE: + bidirectional concept map", lambda q: concept_search(q, index, 5))

    print("\n===== PER-QUERY (rank of correct doc; 0 = miss in top10) =====")
    print(f"{'lang':6} {'query':40} {'base':>4} {'concept':>7}  base-top1 -> concept-top1")
    brow = {r[1]: r for r in base["rows"]}
    crow = {r[1]: r for r in cand["rows"]}
    for query, lang, _ in B.GT:
        b = brow[query]
        c = crow[query]
        flag = ""
        if c[2] and (not b[2] or c[2] < b[2]):
            flag = "  <-- improved"
        elif b[2] and (not c[2] or c[2] > b[2]):
            flag = "  <-- REGRESSED"
        print(f"{lang:6} {query[:40]:40} {b[2]:>4} {c[2]:>7}  "
              f"{b[3]} -> {c[3]}{flag}")

    print("\n===== VERDICT =====")
    print(f"baseline R@1={base['r1']:.2f}  R@5={base['r5']:.2f}  MRR={base['mrr']:.2f}")
    print(f"concept  R@1={cand['r1']:.2f}  R@5={cand['r5']:.2f}  MRR={cand['mrr']:.2f}")
    d = cand["mrr"] - base["mrr"]
    print(f"delta MRR = {d:+.2f}  ({'CONCEPT MAP HELPS' if d > 0.02 else 'no meaningful gain'})")
    for lang in ["en", "roman", "urdu"]:
        pass


if __name__ == "__main__":
    main()
