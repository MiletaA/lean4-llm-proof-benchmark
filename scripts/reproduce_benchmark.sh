#!/usr/bin/env bash
# Run the two archived benchmark protocols with explicitly selected Ollama models.
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: bash scripts/reproduce_benchmark.sh <ollama-model> [<ollama-model> ...]" >&2
  exit 2
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJ="$SCRIPT_DIR/../leanproj"
TASKS="$PROJ/tasks"
K="${K:-3}"
LLM_ROUNDS="${LLM_ROUNDS:-4}"
TYPECHECK_TIMEOUT="${TYPECHECK_TIMEOUT:-300}"
GEN_TIMEOUT="${GEN_TIMEOUT:-1800}"
OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"
OLLAMA_URL="${OLLAMA_URL%/}"
SINGLE_SHOT_ONLY="${SINGLE_SHOT_ONLY:-0}"
PROMPT_VARIANT="${PROMPT_VARIANT:-qwen-deepseek}"
case "$PROMPT_VARIANT" in
  qwen-deepseek|petar) PROMPT_VARIANT=qwen-deepseek ;;
  gemma-glm|mileta) PROMPT_VARIANT=gemma-glm ;;
  *) printf 'Error: PROMPT_VARIANT must be qwen-deepseek or gemma-glm\n' >&2; exit 1 ;;
esac
VERIFY_TIMEOUT="${VERIFY_TIMEOUT:-$TYPECHECK_TIMEOUT}"

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
slug() { printf '%s' "$1" | LC_ALL=C sed -E 's/[^a-zA-Z0-9]+/_/g; s/^_//; s/_$//'; }

[[ -f "$SCRIPT_DIR/verify.py" ]] || fail "scripts/verify.py is required. Add the shared verifier before running the benchmark."

for count in "$K" "$LLM_ROUNDS" "$TYPECHECK_TIMEOUT" "$GEN_TIMEOUT" "$VERIFY_TIMEOUT"; do
  [[ "$count" =~ ^[1-9][0-9]*$ ]] || fail "run counts and timeouts must be positive integers"
done
case "$SINGLE_SHOT_ONLY" in
  0|1) ;;
  *) fail "SINGLE_SHOT_ONLY must be 0 or 1" ;;
esac

seen='|'
for model in "$@"; do
  [[ "$model" =~ ^[a-zA-Z0-9][a-zA-Z0-9._:/-]*$ ]] || fail "invalid model tag: $model"
  model_slug="$(slug "$model")"
  case "$seen" in
    *"|$model_slug|"*) fail "duplicate model or filename collision: $model" ;;
  esac
  seen="$seen$model_slug|"
done

for command in python3 curl git lake; do
  command -v "$command" >/dev/null || fail "$command is required (lake is installed with Elan)"
done
if [[ "$SINGLE_SHOT_ONLY" == 0 ]]; then
  ULAM_BIN="${ULAM_BIN:-ulam}"
  command -v "$ULAM_BIN" >/dev/null || fail "ulam is required for agentic runs; set SINGLE_SHOT_ONLY=1 to run only single-shot"
fi
curl --fail --silent --show-error --max-time 5 "$OLLAMA_URL/api/tags" >/dev/null ||
  fail "Ollama is not reachable at $OLLAMA_URL"

WORKDIR="${WORKDIR:-$(mktemp -d "${TMPDIR:-/tmp}/lean-llm-benchmark.XXXXXX")}"
mkdir -p "$WORKDIR"
WORKDIR="$(cd -- "$WORKDIR" && pwd -P)"
OUT="$WORKDIR/out"
mkdir "$OUT" || fail "choose a WORKDIR without an existing out directory"
printf 'Results: %s\n' "$OUT"

if [[ ! -f "$PROJ/.lake/packages/mathlib/.lake/build/lib/lean/Mathlib.olean" ]]; then
  echo "Preparing the pinned Lean/Mathlib project"
  (cd "$PROJ" && lake update && lake exe cache get && lake build Mathlib)
fi

echo "Single-shot (temperature 0)"
OLLAMA_URL="$OLLAMA_URL" GEN_TIMEOUT="$GEN_TIMEOUT" PROMPT_VARIANT="$PROMPT_VARIANT" \
  VERIFY_TIMEOUT="$VERIFY_TIMEOUT" \
  python3 -B - "$SCRIPT_DIR" "$TASKS" "$PROJ" "$OUT" "$@" <<'PY'
import json
import os
from pathlib import Path
import re
import sys
import time
import urllib.request

sys.path.insert(0, sys.argv[1])
from verify import verify_file

tasks, project, out = map(Path, sys.argv[2:5])
models = sys.argv[5:]
url = os.environ["OLLAMA_URL"] + "/api/generate"
generation_timeout = int(os.environ["GEN_TIMEOUT"])
verify_timeout = int(os.environ["VERIFY_TIMEOUT"])
wording = {"qwen-deepseek": "", "gemma-glm": " with"}[os.environ["PROMPT_VARIANT"]]
prompt = (tasks / "single-shot-prompt.txt").read_text(encoding="utf-8")
rows = []
proofs = []

for model in models:
    slug = re.sub(r"[^a-zA-Z0-9]+", "_", model).strip("_")
    for key, name in (("addassoc", "AddAssoc.lean"), ("addcomm", "AddComm.lean")):
        task = (tasks / name).read_text(encoding="utf-8").rstrip("\n")
        payload = {
            "model": model,
            "prompt": prompt.format(task=task, wording=wording),
            "stream": False,
            "options": {"temperature": 0.0, "num_ctx": 4096},
        }
        request = urllib.request.Request(
            url, data=json.dumps(payload).encode(), headers={"Content-Type": "application/json"}
        )
        start = time.monotonic()
        try:
            with urllib.request.urlopen(request, timeout=generation_timeout) as response:
                content = json.load(response).get("response") or ""
            blocks = re.findall(r"```(?:lean4?|)\s*\n(.*?)```", content, re.DOTALL)
            code = max(blocks, key=len) if blocks else content
            code = code.strip() + "\n" if code else "-- no output\n"
        except (OSError, ValueError) as error:
            code = f"-- error: {error}\n"
        path = out / f"ss_{slug}_{key}.lean"
        path.write_text(code, encoding="utf-8")
        proofs.append((slug, key, path))
        print(f"  {model} {key}: generated in {time.monotonic() - start:.1f}s", flush=True)

status_names = {"contains_sorry": "failed(sorry)", "wrong_statement": "failed(wrong-statement)"}
for slug, key, path in proofs:
    result = verify_file(str(path), str(project), timeout=verify_timeout)
    status = status_names.get(result["status"], result["status"])
    rows.append({"model": slug, "theorem": key, "status": status})
    print(f"  {slug} {key}: {status}", flush=True)

(out / "singleshot.json").write_text(json.dumps(rows, indent=2) + "\n", encoding="utf-8")
print(f"Single-shot successes: {sum(row['status'] == 'success' for row in rows)}/{len(rows)}")
PY

if [[ "$SINGLE_SHOT_ONLY" == 1 ]]; then
  echo "Single-shot-only mode requested"
  exit 0
fi

echo "Agentic ($K attempts, up to $LLM_ROUNDS rounds per attempt)"
printf '{"prove":{"typecheck_timeout_s":%s}}\n' "$TYPECHECK_TIMEOUT" > "$OUT/ulam_config.json"
export ULAM_CONFIG="$OUT/ulam_config.json"
export ULAM_OLLAMA_BASE_URL="$OLLAMA_URL"
AGENTIC_CSV="$OUT/agentic.csv"
printf 'model,theorem,attempt,solved,elapsed_s\n' > "$AGENTIC_CSV"
successes=0
attempts=0

for model in "$@"; do
  export ULAM_OLLAMA_MODEL="$model"
  model_slug="$(slug "$model")"
  for key in addassoc addcomm; do
    case "$key" in
      addassoc) template="AddAssoc.lean"; theorem="add_assoc_test" ;;
      addcomm) template="AddComm.lean"; theorem="add_comm_test" ;;
    esac
    for ((attempt=1; attempt<=K; attempt++)); do
      prefix="$OUT/ag_${model_slug}_${key}_r${attempt}"
      cp "$TASKS/$template" "$prefix.lean"
      SECONDS=0
      if "$ULAM_BIN" prove "$prefix.lean" --theorem "$theorem" --llm ollama --lean cli \
          --lean-project "$PROJ" --prove-mode llm --llm-rounds "$LLM_ROUNDS" --verbose > "$prefix.log" 2>&1 &&
          grep -q '^Solved\.' "$prefix.log"; then
        solved=yes
        successes=$((successes + 1))
      else
        solved=no
      fi
      elapsed="$SECONDS"
      attempts=$((attempts + 1))
      printf '  %s %s attempt %s: %s (%ss)\n' "$model" "$key" "$attempt" "$solved" "$elapsed"
      printf '%s,%s,%s,%s,%s\n' "$model" "$key" "$attempt" "$solved" "$elapsed" >> "$AGENTIC_CSV"
    done
  done
done
printf 'Agentic successes: %s/%s\nResults: %s\n' "$successes" "$attempts" "$OUT"
