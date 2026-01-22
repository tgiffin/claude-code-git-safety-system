#!/bin/bash
# Automated Project Backup Script
# Run this manually or set up as a cron job for automatic backups

set -e

PROJECT_NAME="swr-scenarios"
BACKUP_BASE_DIR="$HOME/.git-backups/$PROJECT_NAME"
PROJECT_DIR="$(git rev-parse --show-toplevel)"

# Create backup directories
mkdir -p "$BACKUP_BASE_DIR/bundles"
mkdir -p "$BACKUP_BASE_DIR/snapshots"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DATE_FOLDER=$(date +"%Y-%m")

echo "🔄 Starting backup for $PROJECT_NAME..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Create Git bundle (complete repository backup)
echo ""
echo "📦 Creating Git bundle backup..."
BUNDLE_FILE="$BACKUP_BASE_DIR/bundles/${TIMESTAMP}_complete.bundle"
cd "$PROJECT_DIR"
git bundle create "$BUNDLE_FILE" --all

if [ $? -eq 0 ]; then
    BUNDLE_SIZE=$(du -h "$BUNDLE_FILE" | cut -f1)
    echo "   ✅ Bundle created: $BUNDLE_SIZE"
else
    echo "   ❌ Bundle creation failed!"
    exit 1
fi

# 2. Create tar.gz snapshot (includes non-git files)
echo ""
echo "📸 Creating full snapshot (tar.gz)..."
SNAPSHOT_DIR="$BACKUP_BASE_DIR/snapshots/$DATE_FOLDER"
mkdir -p "$SNAPSHOT_DIR"
SNAPSHOT_FILE="$SNAPSHOT_DIR/${TIMESTAMP}_snapshot.tar.gz"

tar -czf "$SNAPSHOT_FILE" \
    --exclude='node_modules' \
    --exclude='dist' \
    --exclude='.git' \
    --exclude='*.log' \
    -C "$(dirname $PROJECT_DIR)" \
    "$(basename $PROJECT_DIR)"

if [ $? -eq 0 ]; then
    SNAPSHOT_SIZE=$(du -h "$SNAPSHOT_FILE" | cut -f1)
    echo "   ✅ Snapshot created: $SNAPSHOT_SIZE"
else
    echo "   ❌ Snapshot creation failed!"
    exit 1
fi

# 3. Save Git status and commit info
echo ""
echo "📋 Saving Git metadata..."
METADATA_FILE="$BACKUP_BASE_DIR/snapshots/$DATE_FOLDER/${TIMESTAMP}_metadata.txt"
{
    echo "Backup Date: $(date)"
    echo "Project: $PROJECT_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Current Branch:"
    git branch --show-current
    echo ""
    echo "Last 5 Commits:"
    git log --oneline -5
    echo ""
    echo "Remote Status:"
    git remote -v
    echo ""
    echo "File Count:"
    git ls-files | wc -l
} > "$METADATA_FILE"
echo "   ✅ Metadata saved"

# 4. Cleanup old backups (keep last 30 bundles, 60 days of snapshots)
echo ""
echo "🧹 Cleaning up old backups..."

# Keep last 30 bundles
cd "$BACKUP_BASE_DIR/bundles"
ls -t *.bundle 2>/dev/null | tail -n +31 | xargs rm -f 2>/dev/null
BUNDLE_COUNT=$(ls -1 *.bundle 2>/dev/null | wc -l)
echo "   📦 Bundles retained: $BUNDLE_COUNT"

# Remove snapshot folders older than 60 days
find "$BACKUP_BASE_DIR/snapshots" -type f -mtime +60 -delete 2>/dev/null
find "$BACKUP_BASE_DIR/snapshots" -type d -empty -delete 2>/dev/null
SNAPSHOT_COUNT=$(find "$BACKUP_BASE_DIR/snapshots" -name "*.tar.gz" | wc -l)
echo "   📸 Snapshots retained: $SNAPSHOT_COUNT"

# 5. Display backup summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Backup Complete!"
echo ""
echo "Backup Location: $BACKUP_BASE_DIR"
echo "Latest Bundle:   $BUNDLE_FILE"
echo "Latest Snapshot: $SNAPSHOT_FILE"
echo ""
echo "To restore from bundle:"
echo "  git clone $BUNDLE_FILE restored-project"
echo ""
echo "To restore from snapshot:"
echo "  tar -xzf $SNAPSHOT_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
