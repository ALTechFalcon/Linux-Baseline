ID=07
TITLE="Only approved ports are listening"
WHY="(Loopback-only listeners are ignored: the network cannot reach them.) Every open port is attack surface; unexpected ones may be a backdoor or forgotten service."
FIX="Stop and disable the service, or add the port to config/approved-ports.txt if it is expected."
run() {
  local approved="$CONFIG_DIR/approved-ports.txt" listening extra
  [ -r "$approved" ] || { skip "no approved-ports.txt"; return; }
  listening=$(fixture_or_cmd ss.txt ss -H -tuln | awk 'NF>=5 && $5 !~ /^(127\.|\[::1\])/ {n=split($5,a,":"); print a[n] "/" $1}' | sort -u)
  [ -n "$listening" ] || { skip "could not read listening ports (is 'ss' installed?)"; return; }
  extra=$(comm -23 <(echo "$listening") <(grep -vE '^\s*(#|$)' "$approved" | sort -u) | paste -sd, -)
  if [ -n "$extra" ]; then fail "unapproved listening: $extra"; else pass "listening ports all approved: $(echo "$listening" | paste -sd, -)"; fi
}
