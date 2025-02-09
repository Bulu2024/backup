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
DATE=$(date +'%Y-%m-%d_%H-%M-%S')
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
DATE_TIME=$(date +%Y%m%d_%H%M%S)
LOCAL_BACKUP_DIR="/data/repository/backup"
REMOTE_DEST="root@3.1.1.2:/data/backup"
BACKUP_FILE="${HOST}_${DATE_TIME}_server_backup.tsbak"
CONFIG_FILE="${LOCAL_BACKUP_DIR}/${HOST}_${DATE_TIME}_server_config.json"

tsm maintenance backup -f "${BACKUP_FILE}" --ignore-prompt
tsm settings export -f "${CONFIG_FILE}"

scp "${LOCAL_BACKUP_DIR}/${BACKUP_FILE}" "${REMOTE_DEST}"
scp "${CONFIG_FILE}" "${REMOTE_DEST}"
