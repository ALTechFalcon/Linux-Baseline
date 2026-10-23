ID=10
TITLE="Authentication log exists and is recent"
WHY="Without logs you cannot see logins or attacks; stale logs mean logging may have stopped."
FIX="Make sure rsyslog or journald persistence is running and /var/log/auth.log (or secure) is written."
run() {
  local f
  for f in "$ROOT/var/log/auth.log" "$ROOT/var/log/secure"; do
    if [ -s "$f" ]; then
      if find "$f" -mtime -30 2>/dev/null | grep -q .; then pass "$(basename "$f") present, written within 30 days"; else fail "$(basename "$f") exists but not written for 30+ days"; fi
      return
    fi
  done
  if [ -z "${ROOT:-}" ] && command -v journalctl >/dev/null && journalctl -q -n1 >/dev/null 2>&1; then
    pass "no auth.log; journald is available"; return
  fi
  fail "no auth.log or secure file"
}
