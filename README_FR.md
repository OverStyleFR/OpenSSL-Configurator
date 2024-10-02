<div align="center">

# OpenSSL-Configurator

<p align="center">
  <a href="./README.md">English</a> |
  <a href="./README_FR.md">Français</a>
</p>

<p align="center">
  <a href="https://gitlab.ovst.fr/tomv/openssl-configurator">
    <img height="21" src="https://img.shields.io/badge/Repository-Visit-green?style=flat-square&logo=gitlab" alt="GitLab Repository">
  </a>
  <a href="https://gitlab.ovst.fr/tomv/openssl-configurator/-/blob/main/LICENSE">
    <img height="21" src="https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-yellow?style=flat-square" alt="License">
  </a>
</p>

</div>

## Description

**OpenSSL-Configurator** est un projet d'automatisation conçu pour simplifier la génération de certificats locaux en PKI. Ce script prend en charge tout le processus, de la création des dossiers nécessaires à la génération des clés privées, en passant par l'envoi des demandes de signature (CSR) à une autorité de certification pour générer des certificats. Il automatise chaque étape afin de rendre l'intégration rapide et facile.

### Fonctionnalités :

- Création automatique des dossiers si nécessaire.
- Génération de clés privées.
- Création des fichiers de demande de certificat (request files).
- Connexion automatique à une autorité de certification pour exécuter la commande permettant de générer le certificat à partir du fichier de demande.

## Prérequis

Avant de pouvoir utiliser **OpenSSL-Configurator**, assurez-vous d'avoir les éléments suivants installés sur votre système :

- **Terminal Bash** (pour exécuter le script).
- **OpenSSL** (outil utilisé pour générer les certificats).
- Accès à une autorité de certification (CA) pour signer les demandes de certificats.

## Usage

Pour exécuter le script, il suffit de lancer la commande suivante dans un terminal Bash :

***
```bash
bash <(curl -s https://gitlab.ovst.fr/tomv/openssl-configurator/-/raw/main/openssl-generator.sh)
```
***

## Scripts disponibles

| Script                                          | Description                                                                                                   |
|-------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| [openssl-configurator.sh](https://gitlab.ovst.fr/tomv/openssl-configurator/-/raw/main/openssl-configurator.sh)  | Le script principal pour automatiser la génération de certificats locaux avec OpenSSL.                          |

## Licence

Le projet est distribué sous la licence CC BY-NC-SA 4.0. Voir le fichier [LICENSE](./LICENSE) pour plus de détails.

Made with ❤️ by [Tom V.](https://tomv.ovh)