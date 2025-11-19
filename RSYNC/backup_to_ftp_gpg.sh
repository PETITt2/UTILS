#!/bin/bash

SRC_ETC="/etc/dhcp/dhcpd.conf"
DATE=$(date +%F_%H-%M-%S)
DEST="/tmp/dhcpd.conf-$DATE.gpg"
FTP_SERVER="root@192.168.50.5"
FTP_PATH="/backup/dhcp/"

# Chiffrement du fichier DHCP
gpg --yes --batch --trust-model always --encrypt --recipient backup@ftp.local -o "$DEST" "$SRC_ETC"

# Transfert du fichier chiffré via rsync
rsync -avz -e ssh "$DEST" "$FTP_SERVER:$FTP_PATH"

# Nettoyer le fichier temporaire
rm -f "$DEST"

# Log
echo "[$(date)] Backup GPG exécuté vers $FTP_SERVER:$FTP_PATH" >> /var/log/backup_dhcp_gpg.log