#!/usr/bin/env python3
"""
Script d'automatisation et d'analyse de répertoires sous Linux
Auteur: Admin Système
Description: Analyse un répertoire et produit un rapport détaillé
"""

import os
import sys
import argparse
from pathlib import Path
from datetime import datetime


class DirectoryAnalyzer:
    """Classe pour analyser un répertoire système"""
    
    def __init__(self, directory_path):
        """
        Initialise l'analyseur avec le chemin du répertoire
        
        Args:
            directory_path (str): Chemin du répertoire à analyser
        """
        self.directory_path = Path(directory_path)
        self.total_files = 0
        self.total_directories = 0
        self.total_size = 0
        self.file_types = {}
        self.largest_files = []
        
    def validate_directory(self):
        """
        Vérifie que le répertoire existe et est accessible
        
        Returns:
            bool: True si valide, False sinon
        """
        if not self.directory_path.exists():
            print(f"Erreur: Le répertoire '{self.directory_path}' n'existe pas.")
            return False
            
        if not self.directory_path.is_dir():
            print(f"Erreur: '{self.directory_path}' n'est pas un répertoire.")
            return False
            
        if not os.access(self.directory_path, os.R_OK):
            print(f"Erreur: Pas de permission de lecture sur '{self.directory_path}'.")
            return False
            
        return True
    
    def get_size_readable(self, size_bytes):
        """
        Convertit une taille en octets vers un format lisible
        
        Args:
            size_bytes (int): Taille en octets
            
        Returns:
            str: Taille formatée (ex: "1.5 MB")
        """
        for unit in ['o', 'Ko', 'Mo', 'Go', 'To']:
            if size_bytes < 1024.0:
                return f"{size_bytes:.2f} {unit}"
            size_bytes /= 1024.0
        return f"{size_bytes:.2f} Po"
    
    def analyze_directory(self):
        """
        Analyse le contenu du répertoire de manière récursive
        """
        try:
            for root, dirs, files in os.walk(self.directory_path):
                # Compte les sous-répertoires
                self.total_directories += len(dirs)
                
                # Analyse chaque fichier
                for filename in files:
                    file_path = Path(root) / filename
                    
                    try:
                        # Compte les fichiers
                        self.total_files += 1
                        
                        # Calcule la taille
                        if file_path.is_file() and not file_path.is_symlink():
                            file_size = file_path.stat().st_size
                            self.total_size += file_size
                            
                            # Garde trace des plus gros fichiers
                            self.largest_files.append((str(file_path), file_size))
                            
                            # Analyse les types de fichiers
                            extension = file_path.suffix.lower() or 'sans extension'
                            self.file_types[extension] = self.file_types.get(extension, 0) + 1
                            
                    except (OSError, PermissionError) as e:
                        # Ignore les fichiers inaccessibles
                        continue
                        
        except PermissionError as e:
            print(f"Avertissement: Permissions insuffisantes pour certains fichiers/répertoires")
    
    def get_top_files(self, n=10):
        """
        Retourne les N plus gros fichiers
        
        Args:
            n (int): Nombre de fichiers à retourner
            
        Returns:
            list: Liste des (chemin, taille) des plus gros fichiers
        """
        self.largest_files.sort(key=lambda x: x[1], reverse=True)
        return self.largest_files[:n]
    
    def get_top_extensions(self, n=10):
        """
        Retourne les N extensions les plus fréquentes
        
        Args:
            n (int): Nombre d'extensions à retourner
            
        Returns:
            list: Liste des (extension, count) triée par fréquence
        """
        sorted_types = sorted(self.file_types.items(), key=lambda x: x[1], reverse=True)
        return sorted_types[:n]
    
    def generate_report(self, verbose=False):
        """
        Génère et affiche le rapport d'analyse
        
        Args:
            verbose (bool): Afficher les détails supplémentaires
        """
        print("=" * 70)
        print(" " * 15 + "RAPPORT D'ANALYSE DE REPERTOIRE")
        print("=" * 70)
        print()
        
        # Informations générales
        print(f"Répertoire analysé : {self.directory_path.absolute()}")
        print(f"Date d'analyse     : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()
        
        # Statistiques principales
        print("-" * 70)
        print("STATISTIQUES GENERALES")
        print("-" * 70)
        print(f"Nombre total de fichiers      : {self.total_files:,}")
        print(f"Nombre de sous-répertoires    : {self.total_directories:,}")
        print(f"Taille totale occupée         : {self.get_size_readable(self.total_size)}")
        print(f"                                 ({self.total_size:,} octets)")
        
        if self.total_files > 0:
            avg_size = self.total_size / self.total_files
            print(f"Taille moyenne par fichier    : {self.get_size_readable(avg_size)}")
        
        print()
        
        # Détails supplémentaires en mode verbose
        if verbose:
            # Types de fichiers les plus fréquents
            if self.file_types:
                print("-" * 70)
                print("TYPES DE FICHIERS LES PLUS FREQUENTS")
                print("-" * 70)
                print(f"{'Extension':<20} {'Nombre':<15} {'Pourcentage'}")
                print("-" * 70)
                
                top_extensions = self.get_top_extensions(10)
                for ext, count in top_extensions:
                    percentage = (count / self.total_files) * 100
                    print(f"{ext:<20} {count:<15,} {percentage:>6.2f}%")
                print()
            
            # Plus gros fichiers
            top_files = self.get_top_files(10)
            if top_files:
                print("-" * 70)
                print("LES 10 FICHIERS LES PLUS VOLUMINEUX")
                print("-" * 70)
                print(f"{'Taille':<15} {'Chemin'}")
                print("-" * 70)
                
                for file_path, size in top_files:
                    print(f"{self.get_size_readable(size):<15} {file_path}")
                print()
        
        # Résumé final
        print("-" * 70)
        print("RESUME")
        print("-" * 70)
        
        if self.total_files == 0:
            print("Le répertoire est vide (aucun fichier trouvé).")
        else:
            print(f"Le répertoire contient {self.total_files:,} fichier(s)")
            print(f"répartis dans {self.total_directories:,} sous-répertoire(s)")
            print(f"pour un total de {self.get_size_readable(self.total_size)}.")
        
        print("=" * 70)


def main():
    """
    Fonction principale du script
    """
    # Configuration du parser d'arguments
    parser = argparse.ArgumentParser(
        description="Analyse un répertoire et produit un rapport détaillé.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemples d'utilisation:
  %(prog)s /home/user/Documents
  %(prog)s /var/log -v
  %(prog)s . --verbose
        """
    )
    
    parser.add_argument(
        'directory',
        help='Chemin du répertoire à analyser'
    )
    
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Afficher les détails supplémentaires (types de fichiers, plus gros fichiers)'
    )
    
    # Parse les arguments
    args = parser.parse_args()
    
    # Création de l'analyseur
    analyzer = DirectoryAnalyzer(args.directory)
    
    # Validation du répertoire
    if not analyzer.validate_directory():
        sys.exit(1)
    
    # Analyse du répertoire
    print(f"Analyse du répertoire en cours...")
    analyzer.analyze_directory()
    print()
    
    # Génération du rapport
    analyzer.generate_report(verbose=args.verbose)
    
    sys.exit(0)


if __name__ == "__main__":
    main()