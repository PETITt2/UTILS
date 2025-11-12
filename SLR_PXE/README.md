# Installation d’un serveur PXE avec un serveur DHCP séparé

## Objectif

Ce guide explique comment mettre en place un **serveur PXE (Preboot eXecution Environment)** sur une machine Debian, afin de permettre l’installation d’un système (comme Ubuntu ou Debian) directement via le réseau.

Dans ce scénario, le **serveur DHCP** est déjà présent sur le réseau (distinct du serveur PXE).  
Le serveur PXE servira uniquement les fichiers nécessaires au démarrage réseau (bootloader, noyau, initrd, etc.) grâce à **TFTP** et **HTTP/FTP**.

---

## Schéma du réseau

```
[Client] ----> [DHCP Server] ----> [PXE Server (TFTP + HTTP)] ----> [ISO / Netboot Files]
```

---

## Prérequis

- Un **serveur Debian** (ou Ubuntu) qui fera office de **serveur PXE**.
- Un **serveur DHCP fonctionnel** (externe) configuré pour indiquer au client où trouver le serveur PXE.
- Une **connexion Internet** pour télécharger les fichiers d’installation (ou un ISO).
- Paquets nécessaires : `dnsmasq` (optionnel si DHCP manquant), `tftpd-hpa`, `apache2` ou `nginx`.

---

## Étape 1 : Installation des paquets nécessaires

```bash
sudo apt update
sudo apt install tftpd-hpa wget -y
```

Le serveur **tftpd-hpa** servira les fichiers de démarrage réseau, et **apache2** servira les fichiers d’installation (netboot).

---

## Étape 2 : Configuration du TFTP

Le répertoire TFTP par défaut est souvent `/srv/tftp`. Vérifiez ou créez-le :

```bash
sudo mkdir -p /srv/tftp
sudo chmod -R 755 /srv/tftp
```

Éditez le fichier de configuration :

```bash
sudo nano /etc/default/tftpd-hpa
```

Mettez la configuration suivante :

```bash
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
```

Redémarrez le service :

```bash
sudo systemctl restart tftpd-hpa
sudo systemctl enable tftpd-hpa
```

---

## Étape 3 : Téléchargement des fichiers Netboot Debian ou Ubuntu

### Pour Debian :
```bash
cd /srv/tftp
sudo wget http://deb.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/netboot.tar.gz
sudo tar -xzf netboot.tar.gz
```

### Pour Ubuntu :
```bash
cd /srv/tftp
sudo wget http://archive.ubuntu.com/ubuntu/dists/noble/main/installer-amd64/current/legacy-images/netboot/netboot.tar.gz
sudo tar -xzf netboot.tar.gz
```

Cela installera les fichiers nécessaires, notamment :
- `pxelinux.0`
- `ldlinux.c32`
- `initrd.gz`
- `linux`

---

## Étape 4 : Configurer le serveur DHCP existant

Sur le **serveur DHCP**, vous devez ajouter les options suivantes pour indiquer où trouver le serveur PXE.

Exemple (dans `/etc/dnsmasq.conf` ou un fichier équivalent sur le DHCP principal) :

```bash
# Interface réseau à écouter
interface=ens18
bind-interfaces

# DHCP de base
dhcp-range=192.168.50.50,192.168.50.100,12h
dhcp-option=3,192.168.50.1
dhcp-option=6,8.8.8.8,8.8.4.4
domain=lan

# --- PXE Boot via serveur PXE/TFTP externe ---

# BIOS (PXELinux)
dhcp-boot=pxelinux.0,,192.168.50.3

# Pour clients UEFI 64 bits
dhcp-match=set:efi-x64,option:client-arch,7
dhcp-boot=tag:efi-x64,debian-installer/amd64/grubx64.efi,,192.168.50.3
#ici on boot sur grubx64.efi mais cela peut differer selon les version et architectures
```

> Remplacez `192.168.50.X` par l’adresse IP de votre serveur PXE.

---


## Étape 7 : Test du démarrage PXE

1. Branchez un client sur le même réseau.  
2. Dans son BIOS/UEFI, activez le **boot réseau (PXE)**.  
3. Lors du démarrage, il devrait recevoir une IP via DHCP, puis télécharger `pxelinux.0` depuis le serveur PXE.

Si le menu s’affiche, la configuration est réussie.

---

## Étape 8 : Dépannage rapide

- Si le client ne trouve pas le serveur PXE : vérifier les options DHCP 66 et 67.  
- Si le téléchargement échoue : vérifier le pare-feu et le port UDP 69 (TFTP).  
- Si le menu ne s’affiche pas : vérifier la présence du répertoire `pxelinux.cfg/` et du fichier `default (parfois utile et present parfois pas)`.

---
