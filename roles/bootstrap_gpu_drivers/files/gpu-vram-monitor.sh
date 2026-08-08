#!/usr/bin/env bash
# /usr/local/bin/gpu-vram-monitor.sh
# Logs NVIDIA and AMD ROCm GPU memory & process utilization to persistent disk.

LOG_DIR="/var/log/gpu_tracker"
LOG_FILE="${LOG_DIR}/gpu-vram-telemetry.log"
MAX_LOG_SIZE_MB=20

mkdir -p "${LOG_DIR}"

# Function to rotate logs if file exceeds size threshold
rotate_logs() {
    if [[ -f "${LOG_FILE}" ]]; then
        local size
        size=$(du -m "${LOG_FILE}" | cut -f1)
        if [[ ${size} -ge ${MAX_LOG_SIZE_MB} ]]; then
            mv "${LOG_FILE}" "${LOG_FILE}.1"
        fi
    fi
}

# Collect NVIDIA telemetry if nvidia-smi exists
get_nvidia_metrics() {
    if command -v nvidia-smi &>/dev/null; then
        local stats processes
        stats=$(nvidia-smi --query-gpu=index,memory.used,memory.total,utilization.gpu --format=csv,noheader,nounits 2>/dev/null | tr '\n' ' ; ')
        processes=$(nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader,nounits 2>/dev/null | tr '\n' ' | ')
        echo "NVIDIA: Stats [${stats:-N/A}] Processes [${processes:-None}]"
    fi
}

# Collect AMD ROCm telemetry using rocm-smi, amd-smi, or sysfs fallback
get_amd_metrics() {
    if command -v rocm-smi &>/dev/null; then
        local stats processes
        # Extract VRAM% and GPU% usage
        stats=$(rocm-smi --showuse --showmemuse --csv 2>/dev/null | grep -v "device" | tr '\n' ' ; ')
        # Extract running KFD processes and VRAM allocations
        processes=$(rocm-smi --showpids --csv 2>/dev/null | grep -v "PID" | awk -F',' '{print "PID: "$1", Name: "$2", VRAM: "$4" B"}' | tr '\n' ' | ')
        echo "AMD (ROCm): Stats [${stats:-N/A}] Processes [${processes:-None}]"
    elif command -v amd-smi &>/dev/null; then
        local stats processes
        stats=$(amd-smi metric --vram --csv 2>/dev/null | tail -n +2 | tr '\n' ' ; ')
        processes=$(amd-smi process --csv 2>/dev/null | tail -n +2 | tr '\n' ' | ')
        echo "AMD (AMD-SMI): Stats [${stats:-N/A}] Processes [${processes:-None}]"
    elif [[ -d /sys/class/drm ]]; then
        # Fallback to sysfs for basic VRAM accounting if CLI utilities are missing
        local sysfs_stats=""
        for card in /sys/class/drm/card*/device/mem_info_vram_used; do
            if [[ -f "$card" ]]; then
                local used total card_name
                card_name=$(echo "$card" | cut -d'/' -f5)
                used=$(($(cat "$card") / 1024 / 1024))
                total=$(($(cat "${card%_used}_total") / 1024 / 1024))
                sysfs_stats+="${card_name}: ${used}MB / ${total}MB ; "
            fi
        done
        if [[ -n "$sysfs_stats" ]]; then
            echo "AMD (Sysfs): Stats [${sysfs_stats}] Processes [N/A]"
        fi
    fi
}

while true; do
    rotate_logs
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    NV_METRICS=$(get_nvidia_metrics)
    AMD_METRICS=$(get_amd_metrics)

    if [[ -n "${NV_METRICS}" || -n "${AMD_METRICS}" ]]; then
        echo "${TIMESTAMP} | ${NV_METRICS} ${AMD_METRICS}" >> "${LOG_FILE}"
    else
        echo "${TIMESTAMP} | No GPU telemetry tools detected (nvidia-smi / rocm-smi / sysfs missing)." >> "${LOG_FILE}"
    fi

    # Sync to disk immediately to survive sudden lockups/power-offs
    sync

    sleep 5
done
