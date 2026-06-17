#!/usr/bin/env bash
# sre-postmortem.sh - Fast post-mortem diagnostic collector for Debian/Ubuntu environments

set -euo pipefail

REPORT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME=$(hostname)
OUTPUT_FILE="/var/log/sre_postmortem_$(date +%Y%m%d_%H%M%S).md"

{
    echo "# SRE Sudden Shutdown Triage Report"
    echo "- **Generated At:** ${REPORT_DATE}"
    echo "- **Target Host:** ${HOSTNAME}"
    echo "---"

    echo "## 1. Last Known Boot Sequences & Durations"
    echo '```text'
    last boot || echo "Could not fetch boot logs."
    echo '```'

    echo "## 2. Kernel Hardware Events (Prior Boot)"
    echo "Checking prior boot logs for hardware/driver panics..."
    echo '```text'
    # Grabs the last 150 lines of the previous boot (-b -1) filtering for critical priorities
    journalctl -b -1 -p 0..3 -n 150 --no-pager || echo "No previous boot log available."
    echo '```'

    echo "## 3. OOM / Out of Memory Events (Prior Boot)"
    echo '```text'
    if journalctl -b -1 -g "killed|Out of memory" --no-pager &>/dev/null; then
        journalctl -b -1 -g "killed|Out of memory" --no-pager
    else
        echo "No explicit OOM Killer messages or 'Out of memory' triggers matched in the prior boot log."
    fi
    echo '```'

    echo "## 4. Persistent App Crash Loops (Kubelet Systemd Status)"
    echo '```text'
    if systemctl is-active --quiet kubelet; then
        echo "Kubelet is active."
    else
        echo "Kubelet state: $(systemctl is-enabled kubelet) / $(systemctl is-active kubelet)"
        # Check if it was flapping on swap prior to shutdown
        journalctl -b -1 -u kubelet -n 20 --no-pager || true
    fi
    echo '```'

    echo "## 5. Linux Kernel Core Dumps & Crash Logs"
    echo '```text'
    if [ -d /var/crash ] && [ "$(ls -A /var/crash)" ]; then
        ls -la /var/crash/
    else
        echo "No kernel crash dumps found in /var/crash/."
    fi
    echo '```'

    echo "## 6. Real-Time Memory & Swap Profile"
    echo '```text'
    free -h
    cat /proc/swaps
    echo '```'

} | tee "${OUTPUT_FILE}"

echo "[-] Post-mortem collection complete. Report saved to: ${OUTPUT_FILE}"
