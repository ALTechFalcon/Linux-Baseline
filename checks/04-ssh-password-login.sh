ID=04
TITLE="SSH password login is disabled"
WHY="Password logins can be guessed or brute-forced; keys cannot."
FIX="First confirm key login works, then set 'PasswordAuthentication no' and reload sshd."
. "$(dirname "${BASH_SOURCE[0]}")/03-ssh-root-login.sh"  # reuse sshd_value
ID=04; TITLE="SSH password login is disabled"
WHY="Password logins can be guessed or brute-forced; keys cannot."
FIX="First confirm key login works, then set 'PasswordAuthentication no' and reload sshd."
run() {
  [ -r "$ROOT/etc/ssh/sshd_config" ] || { skip "sshd_config not found (sshd not installed?)"; return; }
  local v; v=$(sshd_value PasswordAuthentication) || v=""
  if [ "$v" = "no" ]; then pass "PasswordAuthentication no"; else fail "PasswordAuthentication ${v:-unset (default yes)}"; fi
}
