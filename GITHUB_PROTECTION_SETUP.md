# GitHub Branch Protection Setup Guide

This guide will walk you through setting up GitHub branch protection rules to prevent accidental deletion of your repository and protect your main branch.

## 🛡️ Why Branch Protection?

Branch protection prevents:
- Accidental deletion of branches
- Force pushes that rewrite history
- Direct commits to main without review
- Deletion of the entire repository

## 📋 Step-by-Step Setup

### 1. Enable Branch Protection for Main Branch

1. Go to your repository on GitHub: https://github.com/tgiffin/swr-scenarios
2. Click **Settings** (top menu)
3. Click **Branches** (left sidebar)
4. Under "Branch protection rules", click **Add rule**
5. In "Branch name pattern", enter: `main`

### 2. Recommended Protection Rules

Check these boxes:

#### Essential (Highly Recommended):
- ✅ **Require a pull request before merging**
  - Prevents direct commits to main
  - Forces you to review changes before merging

- ✅ **Do not allow bypassing the above settings**
  - Even admins (you) must follow the rules

- ✅ **Allow force pushes** → Set to "Specify who can force push" → Select "Nobody"
  - Prevents rewriting history accidentally

#### Optional (For Extra Safety):
- ⚪ **Require status checks to pass before merging**
  - Only if you have CI/CD set up

- ⚪ **Require conversation resolution before merging**
  - Good for team projects

6. Click **Create** or **Save changes**

### 3. Prevent Repository Deletion

1. Still in **Settings**
2. Scroll down to the **Danger Zone** section
3. You'll see options like:
   - **Change repository visibility**
   - **Disable branch protection rules**
   - **Transfer ownership**
   - **Archive this repository**
   - **Delete this repository**

**Note:** GitHub doesn't have a "lock" feature to prevent deletion, but deletion requires typing the full repository name as confirmation. This provides protection against accidental deletion.

### 4. Enable GitHub Repository Backup (Recommended)

Since GitHub can be deleted, consider setting up automatic backups:

#### Option A: GitHub Actions Backup (Free)
Create a scheduled backup that runs automatically.

1. Create `.github/workflows/backup.yml` in your repository:

\`\`\`yaml
name: Automated Repository Backup

on:
  schedule:
    # Runs every day at 2 AM UTC
    - cron: '0 2 * * *'
  workflow_dispatch: # Allows manual trigger

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history

      - name: Create backup bundle
        run: |
          git bundle create backup.bundle --all

      - name: Upload backup artifact
        uses: actions/upload-artifact@v4
        with:
          name: repository-backup-${{ github.run_number }}
          path: backup.bundle
          retention-days: 90
\`\`\`

2. Commit and push this file to your repository
3. GitHub will automatically run daily backups
4. You can download backups from the "Actions" tab → Select a workflow run → "Artifacts"

#### Option B: Third-Party Backup Services (Paid)
- **BackHub** (backhub.co)
- **Rewind** (rewind.com)
- **GitProtect** (gitprotect.io)

These services automatically backup your entire GitHub account daily.

### 5. Set Up Multiple Remotes (Extra Safety)

Add a second remote backup location (like GitLab or Bitbucket):

\`\`\`bash
# Add GitLab as a second remote
git remote add gitlab git@gitlab.com:yourusername/swr-scenarios.git

# Push to both remotes
git push origin main
git push gitlab main

# Or push to all remotes at once
git remote set-url --add --push origin git@github.com:tgiffin/swr-scenarios.git
git remote set-url --add --push origin git@gitlab.com:yourusername/swr-scenarios.git
git push origin main  # Now pushes to both!
\`\`\`

## 🔄 Recommended Workflow with Protection

### Daily Development Workflow:

1. **Create a feature branch:**
   \`\`\`bash
   git checkout -b feature/my-new-feature
   \`\`\`

2. **Make changes and commit locally:**
   \`\`\`bash
   git add .
   git commit -m "Add new feature"
   \`\`\`
   *Note: Your pre-commit hook will run safety checks*

3. **Push feature branch:**
   \`\`\`bash
   git push origin feature/my-new-feature
   \`\`\`
   *Note: Your pre-push hook will create a backup*

4. **Create Pull Request on GitHub:**
   - Go to your repository on GitHub
   - Click "Compare & pull request"
   - Review the changes in the PR interface
   - Merge the PR

5. **Pull changes locally:**
   \`\`\`bash
   git checkout main
   git pull origin main
   \`\`\`

### Using GitHub Desktop:

GitHub Desktop works great with these protections!

1. **Create a new branch** (Branch menu → New Branch)
2. **Make changes** (files will show in left panel)
3. **Review changes** (click files to see diffs)
4. **Commit** (write message, click "Commit to branch")
5. **Push** (Click "Push origin")
6. **Create PR** (GitHub Desktop will show "Create Pull Request" button)
7. **Merge on GitHub website**

## 🔍 Verifying Your Setup

Run these checks to verify everything is working:

\`\`\`bash
# Check that hooks are installed
ls -la .git/hooks/pre-commit .git/hooks/pre-push

# Test the pre-commit hook
git add .
git commit -m "test commit"

# Verify branch protection on GitHub
# Go to: Settings → Branches → View rules
\`\`\`

## 🚨 What to Do If Something Goes Wrong

### If you accidentally delete files locally:

\`\`\`bash
# Restore from last commit
git checkout HEAD -- .

# Or restore from GitHub
git fetch origin
git reset --hard origin/main
\`\`\`

### If you need to recover from backup:

\`\`\`bash
# From Git bundle
git clone ~/.git-backups/swr-scenarios/bundles/LATEST_BACKUP.bundle restored-project

# From snapshot
cd ~
tar -xzf ~/.git-backups/swr-scenarios/snapshots/YYYY-MM/TIMESTAMP_snapshot.tar.gz
\`\`\`

### If GitHub repository is deleted:

1. **Local repository still exists** - You can push to a new GitHub repo
2. **Backup bundles exist** - Restore from `~/.git-backups/`
3. **Contact GitHub support** - They may be able to restore within 90 days

## 📞 Additional Resources

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)
- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
- [GitHub Desktop Documentation](https://docs.github.com/en/desktop)

## ✅ Quick Checklist

- [ ] Branch protection enabled on main branch
- [ ] Pre-commit hook installed and working
- [ ] Pre-push hook installed and working
- [ ] Backup script tested
- [ ] GitHub Actions backup workflow created (optional)
- [ ] Second remote added (optional)
- [ ] Tested recovery process
