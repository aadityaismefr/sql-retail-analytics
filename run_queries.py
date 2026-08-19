"""
Run every query in sql/ against data/retail.duckdb and write the results to
results/ as markdown tables, so the repo shows real output and not just SQL.

Usage:
    python data/generate_data.py     # once, builds the database
    python run_queries.py            # runs 01..15 and refreshes results/
    python run_queries.py 05         # run a single query and print it
"""

from __future__ import annotations

import sys
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parent
SQL_DIR = ROOT / "sql"
OUT_DIR = ROOT / "results"
DB = ROOT / "data" / "retail.duckdb"

MAX_ROWS = 25   # results files stay readable on GitHub


def query_files(prefix: str | None = None):
    files = sorted(f for f in SQL_DIR.glob("*.sql") if not f.name.startswith("00_"))
    if prefix:
        files = [f for f in files if f.name.startswith(prefix)]
    return files


def leading_comment(sql: str) -> str:
    lines = []
    for line in sql.splitlines():
        if line.startswith("--"):
            lines.append(line.lstrip("- ").rstrip())
        elif lines:
            break
    return "\n".join(lines)


def main() -> int:
    if not DB.exists():
        print(f"error: {DB} not found - run `python data/generate_data.py` first",
              file=sys.stderr)
        return 1

    OUT_DIR.mkdir(exist_ok=True)
    con = duckdb.connect(str(DB), read_only=True)
    prefix = sys.argv[1] if len(sys.argv) > 1 else None

    for path in query_files(prefix):
        sql = path.read_text()
        df = con.execute(sql).fetchdf()
        truncated = len(df) > MAX_ROWS

        body = [
            f"# {path.stem}",
            "",
            "> " + leading_comment(sql).replace("\n", "\n> "),
            "",
            "```sql",
            sql.strip(),
            "```",
            "",
            f"**{len(df):,} row(s)**" + (f" - showing first {MAX_ROWS}" if truncated else ""),
            "",
            df.head(MAX_ROWS).to_markdown(index=False),
            "",
        ]
        (OUT_DIR / f"{path.stem}.md").write_text("\n".join(body))
        print(f"{path.name:<34} -> results/{path.stem}.md  ({len(df):,} rows)")

        if prefix:
            print()
            print(df.head(MAX_ROWS).to_string(index=False))

    con.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
