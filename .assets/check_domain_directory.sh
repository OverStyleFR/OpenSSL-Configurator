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

# Ajouter le dossier des logs du service
LOG_DIR="/root/Docker/applications/nginx/logs/$DOMAIN/$SERVICE_NAME"

# Vérification du dossier de logs
if [ -d "$LOG_DIR" ]; then
    echo "${VIOLET}Le dossier $LOG_DIR existe.${RESET}"
else
    read -p "${YELLOW}Le dossier $LOG_DIR n'existe pas. Voulez-vous le créer ? (y/n): ${RESET}" choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        mkdir -p "$LOG_DIR"
        if [ $? -ne 0 ]; then
            echo "${RED}Erreur: Échec de la création du dossier $LOG_DIR${RESET}"
            exit 1
        fi
        echo "${GREEN}Dossier $LOG_DIR créé avec succès.${RESET}"
    else
        echo "${BLUE}Le dossier $LOG_DIR n'a pas été créé.${RESET}"
        exit 1
    fi
fi

# Vérification des fichiers access.log et error.log dans le dossier de logs
log_files=("access.log" "error.log")

for log_file in "${log_files[@]}"; do
    log_path="$LOG_DIR/$log_file"
    if [ -f "$log_path" ]; then
        echo "${VIOLET}Le fichier $log_path existe déjà.${RESET}"
    else
        read -p "${YELLOW}Le fichier $log_file n'existe pas. Voulez-vous le créer ? (y/n): ${RESET}" choice
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            touch "$log_path"
            if [ $? -ne 0 ]; then
                echo "${RED}Erreur: Échec de la création du fichier $log_file${RESET}"
                exit 1
            fi
            echo "${GREEN}Fichier $log_file créé avec succès dans $LOG_DIR.${RESET}"
        else
            echo "${BLUE}Le fichier $log_file n'a pas été créé.${RESET}"
        fi
    fi
done

# Vérification des dossiers Docker/pki/certs, Docker/pki/csr, Docker/pki/private
pki_dirs=(
    "/root/Docker/pki/certs/$FQDN"
    "/root/Docker/pki/csr/$FQDN"
    "/root/Docker/pki/private/$FQDN"
)

for pki_dir in "${pki_dirs[@]}"; do
    if [ -d "$pki_dir" ]; then
        echo "${VIOLET}Le dossier $pki_dir existe.${RESET}"
    else
        read -p "${YELLOW}Le dossier $pki_dir n'existe pas. Voulez-vous le créer ? (y/n): ${RESET}" choice
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            mkdir -p "$pki_dir"
            if [ $? -ne 0 ]; then
                echo "${RED}Erreur: Échec de la création du dossier $pki_dir${RESET}"
                exit 1
            fi
            echo "${GREEN}Dossier $pki_dir créé avec succès.${RESET}"
        else
            echo "${BLUE}Le dossier $pki_dir n'a pas été créé.${RESET}"
        fi
    fi
done

# Vérification des autres fichiers et dossiers
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
