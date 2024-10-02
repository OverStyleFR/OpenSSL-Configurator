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
    # Demander le mot de passe et relancer le script avec sudo
    sudo "$0" "$@"
    exit 1
fi

# Définition de la variable pour le domaine
DOMAIN="$1"
SERVICE_NAME="$2"
FQDN="$SERVICE_NAME.$DOMAIN"

# Définir le chemin de base à partir du répertoire où le script est exécuté
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
        if [ $? -ne 0 ]; then
            echo "${RED}Erreur: Échec de la création du dossier $1${RESET}"
            exit 1
        fi
        echo "${GREEN}Dossier $1 créé avec succès.${RESET}"
    else
        echo "${YELLOW}Le dossier $1 n'a pas été créé.${RESET}"
    fi
}

# Vérification de chaque dossier
for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        create_directory "$dir"
    else
        echo "${BLUE}Le dossier $dir existe déjà.${RESET}"
    fi
done

########################################## RETOUR DE STATUT ##########################################

# Si toutes les opérations se sont bien passées, retourner "true"
echo "${GREEN}Tous les dossiers sont présents ou ont été créés avec succès.${RESET}"
echo "true"
exit 0