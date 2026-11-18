#!/usr/bin/env python3
"""
Verify generated Lean proofs against a real Lean 4 + Mathlib toolchain.

For every .lean file in the target directory we:
  1. check for the expected theorem statement in the file,
  2. check there is no `sorry` or `admit` placeholder,
  3. compile it with Mathlib available (`lake env lean <file>`),
and classify the outcome as one of:
  success | wrong_statement | contains_sorry | failed | timeout

It also records a short "inspection" note comparing the core tactic used to
the canonical proof (Nat.add_assoc / Nat.add_comm).

Usage:
  python3 verify.py <dir_with_lean_files> <output_json> [--project PROJ]
The Lean/Mathlib project (PROJ) must already be built (lake exe cache get).
"""

import argparse
import json
import os
import re
import subprocess

COMPILE_TIMEOUT_S = 600

CANON = {
    "addassoc": "theorem add_assoc_test (a b c : ℕ) : (a + b) + c = a + (b + c)",
    "addcomm": "theorem add_comm_test (a b : ℕ) : a + b = b + a",
}


def norm(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()


def which_theorem(fname: str, text: str):
    low = fname.lower()
    if "addassoc" in low or "add_assoc" in low:
        return "addassoc"
    if "addcomm" in low or "add_comm" in low:
        return "addcomm"
    if "add_assoc_test" in text:
        return "addassoc"
    if "add_comm_test" in text:
        return "addcomm"
    return None


def strip_comments(text: str) -> str:
    text = re.sub(r"/-.*?-/", " ", text, flags=re.DOTALL)
    text = re.sub(r"--[^\n]*", " ", text)
    return text


def inspect(text: str, which: str) -> str:
    body = strip_comments(text)
    notes = []
    canon_lemma = "Nat.add_assoc" if which == "addassoc" else "Nat.add_comm"
    generic = "add_assoc" if which == "addassoc" else "add_comm"
    if canon_lemma in body:
        notes.append(f"uses canonical {canon_lemma}")
    elif re.search(rf"\b{generic}\b", body):
        notes.append(f"uses generic {generic} (Mathlib)")
    if re.search(r"\binduction\b", body):
        notes.append("induction")
    if re.search(r"\bomega\b", body):
        notes.append("omega")
    if re.search(r"\bsimp\b", body):
        notes.append("simp")
    if re.search(r"\bring\b", body):
        notes.append("ring")
    if re.search(r"\brfl\b", body):
        notes.append("rfl")
    return "; ".join(notes) if notes else "(no recognised tactic)"


def verify_file(path: str, project: str, timeout: int = COMPILE_TIMEOUT_S):
    fname = os.path.basename(path)
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()

    which = which_theorem(fname, text)
    result = {
        "file": fname,
        "theorem": which,
        "status": None,
        "inspection": inspect(text, which) if which else "(unknown theorem)",
        "compiler_error": None,
    }

    if which is None:
        result["status"] = "unknown_theorem"
        return result

    body = strip_comments(text)
    # escape hatches
    if re.search(r"\bsorry\b", body) or re.search(r"\badmit\b", body):
        result["status"] = "contains_sorry"
        return result
    # canonical statement must be present
    if norm(CANON[which]) not in norm(body):
        result["status"] = "wrong_statement"
        return result

    # compile with Mathlib available
    env = dict(os.environ)
    try:
        proc = subprocess.run(
            ["lake", "env", "lean", os.path.abspath(path)],
            cwd=project,
            capture_output=True,
            text=True,
            timeout=timeout,
            env=env,
        )
    except subprocess.TimeoutExpired:
        result["status"] = "timeout"
        return result

    out = (proc.stdout or "") + "\n" + (proc.stderr or "")
    if proc.returncode == 0 and "error" not in out.lower():
        result["status"] = "success"
    else:
        result["status"] = "failed"
        # keep first few error lines
        errs = [ln for ln in out.splitlines() if ln.strip()]
        result["compiler_error"] = "\n".join(errs[:8])
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    parser.add_argument("target", help="directory containing saved Lean proofs")
    parser.add_argument("out_json", help="output file for verification results")
    parser.add_argument("--project", default="leanproj", help="prepared Lean/Mathlib project")
    args = parser.parse_args()

    files = sorted(
        os.path.join(args.target, f)
        for f in os.listdir(args.target)
        if f.endswith(".lean")
    )
    if not files:
        parser.error(f"no .lean files in {args.target}")

    results = []
    for p in files:
        print(f"[verify] {os.path.basename(p)} ...", flush=True)
        r = verify_file(p, args.project)
        print(f"         -> {r['status']}  ({r['inspection']})", flush=True)
        results.append(r)

    with open(args.out_json, "w", encoding="utf-8") as fh:
        json.dump(results, fh, indent=2, ensure_ascii=False)
    print(f"\n[done] wrote {args.out_json}")


if __name__ == "__main__":
    main()
