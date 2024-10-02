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

# Récupérer les paramètres passés par le script principal
DOMAIN="$1"
SERVICE_NAME="$2"
FQDN="$SERVICE_NAME.$DOMAIN"

# Définir le chemin de base à partir de l'endroit où le script est exécuté
BASE_DIR=$(pwd)

# Liste des fichiers et dossiers à vérifier (en fonction des variables)
files_and_dirs=(
    "/root/Docker/applications/nginx/configuration/sites/$DOMAIN/$SERVICE_NAME.conf"
)

# Dossier des logs du service
LOG_DIR="/root/Docker/applications/nginx/logs/$DOMAIN/$SERVICE_NAME"

# Vérification et création du dossier de logs
create_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "${YELLOW}Le dossier $dir n'existe pas. Création...${RESET}"
        mkdir -p "$dir"
        if [ $? -ne 0 ]; then
            echo "${RED}Erreur: Échec de la création du dossier $dir${RESET}"
            exit 1
        fi
        echo "${GREEN}Dossier $dir créé avec succès.${RESET}"
    else
        echo "${VIOLET}Le dossier $dir existe déjà.${RESET}"
    fi
}

# Vérification du dossier de logs
create_directory "$LOG_DIR"

# Vérification des fichiers access.log et error.log dans le dossier de logs
log_files=("access.log" "error.log")

for log_file in "${log_files[@]}"; do
    log_path="$LOG_DIR/$log_file"
    if [ ! -f "$log_path" ]; then
        echo "${YELLOW}Le fichier $log_file n'existe pas. Création...${RESET}"
        touch "$log_path"
        if [ $? -ne 0 ]; then
            echo "${RED}Erreur: Échec de la création du fichier $log_file${RESET}"
            exit 1
        fi
        echo "${GREEN}Fichier $log_file créé avec succès dans $LOG_DIR.${RESET}"
    else
        echo "${VIOLET}Le fichier $log_path existe déjà.${RESET}"
    fi
done

# Demander à l'utilisateur s'il veut changer le propriétaire des fichiers de logs
read -p "${YELLOW}Voulez-vous appliquer 'chown -R 1000:1000' aux fichiers de logs ? (y/n): ${RESET}" log_chown_choice
if [[ "$log_chown_choice" == "y" || "$log_chown_choice" == "Y" ]]; then
    for log_file in "${log_files[@]}"; do
        chown 1000:1000 "$LOG_DIR/$log_file"
        if [ $? -ne 0 ]; then
            echo "${RED}Erreur: Échec de l'application de 'chown' sur $LOG_DIR/$log_file${RESET}"
            exit 1
        fi
        echo "${GREEN}Permissions 'chown 1000:1000' appliquées sur $LOG_DIR/$log_file avec succès.${RESET}"
    done
else
    echo "${BLUE}Les permissions des fichiers de logs n'ont pas été modifiées.${RESET}"
fi

# Vérification des dossiers Docker/pki/certs, Docker/pki/csr, Docker/pki/private
pki_dirs=(
    "/root/Docker/pki/certs/$FQDN"
    "/root/Docker/pki/csr/$FQDN"
    "/root/Docker/pki/private/$FQDN"
)

# Vérification et création des dossiers PKI
for pki_dir in "${pki_dirs[@]}"; do
    create_directory "$pki_dir"
done

# Demander à l'utilisateur s'il veut changer les permissions sur les dossiers créés
read -p "${YELLOW}Voulez-vous appliquer 'chown -R 1000:1000' aux dossiers créés ? (y/n): ${RESET}" chown_choice
if [[ "$chown_choice" == "y" || "$chown_choice" == "Y" ]]; then
    for dir in "${pki_dirs[@]}"; do
        chown -R 1000:1000 "$dir"
        if [ $? -ne 0 ]; then
            echo "${RED}Erreur: Échec de l'application de 'chown' sur $dir${RESET}"
            exit 1
        fi
        echo "${GREEN}Permissions 'chown -R 1000:1000' appliquées sur $dir avec succès.${RESET}"
    done
else
    echo "${BLUE}Les permissions n'ont pas été modifiées.${RESET}"
fi

# Vérification du fichier .conf
for item in "${files_and_dirs[@]}"; do
    if [ ! -e "$item" ]; then
        echo "${YELLOW}Le fichier $item n'existe pas. Création...${RESET}"
        touch "$item"
        if [ $? -ne 0 ]; then
            echo "${RED}Erreur: Échec de la création du fichier $item${RESET}"
            exit 1
        fi
        echo "${GREEN}Fichier $item créé avec succès.${RESET}"
    else
        echo "${VIOLET}$item existe déjà.${RESET}"
    fi
done

########################################## RETOUR DE STATUT ##########################################

# Si toutes les opérations se sont bien passées, retourner "true"
echo "${GREEN}Tous les fichiers et dossiers sont présents ou ont été créés avec succès.${RESET}"
echo "true"
exit 0
