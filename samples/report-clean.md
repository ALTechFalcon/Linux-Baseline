# Linux baseline report

- Host: vm
- Date: 2026-10-12 07:32 UTC
- Target: <fixture>/c
- Result: **15 pass, 0 fail, 0 skip**

| Status | ID | Check | Evidence |
| --- | --- | --- | --- |
| PASS | 01 | No accounts with an empty password | no empty password fields in /etc/shadow |
| PASS | 02 | Only root has user ID 0 | only root has UID 0 |
| PASS | 03 | SSH root login is disabled | PermitRootLogin no |
| PASS | 04 | SSH password login is disabled | PasswordAuthentication no |
| PASS | 05 | No world-writable files in system folders | none found in /etc and program folders |
| PASS | 06 | Safe permissions on /etc/passwd and /etc/shadow | passwd 644, shadow 640 |
| PASS | 07 | Only approved ports are listening | listening ports all approved: 22/tcp |
| PASS | 08 | No pending security updates | no security updates pending |
| PASS | 09 | Host firewall is active | firewall active |
| PASS | 10 | Authentication log exists and is recent | auth.log present, written within 30 days |
| PASS | 11 | No legacy insecure services installed | no telnet/rsh/rlogin/tftp servers found |
| PASS | 12 | Clock synchronisation is on | NTPSynchronized=yes |
| PASS | 13 | Passwordless sudo only for approved users | no unapproved NOPASSWD entries |
| PASS | 14 | Address-space randomisation (ASLR) is full | randomize_va_space=2 |
| PASS | 15 | No cron files writable by others | no world-writable cron files |

_A pass means these checks passed. It does not mean the machine is secure._
