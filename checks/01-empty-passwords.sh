ID=01
TITLE="No accounts with an empty password"
WHY="An account with no password lets anyone log in as that user."
FIX="Lock or set a password: passwd -l USER (or passwd USER)."
run() {
  [ -r "$ROOT/etc/shadow" ] || { skip "/etc/shadow not readable; run as root"; return; }
  local bad; bad=$(awk -F: '$2=="" {print $1}' "$ROOT/etc/shadow" | paste -sd, -)
  if [ -n "$bad" ]; then fail "empty password: $bad"; else pass "no empty password fields in /etc/shadow"; fi
}
