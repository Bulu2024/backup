#!/bin/bash

DATE=$(date +'%Y-%m-%d_%H-%M-%S')
SRC_DB="/data/repository/db/backup/${DATE}_backup_clickhouse"
SRC_SW="/opt/analytics"
DEST="/srv/backup/backup_data/"

# Clickhouse
clickhouse-backup create --config /etc/clickhouse-backup/config.yml --schema "${DATE}_backup_clickhouse"
tar -czvf "${DEST}${DATE}_backup_clickhouse.tar.gz" "${SRC_DB}"

# App
SRC_SW="/opt/analytics"
ARCHIVE="${DEST}${DATE}_analytics_app_backup.tar.gz"
export GZIP=-9
tar -czvf "$ARCHIVE" \
    --exclude='.git' \
    --exclude='*.csv' \
    --exclude='*.csv.gz' \
    --exclude='*.tar.gz' \
    --exclude='*.log' \
    --exclude='*.log.*' \
    -C "$SRC_SW" .

echo "Backup complete: $ARCHIVE"

# Git
cd "$DEST.." || { echo "Directory not found"; exit 1; }
git add .
git commit -m "Backup ${DATE}"
git push origin main

# Tableau
HOST=$(hostname)
LOCAL_BACKUP_DIR="/data/repository/backup"
REMOTE_DEST="root@3.1.1.2:/data/backup"
BACKUP_FILE="${HOST}_${DATE}_server_backup.tsbak"
CONFIG_FILE="${LOCAL_BACKUP_DIR}/${HOST}_${DATE}_server_config.json"

/opt/tableau/tableau_server/packages/bin.20242.24.1213.1118/tsm maintenance backup -f "${BACKUP_FILE}" --ignore-prompt
/opt/tableau/tableau_server/packages/bin.20242.24.1213.1118/tsm settings export -f "${CONFIG_FILE}"

scp "${LOCAL_BACKUP_DIR}/${BACKUP_FILE}" "${REMOTE_DEST}"
scp "${CONFIG_FILE}" "${REMOTE_DEST}"

REMOTE_DEST="root@192.168.99.5:/srv/backup/backup_analytics"
scp "${LOCAL_BACKUP_DIR}/${BACKUP_FILE}" "${REMOTE_DEST}"
scp "${CONFIG_FILE}" "${REMOTE_DEST}"

