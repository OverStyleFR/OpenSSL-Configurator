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

# Demander l'adresse IP associée
read -p "Entrez l'adresse IP pour le service $FQDN: " SERVICE_IP

# Demander l'adresse IP de l'autorité de certification
read -p "Entrez l'adresse IP de l'autorité de certification: " CA_IP

# Créer le fichier de configuration dans l'autorité de certification
ssh -t "root@$CA_IP" << EOF
    echo "${YELLOW}Création du fichier de configuration pour le service $SERVICE_NAME...${RESET}"
    cat <<EOL > /root/pki/sites/openssl-ssl-$SERVICE_NAME.cnf
[ req ]
distinguished_name  = req_distinguished_name
x509_extensions     = v3_req
prompt              = no

[ req_distinguished_name ]
C  = FR
ST = Occitanie
L  = Albi
O  = INT OVST ROOT CA
OU = IT-SSL
CN = $FQDN

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $FQDN
IP.1  = $SERVICE_IP
EOL
EOF

echo "${GREEN}Fichier de configuration créé avec succès pour $SERVICE_NAME.${RESET}"
exit 0
