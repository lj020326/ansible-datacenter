#!/usr/bin/env bash
# sre-postmortem.sh - Fast post-mortem diagnostic collector for Debian/Ubuntu environments

set -euo pipefail

EMAIL_MODE=false
[[ "${1:-}" == "--email" ]] && EMAIL_MODE=true

REPORT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME=$(hostname)
GPU_TELEMETRY_LOG="/var/log/gpu-vram-telemetry.log"
OUTPUT_FILE="/var/log/sre_postmortem_$(date +%Y%m%d_%H%M%S).md"

# Optional config file dropped by the role
CONFIG_FILE="/etc/sre-postmortem.conf"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# Defaults (overridable via config)
POSTMORTEM_EMAIL_TO="${POSTMORTEM_EMAIL_TO:-admin@example.com}"
POSTMORTEM_EMAIL_FROM="${POSTMORTEM_EMAIL_FROM:-sre-postmortem@${HOSTNAME}}"

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

    echo "## 7. GPU VRAM Utilization Prior to Crash (GPU Tracker Logs)"
    echo '```text'
    # Check both potential log file locations
    ALT_LOG="/var/log/gpu_tracker/gpu-vram-telemetry.log"
    if [ -f "$GPU_TELEMETRY_LOG" ]; then
        TARGET_LOG="$GPU_TELEMETRY_LOG"
    elif [ -f "$ALT_LOG" ]; then
        TARGET_LOG="$ALT_LOG"
    else
        TARGET_LOG=""
    fi

    if [ -n "$TARGET_LOG" ]; then
        echo "Reading telemetry log: ${TARGET_LOG}"
        echo "Last known GPU VRAM state prior to reboot/crash:"
        echo "--------------------------------------------------"
        tail -n 25 "$TARGET_LOG"
        echo "--------------------------------------------------"

        echo "Top suspect processes running prior to shutdown:"
        tail -n 50 "$TARGET_LOG" | grep -oP 'PID:?\s*\K[0-9]+|process_name:?\s*\K[^|]+|Name:\s*\K[^,]+|ollama|vllm|llama-server|hip|roc' | sort | uniq -c
    else
        echo "No GPU telemetry log found at $GPU_TELEMETRY_LOG or$ALT_LOG"
    fi
    echo '```'

} | tee "${OUTPUT_FILE}"

echo "[-] Post-mortem collection complete. Report saved to: ${OUTPUT_FILE}"

if $EMAIL_MODE; then
    SUBJECT="[SRE] Unexpected reboot postmortem – ${HOSTNAME} – ${REPORT_DATE}"

    if command -v mail >/dev/null 2>&1; then
        # Most systems with mailutils / bsd-mailx
        echo "See attached postmortem report." | \
            mail -s "$SUBJECT" -a "$OUTPUT_FILE" \
                 -r "$POSTMORTEM_EMAIL_FROM" \
                 "$POSTMORTEM_EMAIL_TO" \
            && echo "[-] Report emailed to: $POSTMORTEM_EMAIL_TO" \
            || echo "[!] mail command failed – report left on disk" >&2
    elif command -v sendmail >/dev/null 2>&1; then
        # Fallback: simple sendmail
        {
            echo "From: $POSTMORTEM_EMAIL_FROM"
            echo "To: $POSTMORTEM_EMAIL_TO"
            echo "Subject: $SUBJECT"
            echo "MIME-Version: 1.0"
            echo "Content-Type: multipart/mixed; boundary=\"BOUNDARY\""
            echo
            echo "--BOUNDARY"
            echo "Content-Type: text/plain"
            echo
            echo "Unexpected reboot detected. Full triage report attached."
            echo
            echo "--BOUNDARY"
            echo "Content-Type: text/markdown; name=\"$(basename "$OUTPUT_FILE")\""
            echo "Content-Disposition: attachment; filename=\"$(basename "$OUTPUT_FILE")\""
            echo
            cat "$OUTPUT_FILE"
            echo
            echo "--BOUNDARY--"
        } | sendmail -t
        echo "[-] Report emailed via sendmail to: $POSTMORTEM_EMAIL_TO"
    else
        echo "[!] No mailer (mail/sendmail) found – report left on disk only" >&2
    fi
fi
