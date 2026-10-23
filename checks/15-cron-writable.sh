ID=15
TITLE="No cron files writable by others"
WHY="A world-writable cron job lets any user run commands as whoever owns the job (often root)."
FIX="chmod o-w on the file or folder, and review its contents."
run() {
  local bad
  bad=$(find "$ROOT/etc/crontab" "$ROOT/etc/cron.d" "$ROOT/etc/cron.daily" "$ROOT/etc/cron.hourly" \
        "$ROOT/etc/cron.weekly" "$ROOT/etc/cron.monthly" ! -type l -perm -0002 2>/dev/null | head -5 | paste -sd' ' -)
  if [ -n "$bad" ]; then fail "writable by others: $bad"; else pass "no world-writable cron files"; fi
}
