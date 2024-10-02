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

**OpenSSL-Configurator** is an automation project designed to simplify the generation of local certificates using PKI. This script handles the entire process, from creating the necessary folders and generating private keys to sending certificate signing requests (CSR) to a certification authority for certificate generation. It automates each step to ensure quick and easy integration.

### Features:

- Automatic creation of folders if needed.
- Generation of private keys.
- Creation of certificate request files (CSR).
- Automatic connection to a certification authority to generate the certificate from the request file.

## Prerequisites

Before using **OpenSSL-Configurator**, ensure you have the following installed on your system:

- **Bash terminal** (to run the script).
- **OpenSSL** (tool used for certificate generation).
- Access to a certification authority (CA) to sign certificate requests.

## Usage

To run the script, simply execute the following command in a Bash terminal:

***
```bash
bash <(curl -s https://gitlab.ovst.fr/tomv/openssl-configurator/-/raw/main/openssl-generator.sh)
```
***

## Available Scripts

| Script                                          | Description                                                                                                   |
|-------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| [openssl-configurator.sh](https://gitlab.ovst.fr/tomv/openssl-configurator/-/raw/main/openssl-configurator.sh)  | The main script to automate the generation of local certificates with OpenSSL.                                 |

## License

The project is distributed under the CC BY-NC-SA 4.0 license. See the [LICENSE](./LICENSE) file for more details.

Made with ❤️ by [Tom V.](https://tomv.ovh)