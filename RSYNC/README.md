# Sauvegarde Automatique du DHCP vers un Serveur de Stockage via SSH + Chiffrement GPG

## Objectif de la documentation

Ce guide explique comment mettre en place **une sauvegarde automatique, chiffrée et transférée via SSH**, entre deux serveurs Debian.

Cette documentation inclut :

* La préparation des serveurs
* L'installation de `rsync` et `gpg`
* La génération et l'export des clés GPG
* La mise en place d'un script de sauvegarde **chiffré**
* La planification automatique avec `cron`

---

## 1. Architecture du système

* **Serveur DHCP (192.168.50.4)**

  * Source des fichiers à sauvegarder : `/etc/dhcp/dhcpd.conf`
  * Chiffre la sauvegarde avec GPG
  * Envoie la sauvegarde chiffrée au serveur FTP via SSH

* **Serveur FTP (192.168.50.5)**

  * Sert uniquement de stockage
  * Reçoit des fichiers déjà chiffrés
  * Stocke les sauvegardes dans : `/backup/dhcp/`

Toutes les transmissions sont sécurisées par **SSH + chiffrement GPG**.

---

## 2. Préparation des serveurs

### 2.1. Mise à jour

Sur les deux serveurs :

```bash
apt -y update
apt -y upgrade
```

### 2.2. Installation des outils nécessaires

Sur les deux serveurs :

```bash
apt install -y rsync openssh-server gnupg
```

### 2.3. Préparation du stockage (Serveur FTP)

```bash
mkdir -p /backup/dhcp
chmod 700 /backup/dhcp
```

---

## 3. Mise en place du chiffrement GPG

### 3.1. Création de la clé GPG (Serveur FTP)

Le serveur FTP héberge la **clé publique**, car c’est lui qui doit pouvoir déchiffrer.

```bash
gpg --quick-generate-key "backup@ftp.local" default default never
```

Vérifier :

```bash
gpg --list-keys
```

Exporter la **clé publique** :

```bash
gpg --export -a "backup@ftp.local" > /root/backup_pubkey.asc
```

---

### 3.2. Copie de la clé publique vers le serveur DHCP

Depuis le serveur FTP :

```bash
scp /root/backup_pubkey.asc root@192.168.50.4:/root/
```

Sur le serveur DHCP, importer la clé :

```bash
gpg --import /root/backup_pubkey.asc
```

---

## 4. Mise en place de l’authentification SSH

### 4.1. Génération de la clé SSH (Serveur DHCP)

```bash
ssh-keygen -t ed25519
```

### 4.2. Copier la clé publique vers le serveur FTP

```bash
ssh-copy-id root@192.168.50.5
```

Vérification :

```bash
ssh root@192.168.50.5 "echo Connexion SSH OK"
```

---

## 5. Script de sauvegarde chiffrée (Serveur DHCP)

Créer :

```bash
nano /usr/local/bin/backup_to_ftp_gpg.sh
```

Contenu :

```bash
#!/bin/bash
DATE=$(date +%F_%H-%M-%S)
SRC="/etc/dhcp/dhcpd.conf"
TMP_FILE="/tmp/dhcpd.conf-$DATE.gpg"
DEST="root@192.168.50.5:/backup/dhcp/"

# Chiffrement GPG
gpg --batch --yes --encrypt -r "backup@ftp.local" -o "$TMP_FILE" "$SRC"

# Transfert via SSH
rsync -avz "$TMP_FILE" "$DEST"

# Log
echo "[$(date)] Backup envoyée : $TMP_FILE" >> /var/log/backup_dhcp_gpg.log

# Nettoyage
rm -f "$TMP_FILE"
```

Rendre exécutable :

```bash
chmod +x /usr/local/bin/backup_to_ftp_gpg.sh
```

---

## 6. Planification automatique via CRON

Éditer :

```bash
crontab -e
```

Ajouter :

```bash
0 23 * * * /usr/local/bin/backup_to_ftp_gpg.sh
```

La sauvegarde sera exécutée **tous les jours à 23h**.

---

## 7. Tests et vérifications

### 7.1. Test manuel

```bash
/usr/local/bin/backup_to_ftp_gpg.sh
```

### 7.2. Vérifier sur le serveur FTP

```bash
ls /backup/dhcp/
```

### 7.3. Vérifier les logs

```bash
tail -n 20 /var/log/backup_dhcp_gpg.log
```

---

## 8. Sécurisation

### Droits SSH

```bash
chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_ed25519
chmod 644 /root/.ssh/id_ed25519.pub
```

### Droits GPG

```bash
chmod 700 /root/.gnupg
```

### Droits dossier backup

```bash
chmod 700 /backup/dhcp
```

---
