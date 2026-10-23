ID=08
TITLE="No pending security updates"
WHY="Unpatched known flaws are the most common way machines are compromised."
FIX="Run your package manager's update (apt update && apt upgrade) and reboot if asked."
run() {
  local out n
  if [ -z "${ROOT:-}" ] && ! command -v apt-get >/dev/null; then skip "apt-get not found (not Debian/Ubuntu?)"; return; fi
  out=$(fixture_or_cmd updates.txt apt-get -s upgrade) || true
  [ -n "$out" ] || { skip "could not read update list"; return; }
  n=$(echo "$out" | grep -c '^Inst.*[Ss]ecurity' || true)
  if [ "$n" -gt 0 ]; then fail "$n security update(s) pending"; else pass "no security updates pending"; fi
}
