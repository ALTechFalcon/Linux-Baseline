ID=06
TITLE="Safe permissions on /etc/passwd and /etc/shadow"
WHY="passwd must not be writable by others; shadow (password hashes) must not be readable by others."
FIX="chmod 644 /etc/passwd; chmod 640 /etc/shadow (group shadow)."
run() {
  local p s
  p=$(stat -c %a "$ROOT/etc/passwd" 2>/dev/null) || { skip "cannot stat /etc/passwd"; return; }
  s=$(stat -c %a "$ROOT/etc/shadow" 2>/dev/null) || { skip "cannot stat /etc/shadow"; return; }
  if (( (8#$p & 8#022) == 0 )) && (( (8#$s & 8#037) == 0 )); then
    pass "passwd $p, shadow $s"
  else
    fail "passwd $p (want no group/other write), shadow $s (want 640 or stricter)"
  fi
}
