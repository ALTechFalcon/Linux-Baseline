ID=11
TITLE="No legacy insecure services installed"
WHY="telnet, rsh and tftp send data unencrypted and have no real authentication."
FIX="Remove the package (apt remove telnetd rsh-server tftpd) and use SSH instead."
run() {
  local d n found=""
  for n in telnetd in.telnetd rshd in.rshd rlogind in.rlogind tftpd in.tftpd; do
    for d in usr/sbin usr/bin sbin bin; do
      [ -e "$ROOT/$d/$n" ] && found="$found $n"
    done
  done
  if [ -n "$found" ]; then fail "installed:$found"; else pass "no telnet/rsh/rlogin/tftp servers found"; fi
}
