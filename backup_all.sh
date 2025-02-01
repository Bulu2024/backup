#!/bin/bash

DATE=$(date +'%Y-%m-%d_%H-%M-%S')
SRC_DB="/data/repository/db/backup/backup_clickhouse_${DATE}"
SRC_SW="/opt/analytics"
DEST="/root/backup_analytics/data/backup_clickhouse_${DATE}"

# Clickhouse
clickhouse-backup create --config /etc/clickhouse-backup/config.yml --schema "backup_clickhouse_${DATE}"
cp -r "${SRC_DB}" "${DEST}"

# App
SRC_SW="/opt/analytics"
DATE=$(date +'%Y-%m-%d_%H-%M-%S')
ARCHIVE="/root/backup_analytics/data/analytics_app_backup_${DATE}.tar.gz"
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
cd /root/backup_analytics || { echo "Directory not found"; exit 1; }
git add .
git commit -m "Backup ${DATE}"
git push origin main
