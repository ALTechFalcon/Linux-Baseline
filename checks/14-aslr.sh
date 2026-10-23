ID=14
TITLE="Address-space randomisation (ASLR) is full"
WHY="ASLR makes memory-corruption attacks much harder to aim."
FIX="sysctl -w kernel.randomize_va_space=2 and persist it in /etc/sysctl.d/."
run() {
  local v; v=$(cat "$ROOT/proc/sys/kernel/randomize_va_space" 2>/dev/null) || { skip "cannot read randomize_va_space"; return; }
  if [ "$v" = "2" ]; then pass "randomize_va_space=2"; else fail "randomize_va_space=$v (want 2)"; fi
}
