ID=02
TITLE="Only root has user ID 0"
WHY="Any account with UID 0 has full administrator power, whatever its name."
FIX="Remove the account or change its UID: usermod -u NEWUID USER."
run() {
  local bad; bad=$(awk -F: '$3==0 && $1!="root" {print $1}' "$ROOT/etc/passwd" | paste -sd, -)
  if [ -n "$bad" ]; then fail "extra UID 0 accounts: $bad"; else pass "only root has UID 0"; fi
}
