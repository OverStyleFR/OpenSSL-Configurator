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

# Variables dynamiques pour le domaine et les fichiers/dossiers spécifiques
DOMAIN="int.ovst.fr"
SERVICE_NAME="gitlab" # Nom du service qui change selon le script principal
FQDN="$SERVICE_NAME.$DOMAIN" # Utilisé pour le nom des certificats

# Définir le chemin de base à partir de l'endroit où le script est exécuté
BASE_DIR=$(pwd)

# Liste des fichiers et dossiers à vérifier (en fonction des variables)
files_and_dirs=(
    "/root/Docker/applications/nginx/configuration/sites/$DOMAIN/$SERVICE_NAME.conf"
    "/root/Docker/applications/nginx/logs/$DOMAIN/$SERVICE_NAME"
    "/root/Docker/pki/certs/$FQDN"
    "/root/Docker/pki/csr/$FQDN"
    "/root/Docker/pki/private/$FQDN"
)

# Fonction pour demander à l'utilisateur s'il veut créer un fichier ou dossier
create_file_or_dir() {
    read -p "${YELLOW}Le fichier ou dossier $1 n'existe pas. Voulez-vous le créer ? (y/n): ${RESET}" choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        # Vérifie s'il s'agit d'un fichier ou d'un dossier (basé sur la présence d'une extension)
        if [[ "$1" == *.* ]]; then
            touch "$1"  # Créer un fichier
            if [ $? -ne 0 ]; then
                echo "${RED}Erreur: Échec de la création du fichier $1${RESET}"
                exit 1
            fi
            echo "${GREEN}Fichier $1 créé avec succès.${RESET}"
        else
            mkdir -p "$1"  # Créer un dossier
            if [ $? -ne 0 ]; then
                echo "${RED}Erreur: Échec de la création du dossier $1${RESET}"
                exit 1
            fi
            echo "${GREEN}Dossier $1 créé avec succès.${RESET}"
        fi
    else
        echo "${BLUE}Le fichier ou dossier $1 n'a pas été créé.${RESET}"
    fi
}

# Vérification de chaque fichier ou dossier
for item in "${files_and_dirs[@]}"; do
    if [ ! -e "$item" ]; then
        create_file_or_dir "$item"
    else
        echo "${VIOLET}$item existe déjà.${RESET}"
    fi
done

########################################## RETOUR DE STATUT ##########################################

# Si toutes les opérations se sont bien passées, retourner "true"
echo "${GREEN}Tous les fichiers et dossiers sont présents ou ont été créés avec succès.${RESET}"
echo "true"
exit 0
