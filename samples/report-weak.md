# Linux baseline report

- Host: vm
- Date: 2026-10-12 07:32 UTC
- Target: <fixture>/w
- Result: **0 pass, 15 fail, 0 skip**

| Status | ID | Check | Evidence |
| --- | --- | --- | --- |
| FAIL | 01 | No accounts with an empty password | empty password: alice |
| FAIL | 02 | Only root has user ID 0 | extra UID 0 accounts: toor |
| FAIL | 03 | SSH root login is disabled | PermitRootLogin yes |
| FAIL | 04 | SSH password login is disabled | PasswordAuthentication yes |
| FAIL | 05 | No world-writable files in system folders | world-writable: <fixture>/w/etc/cron.d/job /tmp/tmp.otzC09iAEV/w/usr/bin/tool |
| FAIL | 06 | Safe permissions on /etc/passwd and /etc/shadow | passwd 644 (want no group/other write), shadow 644 (want 640 or stricter) |
| FAIL | 07 | Only approved ports are listening | unapproved listening: 23/tcp |
| FAIL | 08 | No pending security updates | 1 security update(s) pending |
| FAIL | 09 | Host firewall is active | no active firewall rules found |
| FAIL | 10 | Authentication log exists and is recent | no auth.log or secure file |
| FAIL | 11 | No legacy insecure services installed | installed: telnetd |
| FAIL | 12 | Clock synchronisation is on | NTPSynchronized=no |
| FAIL | 13 | Passwordless sudo only for approved users | NOPASSWD for: bob |
| FAIL | 14 | Address-space randomisation (ASLR) is full | randomize_va_space=0 (want 2) |
| FAIL | 15 | No cron files writable by others | writable by others: <fixture>/w/etc/cron.d/job |

## What to fix

**01 No accounts with an empty password**
- Why it matters: An account with no password lets anyone log in as that user.
- Fix: Lock or set a password: passwd -l USER (or passwd USER).

**02 Only root has user ID 0**
- Why it matters: Any account with UID 0 has full administrator power, whatever its name.
- Fix: Remove the account or change its UID: usermod -u NEWUID USER.

**03 SSH root login is disabled**
- Why it matters: Direct root login gives attackers a known username and full power if the password leaks.
- Fix: Set 'PermitRootLogin no' in sshd_config and reload sshd.

**04 SSH password login is disabled**
- Why it matters: Password logins can be guessed or brute-forced; keys cannot.
- Fix: First confirm key login works, then set 'PasswordAuthentication no' and reload sshd.

**05 No world-writable files in system folders**
- Why it matters: Any user could change a program or config that the system trusts.
- Fix: Remove the permission: chmod o-w FILE, then find out how it got there.

**06 Safe permissions on /etc/passwd and /etc/shadow**
- Why it matters: passwd must not be writable by others; shadow (password hashes) must not be readable by others.
- Fix: chmod 644 /etc/passwd; chmod 640 /etc/shadow (group shadow).

**07 Only approved ports are listening**
- Why it matters: (Loopback-only listeners are ignored: the network cannot reach them.) Every open port is attack surface; unexpected ones may be a backdoor or forgotten service.
- Fix: Stop and disable the service, or add the port to config/approved-ports.txt if it is expected.

**08 No pending security updates**
- Why it matters: Unpatched known flaws are the most common way machines are compromised.
- Fix: Run your package manager's update (apt update && apt upgrade) and reboot if asked.

**09 Host firewall is active**
- Why it matters: A host firewall limits what the network can reach even if a service is misconfigured.
- Fix: Enable one: ufw enable, or load an nftables ruleset with a default drop policy.

**10 Authentication log exists and is recent**
- Why it matters: Without logs you cannot see logins or attacks; stale logs mean logging may have stopped.
- Fix: Make sure rsyslog or journald persistence is running and /var/log/auth.log (or secure) is written.

**11 No legacy insecure services installed**
- Why it matters: telnet, rsh and tftp send data unencrypted and have no real authentication.
- Fix: Remove the package (apt remove telnetd rsh-server tftpd) and use SSH instead.

**12 Clock synchronisation is on**
- Why it matters: Wrong clocks ruin log timelines and break certificates and Kerberos.
- Fix: Enable time sync: timedatectl set-ntp true (or install chrony).

**13 Passwordless sudo only for approved users**
- Why it matters: NOPASSWD sudo means anyone who controls that account becomes root with no further check.
- Fix: Remove NOPASSWD from sudoers (use visudo), or add the user to config/approved-sudo.txt if justified.

**14 Address-space randomisation (ASLR) is full**
- Why it matters: ASLR makes memory-corruption attacks much harder to aim.
- Fix: sysctl -w kernel.randomize_va_space=2 and persist it in /etc/sysctl.d/.

**15 No cron files writable by others**
- Why it matters: A world-writable cron job lets any user run commands as whoever owns the job (often root).
- Fix: chmod o-w on the file or folder, and review its contents.

_A pass means these checks passed. It does not mean the machine is secure._
