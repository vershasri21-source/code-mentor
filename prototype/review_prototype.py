"""
Prototype: static analysis (Bandit) + LLM explanation for beginners.

Usage:
    export ANTHROPIC_API_KEY=your_key
    python review_prototype.py sample_bad.py
    python review_prototype.py sample_bad.py --lang hinglish
"""
import argparse
import json
import os
import subprocess
import sys

import anthropic

MODEL = os.environ.get("MODEL", "claude-sonnet-4-6")

SYSTEM = """You are a patient code mentor for first/second-year college students.
You receive findings from a static analysis tool plus the code.
For EACH finding return an object with these keys:
  line (int), concept_tag (snake_case, e.g. sql_injection, hardcoded_secret),
  severity (critical|warning|suggestion),
  hint (one sentence that nudges the student WITHOUT giving the answer),
  explanation (2-4 simple sentences: why it is a problem),
  fix (corrected code snippet).
Do not invent new findings. Respond with ONLY a JSON array, no markdown fences."""


def run_bandit(path):
    proc = subprocess.run(
        ["bandit", "-f", "json", "-q", path],
        capture_output=True, text=True,
    )
    try:
        return json.loads(proc.stdout).get("results", [])
    except json.JSONDecodeError:
        print("Bandit output could not be parsed:", proc.stderr, file=sys.stderr)
        return []


def explain(code, findings, lang):
    slim = [
        {
            "line": f["line_number"],
            "tool_rule": f["test_id"],
            "tool_message": f["issue_text"],
            "tool_severity": f["issue_severity"],
        }
        for f in findings[:10]
    ]
    style = {
        "english": "Write in simple English.",
        "hinglish": "Write explanations in simple Hinglish (Hindi in Roman script mixed with English tech terms).",
    }[lang]
    client = anthropic.Anthropic()
    msg = client.messages.create(
        model=MODEL,
        max_tokens=2000,
        system=SYSTEM + "\n" + style,
        messages=[{
            "role": "user",
            "content": f"CODE:\n{code}\n\nFINDINGS:\n{json.dumps(slim, indent=2)}",
        }],
    )
    text = msg.content[0].text.strip().replace("```json", "").replace("```", "")
    return json.loads(text)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("path")
    ap.add_argument("--lang", choices=["english", "hinglish"], default="english")
    args = ap.parse_args()

    code = open(args.path).read()
    findings = run_bandit(args.path)
    if not findings:
        print("No static-analysis findings. Nothing to explain.")
        return

    for r in explain(code, findings, args.lang):
        print(f"\n[{r['severity'].upper()}] line {r['line']}  #{r['concept_tag']}")
        print(f"  Hint        : {r['hint']}")
        print(f"  Explanation : {r['explanation']}")
        print(f"  Fix         :\n{r['fix']}")


if __name__ == "__main__":
    main()
