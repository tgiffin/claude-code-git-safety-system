# Project Safety Guide: Working with Claude Code

This guide helps you work safely with AI coding assistants like Claude Code, preventing accidental deletions or destructive changes to your project.

## 🎯 Quick Safety Rules

### **THE GOLDEN RULES:**
1. **ALWAYS review before committing** - Never blindly accept large changes
2. **Run backups daily** - Use `./backup-project.sh`
3. **Use branches** - Never work directly on `main`
4. **Test locally first** - Don't push untested code
5. **Read what Claude suggests** - Don't just execute without understanding

## 🛡️ Protection Layers You Now Have

### Layer 1: Git Hooks (Automatic)
✅ **Pre-commit hook** - Blocks commits that:
  - Delete more than 50% of files
  - Remove critical files (package.json, README.md, etc.)
  - Change more than 1000 lines without confirmation

✅ **Pre-push hook** - Before pushing to GitHub:
  - Creates automatic backup bundle
  - Shows what commits will be pushed
  - Keeps last 20 backups in `~/.git-backups/`

### Layer 2: Manual Backups
✅ **Backup script** - Run anytime with:
```bash
./backup-project.sh
```

Creates:
- Git bundle (complete repo backup)
- Snapshot tar.gz (includes non-git files)
- Metadata file (commit history, branch info)

### Layer 3: GitHub Protection
✅ **Branch protection** - See `GITHUB_PROTECTION_SETUP.md`
- Prevents force pushes
- Requires pull requests for main branch
- Protects against accidental deletion

### Layer 4: Multiple Recovery Points
✅ **Multiple backups in different locations:**
1. Local `.git` folder (full history)
2. `~/.git-backups/` (automatic bundles)
3. GitHub remote (cloud backup)
4. GitHub Actions artifacts (90-day retention)

## 📋 Daily Best Practices

### Morning Routine (Start of Work Session)
```bash
# 1. Pull latest changes
git pull origin main

# 2. Create today's backup
./backup-project.sh

# 3. Create a new branch for your work
git checkout -b feature/todays-work-$(date +%Y%m%d)

# 4. Verify you're on the right branch
git branch --show-current
```

### During Work Session
- ✅ Commit small, logical changes frequently
- ✅ Write descriptive commit messages
- ✅ Review every change Claude suggests before accepting
- ✅ Test your changes before committing
- ⚠️ Never commit without reviewing the diff

```bash
# Before committing, ALWAYS review changes:
git status
git diff

# Then commit if everything looks good:
git add .
git commit -m "Descriptive message about what changed"
```

### End of Day Routine
```bash
# 1. Push your branch to GitHub
git push origin feature/todays-work-$(date +%Y%m%d)

# 2. Create a pull request on GitHub (review in browser)

# 3. Run final backup
./backup-project.sh

# 4. Review what you accomplished
git log --oneline --since="1 day ago"
```

## 🚨 Red Flags: When to STOP and Review

### 🛑 STOP IMMEDIATELY if Claude suggests:

1. **Mass deletions:**
   - `rm -rf *`
   - Deleting entire directories
   - Removing node_modules or dist (usually safe, but verify)

2. **Force operations:**
   - `git push --force`
   - `git reset --hard` (without specifying a commit)
   - Any command with `--force` or `-f`

3. **Destructive git commands:**
   - `git clean -fd` (deletes untracked files)
   - `git branch -D` (force delete branch)
   - Anything involving `git filter-branch`

4. **System-wide changes:**
   - Commands affecting files outside your project directory
   - Changes to `.git/config` without explanation
   - Modifying npm/system global packages

5. **Suspicious file operations:**
   - Creating or modifying `.env` files with credentials
   - Changes to `.gitignore` that could expose secrets
   - Moving files to `/tmp` or outside the project

### ⚠️ When You See These Flags:

1. **PAUSE** - Don't execute the command
2. **ASK** - Ask Claude to explain what it will do
3. **VERIFY** - Check if it makes sense for your task
4. **BACKUP** - Run `./backup-project.sh` before proceeding
5. **TEST** - Try on a test branch first if unsure

## 🔍 How to Review Claude's Changes

### For Code Changes:
```bash
# See what files changed
git status

# See detailed changes
git diff

# See changes for specific file
git diff path/to/file.ts

# Use GitHub Desktop for visual diff (easier!)
```

### Questions to Ask Yourself:
- ✅ Does this change match what I asked for?
- ✅ Are files being deleted that shouldn't be?
- ✅ Do I understand what each change does?
- ✅ Are there any unexpected file modifications?
- ✅ Is this change reversible if something goes wrong?

### Using GitHub Desktop (Recommended for Beginners):
1. Open GitHub Desktop
2. Click on each modified file in the left panel
3. Review the red (deleted) and green (added) lines
4. If anything looks wrong, discard those changes
5. Only commit what makes sense

## 🆘 Recovery Procedures

### "Claude deleted my files!"

**Don't panic! Your files are recoverable.**

#### Option 1: Undo uncommitted changes
```bash
# Restore all files to last commit
git checkout HEAD -- .

# Or restore specific file
git checkout HEAD -- path/to/file.ts
```

#### Option 2: Undo last commit (files committed but not pushed)
```bash
# Undo commit but keep changes
git reset --soft HEAD~1

# Undo commit and discard changes
git reset --hard HEAD~1
```

#### Option 3: Restore from GitHub
```bash
# Fetch latest from GitHub
git fetch origin

# Reset to GitHub version
git reset --hard origin/main
```

#### Option 4: Restore from backup bundle
```bash
# Find latest backup
ls -lt ~/.git-backups/YOUR_REPO_NAME/bundles/

# Clone from backup
cd ~
git clone ~/.git-backups/YOUR_REPO_NAME/bundles/LATEST_FILE.bundle recovered-project

# Copy recovered files back
cp -r recovered-project/* /path/to/your/project/
```

#### Option 5: Restore from snapshot
```bash
# Find latest snapshot
ls -lt ~/.git-backups/YOUR_REPO_NAME/snapshots/*/

# Extract snapshot
cd ~
tar -xzf ~/.git-backups/YOUR_REPO_NAME/snapshots/YYYY-MM/TIMESTAMP_snapshot.tar.gz

# This creates a folder with your project - copy what you need
```

### "I pushed bad changes to GitHub!"

```bash
# Option 1: Revert the commit (creates new commit that undoes changes)
git revert HEAD
git push origin main

# Option 2: If you have branch protection, create a fix PR
git checkout -b fix/undo-bad-changes
git revert HEAD
git push origin fix/undo-bad-changes
# Then merge the PR on GitHub
```

### "I deleted my entire repository on GitHub!"

1. **Check local** - Your local copy is still intact
2. **Check backups** - You have bundles in `~/.git-backups/`
3. **Create new repo** on GitHub with same name
4. **Re-push everything:**
   ```bash
   git remote set-url origin https://github.com/USER_NAME/YOUR_REPO_NAME.git
   git push -u origin main
   ```

## 🧰 Useful Commands

### Checking Repository Health
```bash
# See current status
git status

# See commit history
git log --oneline -10

# See what branch you're on
git branch --show-current

# See all branches
git branch -a

# See remote status
git remote -v

# Count files in repo
git ls-files | wc -l

# See size of repo
du -sh .git
```

### Safe Navigation
```bash
# Switch to main branch
git checkout main

# Create and switch to new branch
git checkout -b feature/my-feature

# See what changed between branches
git diff main..feature/my-feature

# List all recent branches
git branch --sort=-committerdate | head -10
```

### Backup Management
```bash
# List all backups
ls -lh ~/.git-backups/YOUR_REPO_NAME/bundles/

# Check backup size
du -sh ~/.git-backups/YOUR_REPO_NAME/

# Verify backup integrity
git bundle verify ~/.git-backups/YOUR_REPO_NAME/bundles/BACKUP_FILE.bundle
```

## 🤖 Working Effectively with Claude Code

### DO:
✅ Give Claude specific, clear instructions
✅ Ask Claude to explain changes before executing
✅ Request that Claude show you the diff
✅ Ask "what will this command do?" if unsure
✅ Tell Claude to stop if something feels wrong
✅ Ask Claude to work in small, reviewable steps

### DON'T:
❌ Accept changes blindly without reviewing
❌ Let Claude run commands you don't understand
❌ Skip backups because "it's probably fine"
❌ Work directly on main branch
❌ Commit without testing
❌ Push without reviewing what's being pushed

### Example Good Interactions:

**Good:**
> "Add a new button component to the header. Show me the code first before making changes."

**Good:**
> "I want to refactor the authentication logic. Let's do this in steps. First, show me the current structure."

**Good:**
> "Before you delete those files, explain why they need to be deleted and what the impact will be."

**Bad:**
> "Fix everything that's broken." (too vague, might make sweeping changes)

**Bad:**
> "Just do whatever you think is best." (gives too much control without oversight)

## 📊 Weekly Maintenance

### Every Monday:
- [ ] Run `./backup-project.sh`
- [ ] Review and merge any open pull requests
- [ ] Clean up old feature branches:
  ```bash
  git branch --merged | grep -v "main" | xargs git branch -d
  ```
- [ ] Verify GitHub is in sync:
  ```bash
  git fetch origin
  git status
  ```

### Monthly:
- [ ] Review backup storage size
- [ ] Download GitHub Actions backup artifacts
- [ ] Update dependencies if needed
- [ ] Review and update this guide with lessons learned

## 📞 Additional Resources

- **Git Basics:** https://git-scm.com/book/en/v2/Getting-Started-Git-Basics
- **GitHub Desktop:** https://docs.github.com/en/desktop
- **Git Undo Guide:** https://github.blog/2015-06-08-how-to-undo-almost-anything-with-git/

## 🎓 Learning Git Gradually

You don't need to be a Git expert to stay safe! Focus on learning these commands in order:

1. **Week 1 - Basic safety:**
   - `git status`
   - `git diff`
   - `git log --oneline`

2. **Week 2 - Branching:**
   - `git checkout -b branch-name`
   - `git branch --show-current`
   - `git checkout main`

3. **Week 3 - Recovery:**
   - `git checkout HEAD -- filename`
   - `git reset --soft HEAD~1`

4. **Week 4 - Backups:**
   - `./backup-project.sh`
   - `git bundle create backup.bundle --all`

**Remember:** GitHub Desktop handles most of these visually - use it while you learn!

## ✅ Final Checklist

Print this and keep it near your computer:

**Before Each Work Session:**
- [ ] Backup created today?
- [ ] On a feature branch (not main)?
- [ ] Latest changes pulled from GitHub?

**Before Each Commit:**
- [ ] Reviewed all changes with `git diff`?
- [ ] Changes match what I intended?
- [ ] No unexpected deletions?
- [ ] Tested the changes?

**Before Each Push:**
- [ ] Commits contain only related changes?
- [ ] Commit messages are clear?
- [ ] No sensitive data (passwords, API keys)?
- [ ] Ready for others to see this code?

**End of Day:**
- [ ] All changes committed or stashed?
- [ ] Branch pushed to GitHub?
- [ ] Backup created?

---

**Remember: It's better to be overly cautious than to lose work. When in doubt, BACKUP FIRST!**
