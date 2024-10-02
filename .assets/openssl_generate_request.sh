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
    exec sudo "$0" "$@"
    exit 1
fi

# Récupérer les paramètres passés par le script principal
DOMAIN="$1"
SERVICE_NAME="$2"
FQDN="$SERVICE_NAME.$DOMAIN"

# Définir le chemin de base à partir du répertoire où le script est exécuté
BASE_DIR=$(pwd)

# Définir les chemins pour les fichiers
PRIVATE_KEY_PATH="$BASE_DIR/Docker/pki/private/$FQDN/ssl-$SERVICE_NAME.key"
CSR_PATH="$BASE_DIR/Docker/pki/csr/$DOMAIN/$FQDN/ssl-$SERVICE_NAME.csr"

# Demander les attributs pour le certificat
read -p "Entrez le code pays (C): " COUNTRY
read -p "Entrez la région (ST): " STATE
read -p "Entrez la ville (L): " CITY
read -p "Entrez le nom de l'autorité root (O): " ORGANIZATION
read -p "Entrez le nom de la sous-autorité (OU): " ORG_UNIT

# Créer les répertoires nécessaires pour la clé privée et la demande de certificat
mkdir -p "$(dirname "$PRIVATE_KEY_PATH")"
mkdir -p "$(dirname "$CSR_PATH")"

# Générer la clé privée directement à l'emplacement final
echo "${YELLOW}Génération de la clé privée...${RESET}"
openssl ecparam -genkey -name secp384r1 -out "$PRIVATE_KEY_PATH"
if [ $? -ne 0 ]; then
    echo "${RED}Erreur: Échec de la génération de la clé privée${RESET}"
    exit 1
fi
echo "${GREEN}Clé privée générée avec succès à $PRIVATE_KEY_PATH.${RESET}"

# Générer la demande de certificat (CSR)
echo "${YELLOW}Génération de la demande de certificat...${RESET}"
openssl req -new -key "$PRIVATE_KEY_PATH" -out "$CSR_PATH" -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORGANIZATION/OU=$ORG_UNIT/CN=$FQDN"
if [ $? -ne 0 ]; then
    echo "${RED}Erreur: Échec de la génération de la demande de certificat${RESET}"
    exit 1
fi
echo "${GREEN}Demande de certificat générée avec succès à $CSR_PATH.${RESET}"

########################################## RETOUR DE STATUT ##########################################

echo "${GREEN}Clé et demande de certificat créées avec succès.${RESET}"
exit 0
