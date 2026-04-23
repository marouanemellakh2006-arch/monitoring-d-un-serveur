#!/bin/bash
# ==============================================
# setup_cron.sh - Configurer la planification
# ==============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MONITOR_SCRIPT="$SCRIPT_DIR/monitor.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════╗"
echo "║         ⏰ CONFIGURATION CRON                    ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# Rendre le script exécutable
chmod +x "$MONITOR_SCRIPT"
chmod +x "$SCRIPT_DIR/report.sh"

echo -e " ${BLUE}Script principal:${NC} $MONITOR_SCRIPT"
echo ""
echo -e " ${BLUE}Choisissez la fréquence de monitoring:${NC}"
echo "  1) Toutes les 5 minutes  (recommandé)"
echo "  2) Toutes les 15 minutes"
echo "  3) Toutes les heures"
echo "  4) Afficher le cron actuel"
echo "  5) Supprimer le cron"
echo ""
read -p " Votre choix [1-5]: " choice

case $choice in
    1)
        CRON_LINE="*/5 * * * * $MONITOR_SCRIPT >> /dev/null 2>&1"
        FREQ="toutes les 5 minutes"
        ;;
    2)
        CRON_LINE="*/15 * * * * $MONITOR_SCRIPT >> /dev/null 2>&1"
        FREQ="toutes les 15 minutes"
        ;;
    3)
        CRON_LINE="0 * * * * $MONITOR_SCRIPT >> /dev/null 2>&1"
        FREQ="toutes les heures"
        ;;
    4)
        echo ""
        echo -e " ${BLUE}Cron actuel:${NC}"
        crontab -l 2>/dev/null || echo "  (aucun cron configuré)"
        exit 0
        ;;
    5)
        crontab -l 2>/dev/null | grep -v "$MONITOR_SCRIPT" | crontab -
        echo -e " ${GREEN}✅ Cron supprimé.${NC}"
        exit 0
        ;;
    *)
        echo -e " ${YELLOW}Choix invalide.${NC}"
        exit 1
        ;;
esac

# Ajouter le cron sans dupliquer
(crontab -l 2>/dev/null | grep -v "$MONITOR_SCRIPT"; echo "$CRON_LINE") | crontab -

echo ""
echo -e " ${GREEN}✅ Cron configuré: monitoring $FREQ${NC}"
echo -e " ${BLUE}Ligne ajoutée:${NC} $CRON_LINE"
echo ""
echo -e " Pour vérifier: ${YELLOW}crontab -l${NC}"
echo ""
