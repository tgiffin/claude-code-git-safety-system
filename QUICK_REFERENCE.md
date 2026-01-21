# 🚨 Quick Reference Card - Emergency Commands

**Print this and keep it visible!**

## ⚠️ STOP and Review If You See:
- ❌ `rm -rf`
- ❌ `git push --force`
- ❌ `git reset --hard` (without commit hash)
- ❌ Mass file deletions
- ❌ Changes to files outside your project

## 🆘 Emergency Recovery Commands

### Undo Uncommitted Changes
```bash
# Restore everything
git checkout HEAD -- .

# Restore one file
git checkout HEAD -- path/to/file
```

### Undo Last Commit (Not Pushed)
```bash
# Keep the changes
git reset --soft HEAD~1

# Discard the changes
git reset --hard HEAD~1
```

### Restore from GitHub
```bash
git fetch origin
git reset --hard origin/main
```

### Restore from Backup
```bash
# Find latest backup
ls -lt ~/.git-backups/swr-scenarios/bundles/

# Clone from backup
git clone ~/.git-backups/swr-scenarios/bundles/LATEST.bundle ~/recovered-project
```

## 📋 Daily Workflow

### Morning
```bash
git pull origin main
./backup-project.sh
git checkout -b feature/todays-work
```

### Before Commit
```bash
git status
git diff
# Review changes carefully!
git add .
git commit -m "Clear description"
```

### Before Push
```bash
# Your pre-push hook will auto-backup
git push origin feature/todays-work
```

### End of Day
```bash
./backup-project.sh
```

## 🛡️ Safety Features Active

✅ Pre-commit hook - Blocks dangerous commits
✅ Pre-push hook - Creates auto-backup before push
✅ Commit-msg hook - Shows change summary
✅ Manual backup script - `./backup-project.sh`

## 🔍 Quick Status Checks

```bash
# Where am I?
git branch --show-current

# What's changed?
git status

# Recent commits
git log --oneline -5

# Check backups exist
ls ~/.git-backups/swr-scenarios/bundles/
```

## 📞 Need Help?

1. Read `PROJECT_SAFETY_GUIDE.md` (comprehensive guide)
2. Read `GITHUB_PROTECTION_SETUP.md` (GitHub setup)
3. Ask Claude to explain before executing
4. Create backup before risky operations: `./backup-project.sh`

## ⚡ One-Line Backup Command
```bash
./backup-project.sh
```

**Bookmark this file!** You'll thank yourself later.
