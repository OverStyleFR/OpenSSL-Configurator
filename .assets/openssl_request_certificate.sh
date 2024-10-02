#!/bin/bash

# Définir les couleurs
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

########################################## INITIALISATION ROOT ##########################################

# Vérifier si l'utilisateur est root
if [[ $EUID -ne 0 ]]; then
    echo "${RED}${BOLD}Ce script doit être exécuté en tant que root${RESET}"
    exec sudo "$0" "$@"
    exit 1
fi

# Récupérer les paramètres passés par le script principal
DOMAIN="$1"
SERVICE_NAME="$2"
FQDN="$SERVICE_NAME.$DOMAIN"

# Définir le chemin de base à partir du répertoire où le script est exécuté
BASE_DIR=$(pwd)

# Définir le chemin du CSR
CSR_PATH="$BASE_DIR/Docker/pki/csr/$DOMAIN/$FQDN/ssl-$SERVICE_NAME.csr"

# Demander à l'utilisateur de configurer une clé SSH pour se connecter facilement
echo "${YELLOW}Veuillez configurer une clé SSH pour une connexion facile avec l'autorité de certification.${RESET}"
read -p "Entrez l'adresse IP de l'autorité de certification: " CA_IP

# Vérification de l'existence du fichier .csr
if [ ! -f "$CSR_PATH" ]; then
    echo "${RED}Erreur: Le fichier CSR n'existe pas à l'emplacement $CSR_PATH.${RESET}"
    exit 1
fi

# Transférer le fichier .csr sur l'autorité de certification
echo "${YELLOW}Transfert du fichier CSR sur l'autorité de certification...${RESET}"
scp "$CSR_PATH" "root@$CA_IP:/tmp/"
if [ $? -ne 0 ]; then
    echo "${RED}Erreur: Échec du transfert du fichier CSR.${RESET}"
    exit 1
fi

# Exécuter des commandes sur l'autorité de certification
ssh "root@$CA_IP" << EOF
    echo "${YELLOW}Création des dossiers pour le certificat...${RESET}"
    mkdir -p pki/certs/$FQDN
    mkdir -p pki/csr/$FQDN

    echo "${YELLOW}Déplacement du fichier CSR...${RESET}"
    mv /tmp/ssl-$SERVICE_NAME.csr pki/csr/$FQDN/
    
    echo "${YELLOW}Application des permissions sur le certificat...${RESET}"
    chmod 700 pki/csr/$FQDN/ssl-$SERVICE_NAME.csr
EOF

echo "${GREEN}Processus terminé avec succès.${RESET}"
exit 0
