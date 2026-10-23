# Linux Security Baseline Checker

A read-only Bash tool: 15 checks, a pass/fail/skip report in Markdown or text, exit code 1 if any check fails.
Tested against a clean and a deliberately weakened fake system tree. Run it on your own lab VM to produce your real evidence.

## Files
| File | Purpose |
| --- | --- |
| baseline.sh | Runner: runs `checks/*.sh`, prints the report |
| lib.sh | Helpers (`pass`, `fail`, `skip`, fixture support) |
| checks/01..15-*.sh | One check per file with its own ID, TITLE, WHY and FIX |
| config/approved-ports.txt | Ports you expect to listen (edit for your VM) |
| config/approved-sudo.txt | Users allowed passwordless sudo |
| tests/run-tests.sh | 8 automated tests (clean tree, weak tree, read-only proof, bad options, report file) |
| tests/make-fixtures.sh | Builds the fake CLEAN and WEAK system trees |
| samples/ | Example reports from the fixtures |

## Use
```
bash baseline.sh                          # report to screen (run as root for full coverage)
sudo bash baseline.sh --out report.md     # save a Markdown report
bash baseline.sh --format text            # plain text
bash tests/run-tests.sh                   # prove the tool works
```
Copy the folder to your Linux VM (it needs bash, awk, find, stat, sort, comm; `ss`, `apt-get`, `timedatectl` for some checks). Without root, checks that need `/etc/shadow` or `/etc/sudoers` report SKIP and say why.

## The 15 checks
Empty passwords · extra UID 0 accounts · SSH root login · SSH password login · world-writable files in system folders · passwd/shadow permissions · unapproved listening ports (loopback ignored) · pending security updates (Debian/Ubuntu) · host firewall · recent auth log · legacy services (telnet, rsh, tftp) · time sync · NOPASSWD sudo · ASLR · world-writable cron files.

## How it is proven read-only
The test hashes every file, mode and timestamp of a fake tree before and after a run and requires them to be identical. Checks only read files and run query commands.

## Evidence for your portfolio (do on your own VM)
1. Take a snapshot `clean-baseline`. Run `sudo bash baseline.sh --out evidence/run1-clean.md`.
2. Weaken your own lab VM on purpose in one simple way (for example set `PermitRootLogin yes` in sshd_config), run again to `run2-weak.md`, confirm the matching check FAILS.
3. Revert the snapshot and run once more to `run3-fixed.md`.

## Limits
- Tested in fixtures and a sandbox, not on your VM: expect some SKIPs until you run as root on your distribution. Tested logic targets Debian/Ubuntu-style systems; RHEL-style systems need a different update check (08) and use /var/log/secure.
- A pass means these 15 checks passed, not that the machine is secure.
- Check 07 compares against YOUR approved list: edit `config/approved-ports.txt` first.

## Related
`ioc-extractor` turns logs from this VM into a list of indicators.
"# Linux-Baseline" 
