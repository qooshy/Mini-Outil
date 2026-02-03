#!/bin/bash

################################################################################
# Script d'audit de sécurité des fichiers et d'automatisation des correctifs
# Auteur: Admin Système
# Date: $(date +%Y-%m-%d)
################################################################################

# Variables globales
LOG_FILE="/var/log/security_audit.log"
FIX_MODE=0
VERBOSE=0

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

################################################################################
# LISTE DE CONTROLE DES FICHIERS SENSIBLES
################################################################################
# Format: chemin|permissions|propriétaire|groupe
declare -a FILE_CHECKLIST=(
    "/etc/passwd|644|root|root"
    "/etc/shadow|640|root|shadow"
    "/etc/group|644|root|root"
    "/etc/gshadow|640|root|shadow"
    "/etc/ssh/sshd_config|600|root|root"
    "/etc/sudoers|440|root|root"
    "/root/.ssh/authorized_keys|600|root|root"
    "/etc/crontab|644|root|root"
    "/etc/fstab|644|root|root"
    "/boot/grub/grub.cfg|600|root|root"
)

################################################################################
# Fonction: afficher_aide
# Description: Affiche l'aide du script
################################################################################
afficher_aide() {
    cat << EOF
Usage: $0 [OPTIONS]

Script d'audit de sécurité des fichiers système

OPTIONS:
    -f, --fix       Active le mode correction automatique (nécessite root)
    -v, --verbose   Mode verbeux
    -h, --help      Affiche cette aide

EXEMPLES:
    $0                  # Audit simple sans correction
    $0 -v               # Audit avec affichage détaillé
    sudo $0 -f          # Audit avec correction automatique
    sudo $0 -f -v       # Audit verbeux avec correction

EOF
}

################################################################################
# Fonction: log_issue
# Description: Journalise les problèmes détectés
# Paramètres:
#   $1 - Type de problème
#   $2 - Fichier concerné
#   $3 - Valeur actuelle
#   $4 - Valeur attendue
################################################################################
log_issue() {
    local type_probleme="$1"
    local fichier="$2"
    local valeur_actuelle="$3"
    local valeur_attendue="$4"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local message="[$timestamp] ANOMALIE DETECTEE - Type: $type_probleme | Fichier: $fichier | Actuel: $valeur_actuelle | Attendu: $valeur_attendue"
    
    echo "$message" >> "$LOG_FILE"
    
    if [ $VERBOSE -eq 1 ]; then
        echo -e "${RED}[!]${NC} $message"
    fi
}

################################################################################
# Fonction: check_permissions
# Description: Vérifie les permissions d'un fichier
# Paramètres:
#   $1 - Chemin du fichier
#   $2 - Permissions attendues (format octal)
# Retour: 0 si OK, 1 si anomalie
################################################################################
check_permissions() {
    local file_path="$1"
    local expected_perms="$2"
    
    if [ ! -e "$file_path" ]; then
        log_issue "FICHIER_INEXISTANT" "$file_path" "N/A" "Devrait exister"
        return 1
    fi
    
    local current_perms=$(stat -c "%a" "$file_path")
    
    if [ "$current_perms" != "$expected_perms" ]; then
        log_issue "PERMISSIONS" "$file_path" "$current_perms" "$expected_perms"
        return 1
    fi
    
    return 0
}

################################################################################
# Fonction: check_ownership
# Description: Vérifie le propriétaire et le groupe d'un fichier
# Paramètres:
#   $1 - Chemin du fichier
#   $2 - Propriétaire attendu
#   $3 - Groupe attendu
# Retour: 0 si OK, 1 si anomalie
################################################################################
check_ownership() {
    local file_path="$1"
    local expected_owner="$2"
    local expected_group="$3"
    local has_issue=0
    
    if [ ! -e "$file_path" ]; then
        return 1
    fi
    
    local current_owner=$(stat -c "%U" "$file_path")
    local current_group=$(stat -c "%G" "$file_path")
    
    if [ "$current_owner" != "$expected_owner" ]; then
        log_issue "PROPRIETAIRE" "$file_path" "$current_owner" "$expected_owner"
        has_issue=1
    fi
    
    if [ "$current_group" != "$expected_group" ]; then
        log_issue "GROUPE" "$file_path" "$current_group" "$expected_group"
        has_issue=1
    fi
    
    return $has_issue
}

################################################################################
# Fonction: check_immutability
# Description: Vérifie si un fichier critique possède l'attribut immuable
# Paramètres:
#   $1 - Chemin du fichier
################################################################################
check_immutability() {
    local file_path="$1"
    
    if [ ! -e "$file_path" ]; then
        return 1
    fi
    
    local attrs=$(lsattr "$file_path" 2>/dev/null | awk '{print $1}')
    
    if [[ $attrs == *"i"* ]]; then
        if [ $VERBOSE -eq 1 ]; then
            echo -e "${GREEN}[✓]${NC} $file_path est immuable"
        fi
        return 0
    else
        if [ $VERBOSE -eq 1 ]; then
            echo -e "${YELLOW}[i]${NC} $file_path n'est pas immuable"
        fi
        return 1
    fi
}

################################################################################
# Fonction: check_passwd_content
# Description: Vérifie que /etc/passwd ne contient pas de mots de passe
################################################################################
check_passwd_content() {
    local passwd_file="/etc/passwd"
    
    if [ ! -e "$passwd_file" ]; then
        return 1
    fi
    
    # Vérifie que le deuxième champ est bien 'x' pour chaque ligne
    while IFS=: read -r username password rest; do
        if [ -n "$username" ] && [ "$password" != "x" ] && [ "$password" != "*" ]; then
            log_issue "CONTENU_PASSWD" "$passwd_file" "Mot de passe visible pour $username" "x (shadow password)"
            echo -e "${RED}[!]${NC} ALERTE CRITIQUE: Mot de passe visible dans /etc/passwd pour l'utilisateur $username"
            return 1
        fi
    done < "$passwd_file"
    
    if [ $VERBOSE -eq 1 ]; then
        echo -e "${GREEN}[✓]${NC} Aucun mot de passe visible dans /etc/passwd"
    fi
    
    return 0
}

################################################################################
# Fonction: fix_permissions
# Description: Corrige les permissions d'un fichier
# Paramètres:
#   $1 - Chemin du fichier
#   $2 - Permissions attendues
#   $3 - Propriétaire attendu
#   $4 - Groupe attendu
################################################################################
fix_permissions() {
    local file_path="$1"
    local expected_perms="$2"
    local expected_owner="$3"
    local expected_group="$4"
    
    if [ ! -e "$file_path" ]; then
        echo -e "${RED}[!]${NC} Impossible de corriger $file_path: fichier inexistant"
        return 1
    fi
    
    echo -e "${YELLOW}[*]${NC} Correction de $file_path..."
    
    # Correction des permissions
    if ! chmod "$expected_perms" "$file_path" 2>/dev/null; then
        echo -e "${RED}[!]${NC} Erreur lors de la correction des permissions de $file_path"
        return 1
    fi
    
    # Correction du propriétaire et du groupe
    if ! chown "$expected_owner:$expected_group" "$file_path" 2>/dev/null; then
        echo -e "${RED}[!]${NC} Erreur lors de la correction du propriétaire de $file_path"
        return 1
    fi
    
    echo -e "${GREEN}[✓]${NC} $file_path corrigé avec succès"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - CORRECTION APPLIQUEE: $file_path (perms: $expected_perms, owner: $expected_owner:$expected_group)" >> "$LOG_FILE"
    
    return 0
}

################################################################################
# Fonction: verify_root
# Description: Vérifie que le script est exécuté en tant que root
################################################################################
verify_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[!]${NC} Ce script doit être exécuté en tant que root pour le mode correction"
        echo "Veuillez utiliser: sudo $0 -f"
        exit 1
    fi
}

################################################################################
# Fonction: initialize_log
# Description: Initialise le fichier de log
################################################################################
initialize_log() {
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE" 2>/dev/null || {
            echo -e "${RED}[!]${NC} Impossible de créer le fichier de log: $LOG_FILE"
            LOG_FILE="/tmp/security_audit.log"
            echo -e "${YELLOW}[i]${NC} Utilisation du fichier de log alternatif: $LOG_FILE"
            touch "$LOG_FILE"
        }
    fi
    
    echo "========================================" >> "$LOG_FILE"
    echo "Nouvel audit lancé le $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"
}

################################################################################
# Fonction: main
# Description: Fonction principale du script
################################################################################
main() {
    local total_files=0
    local files_with_issues=0
    local files_fixed=0
    
    echo "========================================="
    echo "  AUDIT DE SECURITE DES FICHIERS SYSTEME"
    echo "========================================="
    echo ""
    
    initialize_log
    
    # Vérification spéciale du contenu de /etc/passwd
    echo "Vérification du contenu de /etc/passwd..."
    check_passwd_content
    echo ""
    
    # Parcours de la liste de contrôle
    for entry in "${FILE_CHECKLIST[@]}"; do
        IFS='|' read -r file_path expected_perms expected_owner expected_group <<< "$entry"
        
        ((total_files++))
        
        echo "Audit de: $file_path"
        
        local has_issue=0
        
        # Vérification des permissions
        if ! check_permissions "$file_path" "$expected_perms"; then
            has_issue=1
        fi
        
        # Vérification du propriétaire et du groupe
        if ! check_ownership "$file_path" "$expected_owner" "$expected_group"; then
            has_issue=1
        fi
        
        # Vérification de l'immutabilité (informatif uniquement)
        check_immutability "$file_path"
        
        # Correction si nécessaire
        if [ $has_issue -eq 1 ]; then
            ((files_with_issues++))
            
            if [ $FIX_MODE -eq 1 ]; then
                if fix_permissions "$file_path" "$expected_perms" "$expected_owner" "$expected_group"; then
                    ((files_fixed++))
                fi
            else
                echo -e "${YELLOW}[i]${NC} Anomalie détectée (utilisez -f pour corriger)"
            fi
        else
            if [ $VERBOSE -eq 1 ]; then
                echo -e "${GREEN}[✓]${NC} Aucune anomalie"
            fi
        fi
        
        echo ""
    done
    
    # Résumé
    echo "========================================="
    echo "  RESUME DE L'AUDIT"
    echo "========================================="
    echo "Fichiers audités: $total_files"
    echo "Fichiers avec anomalies: $files_with_issues"
    
    if [ $FIX_MODE -eq 1 ]; then
        echo "Fichiers corrigés: $files_fixed"
    fi
    
    echo ""
    echo "Log détaillé disponible dans: $LOG_FILE"
    echo ""
    
    if [ $files_with_issues -gt 0 ] && [ $FIX_MODE -eq 0 ]; then
        echo -e "${YELLOW}[i]${NC} Des anomalies ont été détectées. Utilisez 'sudo $0 -f' pour les corriger automatiquement."
    fi
}

################################################################################
# ANALYSE DES ARGUMENTS
################################################################################
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--fix)
            FIX_MODE=1
            verify_root
            shift
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -h|--help)
            afficher_aide
            exit 0
            ;;
        *)
            echo "Option inconnue: $1"
            afficher_aide
            exit 1
            ;;
    esac
done

################################################################################
# EXECUTION DU SCRIPT
################################################################################
main

exit 0