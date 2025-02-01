#!/bin/bash
set -e

SRC="/opt/analytics"
DATE=$(date +'%Y-%m-%d_%H-%M-%S')
ARCHIVE="/root/backup_analytics/data/analytics_app_backup_${DATE}.tar.gz"
ARCHIVE_DIR=$(dirname "$ARCHIVE")

mkdir -p "$ARCHIVE_DIR"

export GZIP=-9

tar -czvf "$ARCHIVE" \
    --exclude='.git' \
    --exclude='*.csv' \
    --exclude='*.csv.gz' \
    --exclude='*.tar.gz' \
    --exclude='*.log' \
    --exclude='*.log.*' \
    -C "$SRC" .

echo "Backup complete: $ARCHIVE"

