ID=09
TITLE="Host firewall is active"
WHY="A host firewall limits what the network can reach even if a service is misconfigured."
FIX="Enable one: ufw enable, or load an nftables ruleset with a default drop policy."
run() {
  local out
  out=$( { fixture_or_cmd firewall.txt ufw status; fixture_or_cmd firewall.txt nft list ruleset; fixture_or_cmd firewall.txt iptables -S; } 2>/dev/null | sort -u )
  [ -n "$out" ] || { skip "could not read firewall state (need root?)"; return; }
  if echo "$out" | grep -qE 'Status: active|hook input|-P INPUT (DROP|REJECT)'; then pass "firewall active"; else fail "no active firewall rules found"; fi
}
