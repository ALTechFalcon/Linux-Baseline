ID=12
TITLE="Clock synchronisation is on"
WHY="Wrong clocks ruin log timelines and break certificates and Kerberos."
FIX="Enable time sync: timedatectl set-ntp true (or install chrony)."
run() {
  local v
  v=$(fixture_or_cmd timesync.txt timedatectl show -p NTPSynchronized | head -1)
  [ -n "$v" ] || { skip "timedatectl not available"; return; }
  if [ "$v" = "NTPSynchronized=yes" ]; then pass "$v"; else fail "$v"; fi
}
