#!/usr/bin/env bash
# Runs baseline.sh on a CLEAN and a WEAK fake tree, and proves the tool is read-only.
set -u
HERE=$(cd "$(dirname "$0")" && pwd); BASE="bash $HERE/../baseline.sh"
. "$HERE/make-fixtures.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
fails=0
ok()  { echo "ok   - $1"; }
bad() { echo "FAIL - $1"; fails=$((fails+1)); }

make_clean "$T/clean"; make_weak "$T/weak"

out=$($BASE --root "$T/clean" --format text); rc=$?
[ $rc -eq 0 ] && ok "clean tree: exit 0" || bad "clean tree exit $rc"
echo "$out" | grep -q 'Result: 15 pass, 0 fail, 0 skip' && ok "clean tree: 15 pass" || { bad "clean tree result"; echo "$out"; }

out=$($BASE --root "$T/weak" --format text); rc=$?
[ $rc -eq 1 ] && ok "weak tree: exit 1" || bad "weak tree exit $rc"
echo "$out" | grep -q 'Result: 0 pass, 15 fail, 0 skip' && ok "weak tree: all 15 checks fail as designed" || { bad "weak tree result"; echo "$out"; }
for id in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15; do
  echo "$out" | grep -q "^\[FAIL\] $id " || bad "weak tree: check $id did not fail"
done

# Read-only proof: snapshot every file's hash, mode, mtime before and after.
snap() { ( cd "$1" && find . -print0 | sort -z | xargs -0 stat -c '%n %a %Y %s' ; find . -type f -print0 | sort -z | xargs -0 sha256sum ); }
snap "$T/weak" >"$T/before"; $BASE --root "$T/weak" >"$T/ro-out"; [ $? -eq 1 ] && grep -q "15 fail" "$T/ro-out" || bad "read-only run did not execute properly"; snap "$T/weak" >"$T/after"
cmp -s "$T/before" "$T/after" && ok "read-only: tree identical after a run" || bad "tool changed the tree"

$BASE --bogus >/dev/null 2>&1; [ $? -eq 2 ] && ok "bad option: exit 2" || bad "bad option exit code"
$BASE --root /nonexistent >/dev/null 2>&1; [ $? -eq 2 ] && ok "missing root: exit 2" || bad "missing root exit code"
$BASE --root "$T/clean" --out "$T/r.md" >/dev/null && grep -q '^# Linux baseline report' "$T/r.md" && ok "markdown report written" || bad "markdown report"

echo; [ $fails -eq 0 ] && echo "ALL TESTS PASSED" || echo "$fails TEST(S) FAILED"
exit $((fails>0))
