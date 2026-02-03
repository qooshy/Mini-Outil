#!/bin/bash
################################################################################
# Script d'installation du Mini-Projet d'Administration Système
################################################################################

echo "=========================================="
echo "Installation du Mini-Projet"
echo "=========================================="
echo ""

# Vérification de Python
echo "[1/4] Vérification de Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo "  ✓ Python $PYTHON_VERSION installé"
else
    echo "  ✗ Python 3 non trouvé"
    echo ""
    echo "Installation de Python requise:"
    echo "  Ubuntu/Debian: sudo apt install python3"
    echo "  CentOS/RHEL:   sudo yum install python3"
    exit 1
fi

# Vérification de Bash
echo ""
echo "[2/4] Vérification de Bash..."
if command -v bash &> /dev/null; then
    BASH_VERSION=$(bash --version | head -n1 | awk '{print $4}')
    echo "  ✓ Bash $BASH_VERSION installé"
else
    echo "  ✗ Bash non trouvé (requis pour security_audit.sh)"
    exit 1
fi

# Conversion des fins de ligne et permissions
echo ""
echo "[3/4] Configuration des scripts..."

# Conversion des fins de ligne Windows vers Unix
if [ -f "security_audit.sh" ]; then
    sed -i 's/\r$//' security_audit.sh
    chmod +x security_audit.sh
    echo "  ✓ security_audit.sh configuré"
fi

if [ -f "directory_analyzer.py" ]; then
    sed -i 's/\r$//' directory_analyzer.py
    chmod +x directory_analyzer.py
    echo "  ✓ directory_analyzer.py configuré"
fi

# Vérification des dépendances Python
echo ""
echo "[4/4] Vérification des dépendances Python..."
echo "  ✓ Aucune dépendance externe requise"
echo "  ℹ Les modules standards Python sont utilisés"

# Résumé
echo ""
echo "=========================================="
echo "Installation terminée avec succès!"
echo "=========================================="
echo ""
echo "Scripts disponibles:"
echo ""
echo "  1. Audit de sécurité (Bash):"
echo "     ./security_audit.sh"
echo "     sudo ./security_audit.sh -f"
echo ""
echo "  2. Analyse de répertoires (Python):"
echo "     ./directory_analyzer.py /chemin/repertoire"
echo "     ./directory_analyzer.py /chemin/repertoire -v"
echo ""
echo "Pour plus d'informations, consultez README.md"
echo ""