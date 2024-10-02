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

# Définir le chemin de base à partir du répertoire où le script est exécuté
BASE_DIR=$(pwd)

# Récupérer les paramètres passés par le script principal
DOMAIN="$1"
SERVICE_NAME="$2"
FQDN="$SERVICE_NAME.$DOMAIN"
CSR_PATH="$BASE_DIR/Docker/pki/csr/$FQDN/ssl-$SERVICE_NAME.csr"

# Demander à l'utilisateur l'IP de l'autorité de certification
read -p "Entrez l'adresse IP de l'autorité de certification: " CA_IP

# Exécuter des commandes sur l'autorité de certification
ssh "root@$CA_IP" << EOF
    echo "${YELLOW}Création des dossiers pour le certificat...${RESET}"

    echo "${YELLOW}Déplacement du fichier CSR...${RESET}"
    mv /tmp/ssl-$SERVICE_NAME.csr pki/csr/$FQDN/
    
    # Signer le certificat
    echo "${YELLOW}Signature du certificat...${RESET}"
    openssl x509 -req -in pki/csr/$FQDN/ssl-$SERVICE_NAME.csr -CA /root/pki/it-ssl.crt -CAkey /root/pki/it-ssl.key -CAcreateserial -out pki/certs/$FQDN/ssl-$SERVICE_NAME.crt -days 30 -sha384 -extfile pki/sites/openssl-ssl-$SERVICE_NAME.cnf -extensions v3_req

    echo "${YELLOW}Application des permissions sur le certificat...${RESET}"
    chmod 700 pki/certs/$FQDN/ssl-$SERVICE_NAME.crt
EOF

# Récupérer le certificat signé
echo "${YELLOW}Récupération du certificat signé...${RESET}"
scp "root@$CA_IP:pki/certs/$FQDN/ssl-$SERVICE_NAME.crt" "$BASE_DIR/Docker/pki/certs/$FQDN/"
if [ $? -ne 0 ]; then
    echo "${RED}Erreur: Échec de la récupération du certificat signé.${RESET}"
    exit 1
fi

echo "${GREEN}Processus terminé avec succès.${RESET}"
exit 0
