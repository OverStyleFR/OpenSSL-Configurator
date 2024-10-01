#!/bin/bash

# Définir les couleurs
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
VIOLET=$(tput setaf 5)
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)
########################################## INITIALISATION ROOT ##########################################

# Vérifier si l'utilisateur est root
if [[ $EUID -ne 0 ]]; then
   echo "${RED}${BOLD}Ce script doit être exécuté en tant que root${RESET}" 
   # Demander le mot de passe
   sudo "$0" "$@"
   exit 1
fi

# Le reste du script ici

# Définition de la variable pour le domaine
DOMAIN="int.ovst.fr"

# Définir le chemin de base à partir de l'endroit où le script est exécuté
BASE_DIR=$(pwd)

# Définition des dossiers à vérifier (à partir du répertoire courant)
directories=(
    "$BASE_DIR/Docker/applications/nginx/configuration/sites/$DOMAIN"
    "$BASE_DIR/Docker/applications/nginx/logs/$DOMAIN"
    "$BASE_DIR/Docker/pki/certs"
    "$BASE_DIR/Docker/pki/csr"
    "$BASE_DIR/Docker/pki/private"
)

# Fonction pour demander à l'utilisateur s'il veut créer un dossier
create_directory() {
    read -p "Le dossier $1 n'existe pas. Voulez-vous le créer ? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        mkdir -p "$1"
        echo "Dossier $1 créé avec succès."
    else
        echo "Le dossier $1 n'a pas été créé."
    fi
}

# Vérification de chaque dossier
for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        create_directory "$dir"
    else
        echo "Le dossier $dir existe déjà."
    fi
done