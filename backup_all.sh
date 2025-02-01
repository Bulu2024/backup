#!/bin/bash

DATE=$(date +'%Y-%m-%d_%H-%M-%S')
SCHEMA="backup_clickhouse_${DATE}"
SRC="/data/repository/db/backup/${SCHEMA}"
DEST="/root/backup_analytics/${SCHEMA}"

clickhouse-backup create --config /etc/clickhouse-backup/config.yml --schema "${SCHEMA}"
cp -r "${SRC}" "${DEST}"

cd /root/backup_analytics || { echo "Directory not found"; exit 1; }
git add .
git commit -m "Backup ${SCHEMA}"
git push origin main
