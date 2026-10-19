# -*- coding: utf-8 -*-
"""Build assets/data/legal_corpus.json from the raw datasets in data/.

Sources
-------
Structured statute CSVs (Book, Chapter, Chapter Title, Section, Heading, Defination):
  Pakistan_Penal_Code.csv, Code_of_Criminal_Procedure_Structured...csv,
  qanun-e-shahadat_1984.csv, Police_law.csv, Transfer%20property.csv,
  2-limitation-act-1908-pdf_extracted.csv, Muslim_Family_Laws_Ordinance_1961.csv,
  Datatset%20For%20FAISS.csv
QA pairs (Query, Response):
  Legal_QA_dataset_From_lawyers.csv, combined_legal_dataset.csv,
  train-00000-of-00001.parquet
Raw statute texts:
  pdf_data.json (array of {file_name, text}) -> statute title index + selected texts

Output: assets/data/legal_corpus.json  (compact keys to keep APK small)
"""
import csv
import json
import re
import sys
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"
OUT = ROOT / "assets" / "data" / "legal_corpus.json"
OUT.parent.mkdir(parents=True, exist_ok=True)

MAX_TEXT = 2200          # chars kept per statute section
MAX_QA = 1400            # chars kept per QA answer
MAX_LIB_TEXT = 60000     # chars per selected library statute
LIB_TEXT_BUDGET = 5_000_000  # total chars of library texts bundled

# (file, id, name, urdu, group, icon, accent, csv-book-name)
STRUCTURED = [
    ("Pakistan_Penal_Code.csv", "ppc", "Pakistan Penal Code 1860",
     "پاکستان پینل کوڈ 1860", "Criminal Law", "gavel", 0xFFB3452F,
     "Pakistan Penal Code"),
    ("Code_of_Criminal_Procedure_Structured%20upto%2016%20chapter.csv", "crpc",
     "Code of Criminal Procedure 1898", "ضابطہ فوجداری 1898", "Criminal Law",
     "local_police", 0xFF8A4B15, "Code of Criminal Procedure, 1898"),
    ("qanun-e-shahadat_1984.csv", "qso", "Qanun-e-Shahadat Order 1984",
     "قانون شہادت حکم 1984", "Evidence Law", "fact_check", 0xFF5B4B8A,
     "Qanun-e-Shahadat Order, 1984"),
    ("Police_law.csv", "police", "Police Order 2002", "پولیس آرڈر 2002",
     "Police Law", "shield", 0xFF2C5F8A, "Police Law"),
    ("Transfer%20property.csv", "topa", "Transfer of Property Act 1882",
     "ٹرانسفر آف پراپرٹی ایکٹ 1882", "Property Law", "home_work", 0xFF1F6E43,
     "Transfer of Property Act"),
    ("2-limitation-act-1908-pdf_extracted.csv", "limitation",
     "Limitation Act 1908", "محکومہ ایکٹ 1908", "Civil Procedure",
     "timer", 0xFF6E561F, "Limitation Act, 1908"),
    ("Muslim_Family_Laws_Ordinance_1961.csv", "mflo",
     "Muslim Family Laws Ordinance 1961", "مسلم فیملی لاز آرڈیننس 1961",
     "Family Law", "family_restroom", 0xFF8A2C5B,
     "Muslim Family Laws Ordinance, 1961"),
]

FAISS = "Datatset%20For%20FAISS.csv"
GOOD_BOOKS = {
    "Pakistan Penal Code",
    "Code of Criminal Procedure, 1898",
    "Qanun-e-Shahadat Order, 1984",
    "Police Law",
    "Transfer of Property Act",
    "Limitation Act, 1908",
    "Muslim Family Laws Ordinance, 1961",
}


def clean(text):
    if text is None:
        return ""
    t = str(text).replace("\r", " ").replace("\n", " ")
    t = re.sub(r"\s+", " ", t).strip()
    return t


def read_structured(path):
    rows = []
    with open(path, encoding="utf-8", errors="replace", newline="") as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            book = clean(row.get("Book"))
            if not book or book not in GOOD_BOOKS:
                continue
            section = clean(row.get("Section"))
            heading = clean(row.get("Heading"))
            body = clean(row.get("Defination"))
            if not section or not body:
                continue
            rows.append((book, section, heading, body))
    return rows


def main():
    # 1. Structured statutes: merge CSVs, dedup by (book, section, heading).
    merged = {}  # key -> (book, section, heading, body)
    for path in [DATA / f for f, *_ in STRUCTURED] + [DATA / FAISS]:
        for book, section, heading, body in read_structured(path):
            key = (book, section, heading.lower()[:60])
            if key not in merged or len(body) > len(merged[key][3]):
                merged[key] = (book, section, heading, body)

    categories = []
    total_sections = 0
    for fname, cid, name, urdu, group, icon, accent, book_name in STRUCTURED:
        entries = []
        seen = set()
        for book, section, heading, body in merged.values():
            if book != book_name:
                continue
            k = (section, heading.lower()[:60])
            if k in seen:
                continue
            seen.add(k)
            entries.append({"s": section, "h": heading, "t": body[:MAX_TEXT]})
        entries.sort(key=lambda e: (
            int(e["s"]) if e["s"].isdigit() else 10_000, e["s"]))
        total_sections += len(entries)
        categories.append({
            "id": cid, "kind": "statute", "name": name, "nameUrdu": urdu,
            "group": group, "icon": icon, "accent": accent,
            "count": len(entries), "entries": entries,
        })
        print(f"  {name}: {len(entries)} sections")

    # 2. QA datasets, dedup by normalised question.
    qa_items = {}
    for src in [DATA / "Legal_QA_dataset_From_lawyers.csv"]:
        with open(src, encoding="utf-8", errors="replace", newline="") as fh:
            for row in csv.DictReader(fh):
                q = clean(row.get("Query"))
                a = clean(row.get("Response"))
                if q and a and len(q) > 12:
                    qa_items[q.lower()[:120]] = {"q": q, "a": a[:MAX_QA]}
    combined = pd.read_csv(DATA / "combined_legal_dataset.csv")
    for _, row in combined.iterrows():
        q, a = clean(row.get("Query")), clean(row.get("Response"))
        if q and a and len(q) > 12:
            qa_items.setdefault(q.lower()[:120], {"q": q, "a": a[:MAX_QA]})
    parquet = pd.read_parquet(DATA / "train-00000-of-00001.parquet")
    for _, row in parquet.iterrows():
        q, a = clean(row.get("Query")), clean(row.get("Response"))
        if q and a and len(q) > 12:
            qa_items.setdefault(q.lower()[:120], {"q": q, "a": a[:MAX_QA]})
    # A QA pair is indexed with its *question* as the high-signal "heading"
    # field (5.0x token weight) and its answer as the low-weight "body". The
    # long, detailed lawyer questions are therefore the single best match for
    # how citizens actually phrase problems - so we keep ALL of them (they
    # range up to ~790 chars) instead of capping by length. We only sort by
    # length so the shorter, more general phrasings are emitted first.
    qa_list = sorted(qa_items.values(), key=lambda x: len(x["q"]))
    categories.append({
        "id": "qa", "kind": "qa", "name": "Lawyers' Q&A Archive",
        "nameUrdu": "وکلا کے سوال و جواب", "group": "Guidance",
        "icon": "question_answer", "accent": 0xFF2C5F8A,
        "count": len(qa_list), "entries": qa_list,
    })
    print(f"  QA archive: {len(qa_list)} pairs")

    # 3. Federal statute library from pdf_data.json.
    with open(DATA / "pdf_data.json", encoding="utf-8") as fh:
        pdfs = json.load(fh)
    title_re = re.compile(
        r"(THE\s+[A-Z][A-Z\s,\.\-\(\)\'\&]+?\s+"
        r"(?:ACT|ORDINANCE|ORDER|RULES?|REGULATION),?\s*\d{4})")
    library = []
    seen_titles = set()
    for item in pdfs:
        text = (item.get("text") or "").strip()
        if len(text) < 400:
            continue
        # Scan past the cover page / ministry preamble: the official title line
        # often sits a few hundred chars in, so a 600-char window silently
        # dropped many statutes. 1500 is enough without risking false matches.
        head = text[:1500]
        m = title_re.search(head)
        if not m:
            continue
        title = clean(m.group(1))
        title = re.sub(r"\s+", " ", title)
        title = re.sub(r"^\s*THE\s+", "", title).strip()
        if not title or title in seen_titles:
            continue
        seen_titles.add(title)
        library.append({"title": title, "chars": len(text), "text": text})
    library.sort(key=lambda x: x["title"])
    print(f"  Statute library: {len(library)} titles")

    # Select citizen-relevant statutes to bundle in full (capped).
    KEYWORDS = [
        "constitution", "family", "penal", "criminal", "evidence",
        "shahadat", "property", "rent", "consumer", "labour", "labor",
        "cyber", "child", "women", "guardian", "succession", "motor vehicle",
        "traffic", "police", "anti-corruption", "nab", "drug", "arms",
        "muslim", "hindu", "christian", "inheritance", "court fee",
        "specific relief", "contract", "registration",
    ]
    selected, budget = [], LIB_TEXT_BUDGET
    for st in library:
        low = st["title"].lower()
        if not any(k in low for k in KEYWORDS):
            continue
        take = min(st["chars"], MAX_LIB_TEXT, budget)
        if take < 1500:
            continue
        selected.append({
            "title": st["title"], "t": st["text"][:take],
        })
        budget -= take
        if budget <= 0:
            break
    index_only = [
        {"title": st["title"], "chars": st["chars"]}
        for st in library if st not in [s for s in selected if s["title"] == st["title"]]
    ]
    # index_only: titles not selected for full text
    selected_titles = {s["title"] for s in selected}
    index_only = [{"title": st["title"], "chars": st["chars"]}
                  for st in library if st["title"] not in selected_titles]
    categories.append({
        "id": "library", "kind": "library",
        "name": "Federal Statute Library", "nameUrdu": "وفاقی قوانین کی لائبریری",
        "group": "Reference", "icon": "menu_book", "accent": 0xFF6E561F,
        "count": len(library), "fullTexts": selected,
        "titles": index_only,
    })
    print(f"  Library full texts: {len(selected)} ({LIB_TEXT_BUDGET - budget} chars), "
          f"index-only: {len(index_only)}")

    corpus = {
        "version": 4, "built": "2026-10-12",
        "sections": total_sections,
        "categories": categories,
    }
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(corpus, fh, ensure_ascii=False, separators=(",", ":"))
    size = OUT.stat().st_size
    print(f"Wrote {OUT} ({size/1_048_576:.2f} MB, {total_sections} statute sections)")


if __name__ == "__main__":
    sys.exit(main())
