Monitoring Simple d'un Serveur
Surveillance automatique des ressources système (CPU, RAM, Disque) avec logs et alertes.

---

## 📁 Structure du projet

```
server-monitor/
├── scripts/
│   ├── monitor.sh       ← Script principal de surveillance
│   ├── report.sh        ← Afficher le rapport des logs
│   └── setup_cron.sh    ← Configurer la planification automatique
├── logs/
│   ├── monitor_YYYY-MM.log  ← Logs mensuels (auto-généré)
│   └── alerts.log           ← Alertes déclenchées (auto-généré)
└── README.md
```

---

## 🚀 Utilisation

### 1. Rendre les scripts exécutables
```bash
chmod +x scripts/*.sh
```

### 2. Lancer une vérification manuelle
```bash
./scripts/monitor.sh
```

### 3. Consulter le rapport des logs
```bash
./scripts/report.sh
```

### 4. Configurer la planification automatique (cron)
```bash
./scripts/setup_cron.sh
```

---

## 📊 Ce que le script surveille

| Métrique | Seuil d'alerte | Description |
|----------|---------------|-------------|
| CPU      | > 80%         | Charge processeur |
| RAM      | > 80%         | Mémoire utilisée |
| Disque   | > 90%         | Espace disque `/` |

---

## 📄 Format des logs

Chaque entrée dans `logs/monitor_YYYY-MM.log` :
```
2025-04-19 14:30:00|CPU:23%|RAM:45%|DISK:67%|LOAD: 0.5, 0.4, 0.3
```

---

## ⏰ Planification cron recommandée

```cron
# Toutes les 5 minutes
*/5 * * * * /chemin/vers/scripts/monitor.sh

# Rapport quotidien à 8h
0 8 * * * /chemin/vers/scripts/report.sh
```

Vérifier les crons actifs :
```bash
crontab -l
```

