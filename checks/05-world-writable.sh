ID=05
TITLE="No world-writable files in system folders"
WHY="Any user could change a program or config that the system trusts."
FIX="Remove the permission: chmod o-w FILE, then find out how it got there."
run() {
  local bad
  bad=$(find "$ROOT/etc" "$ROOT/usr/bin" "$ROOT/usr/sbin" "$ROOT/bin" "$ROOT/sbin" \
        -xdev -type f -perm -0002 2>/dev/null | head -5 | paste -sd' ' -)
  if [ -n "$bad" ]; then fail "world-writable: $bad"; else pass "none found in /etc and program folders"; fi
}
