#!/usr/bin/env bash
# Linux security baseline checker. READ-ONLY: it never changes the system.
# Usage: baseline.sh [--format md|text] [--out FILE] [--root DIR] [-h]
#   --root DIR  check a fixture tree instead of the live system (used by the tests)
# Exit codes: 0 all checks pass or skip, 1 at least one FAIL, 2 usage error.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
FORMAT=md; OUT=""; ROOT=""
CONFIG_DIR=${BASELINE_CONFIG:-$HERE/config}

usage() { sed -n '2,5p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }
while [ $# -gt 0 ]; do
  case $1 in
    --format) FORMAT=${2:-}; shift 2 ;;
    --out)    OUT=${2:-};    shift 2 ;;
    --root)   ROOT=${2:-};   shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done
case $FORMAT in md|text) ;; *) echo "format must be md or text" >&2; exit 2 ;; esac
if [ -n "$ROOT" ]; then
  [ -d "$ROOT" ] || { echo "root not found: $ROOT" >&2; exit 2; }
  ROOT=${ROOT%/}
fi
export ROOT CONFIG_DIR

pass=0 failn=0 skipn=0
rows=(); fixes=()
for f in "$HERE"/checks/*.sh; do
  line=$( . "$HERE/lib.sh"; . "$f"
          r=$(run 2>/dev/null)
          printf '%s\x1f%s\x1f%s\x1f%s\x1f%s' "$ID" "$TITLE" "$WHY" "$FIX" "$r" )
  IFS=$'\x1f' read -r id title why fix res <<<"$line"
  status=${res%%|*}; evidence=${res#*|}
  [ -n "$status" ] || { status=SKIP; evidence="check produced no result"; }
  evidence=$(printf '%s' "$evidence" | tr '\n|' '  ' | cut -c1-200)
  case $status in PASS) ((pass++));; FAIL) ((failn++));; *) ((skipn++));; esac
  rows+=("$status"$'\x1f'"$id"$'\x1f'"$title"$'\x1f'"$evidence")
  [ "$status" = FAIL ] && fixes+=("$id"$'\x1f'"$title"$'\x1f'"$why"$'\x1f'"$fix")
done

render() {
  local host date r s i t e
  host=$(hostname 2>/dev/null || echo unknown); date=$(date -u '+%Y-%m-%d %H:%M UTC')
  if [ "$FORMAT" = md ]; then
    echo "# Linux baseline report"; echo
    echo "- Host: $host"; echo "- Date: $date"; echo "- Target: ${ROOT:-live system}"
    echo "- Result: **$pass pass, $failn fail, $skipn skip**"; echo
    echo "| Status | ID | Check | Evidence |"; echo "| --- | --- | --- | --- |"
    for r in "${rows[@]}"; do IFS=$'\x1f' read -r s i t e <<<"$r"; echo "| $s | $i | $t | $e |"; done
    if [ ${#fixes[@]} -gt 0 ]; then
      echo; echo "## What to fix"
      for r in "${fixes[@]}"; do IFS=$'\x1f' read -r i t w x <<<"$r"
        echo; echo "**$i $t**"; echo "- Why it matters: $w"; echo "- Fix: $x"; done
    fi
    echo; echo "_A pass means these checks passed. It does not mean the machine is secure._"
  else
    echo "LINUX BASELINE REPORT"; echo "Host: $host"; echo "Date: $date"; echo "Target: ${ROOT:-live system}"
    echo "Result: $pass pass, $failn fail, $skipn skip"; echo
    for r in "${rows[@]}"; do IFS=$'\x1f' read -r s i t e <<<"$r"; printf '[%s] %s %s - %s\n' "$s" "$i" "$t" "$e"; done
    for r in "${fixes[@]}"; do IFS=$'\x1f' read -r i t w x <<<"$r"
      printf '\nFIX %s %s\n  why: %s\n  fix: %s\n' "$i" "$t" "$w" "$x"; done
  fi
}
if [ -n "$OUT" ]; then render >"$OUT"; echo "report written to $OUT"; else render; fi
[ "$failn" -gt 0 ] && exit 1
exit 0
