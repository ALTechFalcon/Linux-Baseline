ID=03
TITLE="SSH root login is disabled"
WHY="Direct root login gives attackers a known username and full power if the password leaks."
FIX="Set 'PermitRootLogin no' in sshd_config and reload sshd."
sshd_value() { # first non-comment match wins, as in sshd
  local key=$1 f
  for f in "$ROOT/etc/ssh/sshd_config.d/"*.conf "$ROOT/etc/ssh/sshd_config"; do
    [ -r "$f" ] || continue
    awk -v k="$key" 'tolower($1)==tolower(k) {print tolower($2); exit}' "$f" | grep . && return
  done
  return 1
}
run() {
  [ -r "$ROOT/etc/ssh/sshd_config" ] || { skip "sshd_config not found (sshd not installed?)"; return; }
  local v; v=$(sshd_value PermitRootLogin) || v=""
  case "$v" in
    "") pass "not set; OpenSSH default is prohibit-password" ;;
    no|prohibit-password|without-password) pass "PermitRootLogin $v" ;;
    *) fail "PermitRootLogin $v" ;;
  esac
}
