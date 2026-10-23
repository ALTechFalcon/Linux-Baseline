# Shared helpers for every check. READ-ONLY: nothing here writes outside stdout.
# ROOT is "" for the real system, or a fixture directory used by the tests.
pass() { echo "PASS|$*"; }
fail() { echo "FAIL|$*"; }
skip() { echo "SKIP|$*"; }

# fixture_or_cmd FILE CMD...  : in fixture mode print $ROOT/fixture/FILE, else run CMD.
fixture_or_cmd() {
  local f=$1; shift
  if [ -n "${ROOT:-}" ]; then
    cat "$ROOT/fixture/$f" 2>/dev/null
  else
    "$@" 2>/dev/null
  fi
}
