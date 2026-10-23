ID=13
TITLE="Passwordless sudo only for approved users"
WHY="NOPASSWD sudo means anyone who controls that account becomes root with no further check."
FIX="Remove NOPASSWD from sudoers (use visudo), or add the user to config/approved-sudo.txt if justified."
run() {
  local files bad="" u approved="$CONFIG_DIR/approved-sudo.txt"
  files=("$ROOT/etc/sudoers" "$ROOT/etc/sudoers.d/"*)
  [ -r "$ROOT/etc/sudoers" ] || { skip "/etc/sudoers not readable; run as root"; return; }
  while read -r u; do
    [ -n "$u" ] || continue
    grep -qxF "$u" "$approved" 2>/dev/null || bad="$bad $u"
  done < <(grep -hE '^[^#]*NOPASSWD' "${files[@]}" 2>/dev/null | awk '{print $1}' | sort -u)
  if [ -n "$bad" ]; then fail "NOPASSWD for:$bad"; else pass "no unapproved NOPASSWD entries"; fi
}
