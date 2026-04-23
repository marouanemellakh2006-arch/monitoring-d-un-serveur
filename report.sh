#!/bin/bash
# ==============================================
# report.sh - Afficher le rapport des logs
# ==============================================

LOG_DIR="$(dirname "$0")/../logs"
LOG_FILE="$LOG_DIR/monitor_$(date +%Y-%m).log"
ALERT_FILE="$LOG_DIR/alerts.log"

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════╗"
echo "║            📊 RAPPORT DE MONITORING              ║"
echo "║              $(date '+%B %Y')                      ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

if [ ! -f "$LOG_FILE" ]; then
    echo -e "${YELLOW}Aucun log trouvé pour ce mois. Lancez d'abord monitor.sh${NC}"
    exit 1
fi

# Nombre total d'entrées
total=$(wc -l < "$LOG_FILE")
echo -e " 📈 ${BLUE}Total de mesures enregistrées:${NC} $total"
echo ""

# Dernières 5 entrées
echo -e " ${BLUE}━━━ Dernières mesures ━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
tail -5 "$LOG_FILE" | while IFS='|' read -r timestamp cpu ram disk load; do
    echo -e "  🕐 $timestamp"
    echo -e "     $cpu  $ram  $disk"
    echo ""
done

# Alertes récentes
echo -e " ${BLUE}━━━ Alertes récentes ━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
if [ -f "$ALERT_FILE" ] && [ -s "$ALERT_FILE" ]; then
    tail -5 "$ALERT_FILE" | while read -r line; do
        echo -e "  ${RED}⚠️  $line${NC}"
    done
else
    echo -e "  ${GREEN}✅ Aucune alerte enregistrée${NC}"
fi

echo ""
echo -e " ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " 📁 Fichier log: $LOG_FILE"
echo ""
