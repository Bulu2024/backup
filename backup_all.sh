#!/bin/bash

SRC="/data/repository/db/backup/${SCHEMA}"
DEST="/root/backup_analytics/${SCHEMA}"
SCHEMA="backup_clickhouse_${DATE}"
DATE=$(date +'%Y-%m-%d_%H-%M-%S')

clickhouse-backup create --config /etc/clickhouse-backup/config.yml --schema "${SCHEMA}"
cp -r "${SRC}" "${DEST}"

cd /root/backup_analytics || { echo "Directory not found"; exit 1; }
git add .
git commit -m "Backup ${SCHEMA}"
git push origin main
