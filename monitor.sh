#!/bin/bash
# ==============================================
# monitor.sh - Script de surveillance système
# Projet 4 : Monitoring simple d'un serveur
# ==============================================

# --- Configuration ---
LOG_DIR="$(dirname "$0")/../logs"
LOG_FILE="$LOG_DIR/monitor_$(date +%Y-%m).log"
ALERT_FILE="$LOG_DIR/alerts.log"
CPU_THRESHOLD=80    # Alerte si CPU > 80%
RAM_THRESHOLD=80    # Alerte si RAM > 80%
DISK_THRESHOLD=90   # Alerte si Disque > 90%

# --- Couleurs pour terminal ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Créer le dossier logs si nécessaire ---
mkdir -p "$LOG_DIR"

# --- Fonctions ---

get_timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

get_cpu_usage() {
    # Mesure CPU sur 1 seconde
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | sed 's/%id,//' | tr -d ' ')
    # Si top ne retourne pas le bon format, fallback
    if [ -z "$cpu_idle" ]; then
        cpu_idle=$(vmstat 1 1 | tail -1 | awk '{print $15}')
    fi
    echo $(echo "100 - $cpu_idle" | bc 2>/dev/null || echo "N/A")
}

get_ram_usage() {
    # Utilisation RAM en pourcentage
    ram_info=$(free | grep Mem)
    total=$(echo $ram_info | awk '{print $2}')
    used=$(echo $ram_info | awk '{print $3}')
    if [ "$total" -gt 0 ]; then
        echo $(( used * 100 / total ))
    else
        echo "N/A"
    fi
}

get_ram_details() {
    free -h | grep Mem | awk '{printf "Total: %s | Utilisée: %s | Libre: %s", $2, $3, $4}'
}

get_disk_usage() {
    df -h / | tail -1 | awk '{print $5}' | tr -d '%'
}

get_disk_details() {
    df -h / | tail -1 | awk '{printf "Total: %s | Utilisé: %s | Libre: %s", $2, $3, $4}'
}

get_load_average() {
    uptime | awk -F'load average:' '{print $2}' | xargs
}

get_uptime() {
    uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}'
}

check_threshold() {
    local value=$1
    local threshold=$2
    local label=$3

    if [ "$value" != "N/A" ] && [ "$value" -ge "$threshold" ] 2>/dev/null; then
        local msg="[ALERTE] $(get_timestamp) - $label: ${value}% dépasse le seuil de ${threshold}%"
        echo "$msg" >> "$ALERT_FILE"
        echo -e "${RED}⚠️  ALERTE: $label = ${value}%${NC}"
        return 1
    fi
    return 0
}

log_entry() {
    local cpu=$1
    local ram=$2
    local disk=$3
    local load=$4

    echo "$(get_timestamp)|CPU:${cpu}%|RAM:${ram}%|DISK:${disk}%|LOAD:${load}" >> "$LOG_FILE"
}

print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║       🖥️  MONITEUR SYSTÈME - $(date '+%d/%m/%Y %H:%M')      ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_metric() {
    local label=$1
    local value=$2
    local threshold=$3
    local details=$4

    if [ "$value" != "N/A" ] && [ "$value" -ge "$threshold" ] 2>/dev/null; then
        color=$RED
        icon="🔴"
    elif [ "$value" != "N/A" ] && [ "$value" -ge $(( threshold * 70 / 100 )) ] 2>/dev/null; then
        color=$YELLOW
        icon="🟡"
    else
        color=$GREEN
        icon="🟢"
    fi

    echo -e " $icon ${BLUE}$label:${NC} ${color}${value}%${NC}"
    [ -n "$details" ] && echo -e "    └─ $details"
}

# --- Script Principal ---

print_header

echo -e " 🕐 ${BLUE}Uptime:${NC} $(get_uptime)"
echo -e " ⚡ ${BLUE}Load Average:${NC} $(get_load_average)"
echo ""
echo -e " ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Collecter les métriques
CPU=$(get_cpu_usage)
RAM=$(get_ram_usage)
DISK=$(get_disk_usage)
LOAD=$(get_load_average)

# Afficher les métriques
print_metric "CPU    " "$CPU"  "$CPU_THRESHOLD"  ""
print_metric "RAM    " "$RAM"  "$RAM_THRESHOLD"  "$(get_ram_details)"
print_metric "Disque " "$DISK" "$DISK_THRESHOLD" "$(get_disk_details)"

echo ""
echo -e " ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Vérifier les seuils et créer alertes
check_threshold "$CPU"  "$CPU_THRESHOLD"  "CPU"
check_threshold "$RAM"  "$RAM_THRESHOLD"  "RAM"
check_threshold "$DISK" "$DISK_THRESHOLD" "Disque"

# Enregistrer dans le log
log_entry "$CPU" "$RAM" "$DISK" "$LOAD"

echo -e " 📄 ${GREEN}Log enregistré:${NC} $LOG_FILE"
echo -e " ⏰ ${GREEN}Prochain rapport:${NC} dans 5 minutes (si cron actif)"
echo ""
