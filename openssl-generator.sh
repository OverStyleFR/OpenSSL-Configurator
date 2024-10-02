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

# Définir le chemin de base à partir du répertoire où le script est exécuté
BASE_DIR=$(pwd)

# Demander à l'utilisateur le domaine et le service
echo -n "Entrez le domaine pour lequel générer les certificats : "
read DOMAIN

echo -n "Entrez le nom du service (ex: gitlab) : "
read SERVICE_NAME

# Appel du script secondaire en passant les variables DOMAIN et SERVICE_NAME
if $BASE_DIR/.assets/check_main_directory.sh "$DOMAIN" "$SERVICE_NAME"; then
    echo "Le script check_main_directory.sh s'est terminé avec succès."
else
    echo "Le script check_main_directory.sh a échoué."
    exit 1
fi

if $BASE_DIR/.assets/check_domain_directory.sh "$DOMAIN" "$SERVICE_NAME"; then
    echo "Le script check_domain_directory.sh s'est terminé avec succès."
else
    echo "Le script check_domain_directory.sh a échoué."
    exit 1
fi
