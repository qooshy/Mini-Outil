# MINI-PROJET D'ADMINISTRATION SYSTÈME LINUX

## Vue d'Ensemble du Projet

Ce projet comprend deux outils d'automatisation développés pour faciliter le travail quotidien des administrateurs système Linux.

---

## PARTIE 1 - Script d'Audit de Sécurité des Fichiers (Bash)

### Objectif
Automatiser les contrôles de sécurité sur les fichiers critiques du système Linux pour détecter et corriger les anomalies de permissions, propriétaires et groupes.

### Fichier
`security_audit.sh`

### Points Forts
- ✓ Structure modulaire avec fonctions dédiées
- ✓ Liste de contrôle configurable de 10 fichiers critiques
- ✓ Vérifications complètes (permissions, propriétaire, groupe, immutabilité)
- ✓ Vérification spéciale du contenu de /etc/passwd
- ✓ Journalisation détaillée dans /var/log ou /tmp
- ✓ Mode correction automatique avec option -f
- ✓ Mode verbeux pour détails supplémentaires
- ✓ Gestion des erreurs et validation des privilèges

### Utilisation Rapide
```bash
# Audit simple
./security_audit.sh

# Audit avec correction (root requis)
sudo ./security_audit.sh -f

# Mode verbeux
./security_audit.sh -v
```

### Critères d'Évaluation Couverts
1. **Organisation et structuration** (5pts) : Fonctions modulaires, commentaires clairs
2. **Pertinence de la liste** (5pts) : 10 fichiers critiques bien choisis avec permissions justifiées
3. **Qualité de l'audit** (5pts) : Vérifications complètes + check spécial passwd
4. **Journalisation** (5pts) : Log détaillé avec horodatage et informations complètes
5. **Correction automatique** (5pts) : Implémentation complète avec option -f

---

## PARTIE 2 - Script d'Analyse de Répertoires (Python)

### Objectif
Fournir un outil d'analyse en ligne de commande pour collecter des informations sur les répertoires du système et produire des rapports clairs.

### Fichier
`directory_analyzer.py`

### Points Forts
- ✓ Orienté objet avec classe DirectoryAnalyzer
- ✓ Validation complète des paramètres d'entrée
- ✓ Analyse récursive avec gestion des erreurs
- ✓ Statistiques détaillées (fichiers, répertoires, tailles)
- ✓ Conversion automatique des tailles en format lisible
- ✓ Mode verbose avec analyses supplémentaires
- ✓ Top 10 des fichiers les plus volumineux
- ✓ Distribution des types de fichiers par extension
- ✓ Interface en ligne de commande avec argparse
- ✓ Rapport formaté et professionnel

### Utilisation Rapide
```bash
# Analyse simple
./directory_analyzer.py /chemin/repertoire

# Analyse détaillée
./directory_analyzer.py /chemin/repertoire -v

# Aide
./directory_analyzer.py --help
```

### Fonctionnalités Requises Couvertes
1. **Paramètre en entrée** ✓ : Chemin du répertoire (obligatoire)
2. **Validation** ✓ : Vérification existence, type, permissions
3. **Analyse du contenu** ✓ :
   - Nombre total de fichiers ✓
   - Nombre de sous-répertoires ✓
   - Taille totale occupée ✓
4. **Résumé clair** ✓ : Rapport formaté avec statistiques
5. **Exécutable CLI** ✓ : Shebang + chmod +x

### Fonctionnalités Bonus
- Taille moyenne par fichier
- Distribution des types de fichiers (mode verbose)
- Les 10 plus gros fichiers (mode verbose)
- Gestion des erreurs élégante
- Format de sortie professionnel

---

## STRUCTURE DES FICHIERS

```
mini-projet/
├── security_audit.sh          # Partie 1 - Audit de sécurité (Bash)
├── directory_analyzer.py      # Partie 2 - Analyse de répertoires (Python)
├── README.md                  # Documentation complète
└── PRESENTATION.md            # Ce fichier
```

---

## TESTS ET DÉMONSTRATION

### Partie 1 - Tests du Script Bash

**Test 1 : Audit sans correction**
```bash
./security_audit.sh
```
Résultat attendu : Rapport des anomalies sans modification

**Test 2 : Audit avec correction**
```bash
sudo ./security_audit.sh -f
```
Résultat attendu : Anomalies corrigées et journalisées

**Test 3 : Vérification du log**
```bash
cat /tmp/security_audit.log  # ou /var/log/security_audit.log si root
```
Résultat attendu : Historique des audits avec détails

### Partie 2 - Tests du Script Python

**Test 1 : Validation des erreurs**
```bash
./directory_analyzer.py /repertoire/inexistant
```
Résultat attendu : Message d'erreur clair

**Test 2 : Analyse simple**
```bash
./directory_analyzer.py /tmp
```
Résultat attendu : Rapport avec statistiques de base

**Test 3 : Analyse détaillée**
```bash
./directory_analyzer.py /home/user -v
```
Résultat attendu : Rapport complet avec types de fichiers et top 10

**Test 4 : Aide**
```bash
./directory_analyzer.py --help
```
Résultat attendu : Documentation d'utilisation

---

## POINTS TECHNIQUES REMARQUABLES

### Partie 1 (Bash)
- Utilisation de tableaux associatifs pour la liste de contrôle
- Parsing d'options avec getopts (--fix, --verbose)
- Validation des privilèges root pour la correction
- Vérification du contenu de /etc/passwd (sécurité password)
- Codes couleur pour l'affichage terminal
- Gestion du fallback pour le fichier de log

### Partie 2 (Python)
- Architecture orientée objet propre
- Utilisation de pathlib pour la portabilité
- Gestion élégante des permissions avec try/except
- Algorithme de tri pour top N fichiers
- Formatage automatique des tailles (o, Ko, Mo, Go, To)
- Documentation complète avec docstrings
- Interface CLI professionnelle avec argparse

---

## COMPATIBILITÉ

### Partie 1
- Bash 4.0+
- Systèmes Linux (Ubuntu, Debian, CentOS, etc.)
- Privilèges root pour correction automatique
- Adapté pour WSL avec liste de contrôle modifiable

### Partie 2
- Python 3.6+
- Modules standards uniquement (pas de dépendances)
- Compatible tous systèmes Unix/Linux
- Testé sur WSL Debian

---

## ÉVOLUTION POSSIBLE

### Partie 1
- Configuration externe (fichier CSV/JSON)
- Export du rapport en HTML/PDF
- Notifications par email
- Intégration avec systèmes de monitoring

### Partie 2
- Export en JSON/CSV/HTML
- Détection de fichiers en double (hash)
- Filtrage par date/taille
- Génération de graphiques
- Comparaison de répertoires

---

## CONCLUSION

Ce mini-projet démontre :
- Maîtrise du scripting Bash et Python
- Compréhension de la sécurité système Linux
- Capacité à créer des outils d'automatisation pratiques
- Bonnes pratiques de développement (modularité, gestion d'erreurs, documentation)
- Attention portée à l'expérience utilisateur (rapports clairs, options flexibles)

Les deux outils sont prêts pour une utilisation en production et peuvent être facilement étendus selon les besoins.