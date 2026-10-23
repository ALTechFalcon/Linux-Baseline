# Builds two fake root trees: CLEAN (all checks should pass) and WEAK (all should fail).
# Usage: . make-fixtures.sh; make_clean DIR; make_weak DIR
make_clean() {
  local d=$1
  mkdir -p "$d"/{etc/ssh,etc/sudoers.d,etc/cron.d,etc/cron.daily,usr/bin,usr/sbin,bin,sbin,var/log,proc/sys/kernel,fixture}
  printf 'root:x:0:0:root:/root:/bin/bash\nalice:x:1000:1000::/home/alice:/bin/bash\n' >"$d/etc/passwd"
  printf 'root:!:19000:0:99999:7:::\nalice:$6$hash:19000:0:99999:7:::\n' >"$d/etc/shadow"
  chmod 644 "$d/etc/passwd"; chmod 640 "$d/etc/shadow"
  printf 'PermitRootLogin no\nPasswordAuthentication no\n' >"$d/etc/ssh/sshd_config"
  printf 'root ALL=(ALL:ALL) ALL\n%%sudo ALL=(ALL:ALL) ALL\n' >"$d/etc/sudoers"
  printf 'Netid State Recv-Q Send-Q Local:Port Peer:Port\ntcp LISTEN 0 128 0.0.0.0:22 0.0.0.0:*\nudp UNCONN 0 0 127.0.0.53:53 0.0.0.0:*\n' | tail -n +2 >"$d/fixture/ss.txt"
  echo 'Inst bash [5.1] (5.2 Ubuntu:24.04/noble-updates [amd64])' >"$d/fixture/updates.txt"
  printf 'Status: active\n' >"$d/fixture/firewall.txt"
  echo 'NTPSynchronized=yes' >"$d/fixture/timesync.txt"
  echo 'Oct 12 10:00:00 host sshd[1]: Accepted publickey for alice' >"$d/var/log/auth.log"
  echo 2 >"$d/proc/sys/kernel/randomize_va_space"
  touch "$d/etc/crontab" "$d/etc/cron.d/job"; chmod 644 "$d/etc/crontab" "$d/etc/cron.d/job"
}
make_weak() {
  local d=$1; make_clean "$d"
  printf 'root:!:19000:0:99999:7:::\nalice::19000:0:99999:7:::\n' >"$d/etc/shadow"      # 01 empty password
  printf 'toor:x:0:0::/root:/bin/bash\n' >>"$d/etc/passwd"                               # 02 extra uid 0
  printf 'PermitRootLogin yes\nPasswordAuthentication yes\n' >"$d/etc/ssh/sshd_config"   # 03, 04
  touch "$d/usr/bin/tool"; chmod 666 "$d/usr/bin/tool"                                   # 05
  chmod 644 "$d/etc/shadow"                                                              # 06
  echo 'tcp LISTEN 0 128 0.0.0.0:23 0.0.0.0:*' >>"$d/fixture/ss.txt"                     # 07
  echo 'Inst openssl [3.0] (3.0.1 Ubuntu:24.04/noble-security [amd64])' >>"$d/fixture/updates.txt"  # 08
  echo 'Status: inactive' >"$d/fixture/firewall.txt"                                    # 09
  rm "$d/var/log/auth.log"                                                               # 10
  touch "$d/usr/sbin/telnetd"                                                            # 11
  echo 'NTPSynchronized=no' >"$d/fixture/timesync.txt"                                  # 12
  echo 'bob ALL=(ALL) NOPASSWD: ALL' >"$d/etc/sudoers.d/bob"                            # 13
  echo 0 >"$d/proc/sys/kernel/randomize_va_space"                                       # 14
  chmod 666 "$d/etc/cron.d/job"                                                          # 15
}
