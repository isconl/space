## Architect Git SSH & Commit Workflow Documentation

This document summarizes the complete setup and workflow we have established for managing Git repositories securely and efficiently using SSH, global commit templates, and an interactive commit helper.

---

### 1️⃣ SSH Setup for GitHub

**Goal:** Authenticate with GitHub securely via SSH to enable clone, push, and pull operations without entering credentials each time.

**Steps:**

1. **Generate SSH Key:**
```bash
ssh-keygen -t ed25519 -C "operator@example.com"
```
- Press Enter to accept default file location: `~/.ssh/id_ed25519`
- Set a strong passphrase for security.

2. **Start SSH agent and add key:**
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```
- Enter your passphrase if prompted.

3. **Copy public key and add to GitHub:**
```bash
cat ~/.ssh/id_ed25519.pub
```
- Go to GitHub Settings → SSH and GPG keys → New SSH key
- Title: `Fedora-X260-ARCHITECT`
- Paste key and save.

4. **Test connection:**
```bash
ssh -T git@github.com
```
- Should return: `Hi sconl! You've successfully authenticated, but GitHub does not provide shell access.`

✅ SSH is now configured globally for all repositories.

---

### 2️⃣ Clone a Repository

**Example:**
```bash
git clone git@github.com:q-space/pages.git
cd pages
```
- Ensure you are in the repo root (contains `.git`) for all subsequent operations.

---

### 3️⃣ Git Commit Template

**Goal:** Ensure consistent, structured commit messages across all repositories.

**Location:**
```
/home/sconl/systems-engineer/.global/20260215_template_git_commit_message.txt
```

**Content:**
```
<type>(<scope>): <short summary>
# Example types: feat, fix, docs, style, refactor, test, chore
# Example scope: pages, auth, ui, build

<body (optional)>
# Explain WHY the change was made, not what
# Wrap lines at ~72 characters

<footer (optional)>
# Reference issues (Closes #23)
# Note breaking changes (BREAKING CHANGE: ...)
```

**Set as global Git template:**
```bash
git config --global commit.template /home/sconl/systems-engineer/.global/20260215_template_git_commit_message.txt
```
- Works for **all Git repositories**, not location-dependent.

---

### 4️⃣ Interactive Git Commit Helper Script

**Goal:** Semi-automate commit creation with interactive prompts for type, scope, summary, body, and footer.

**Location:**
```
/home/sconl/systems-engineer/.global/20260215_git_commit_helper.sh
```

**Make executable:**
```bash
chmod +x /home/sconl/systems-engineer/.global/20260215_git_commit_helper.sh
```

**Script content:**
```bash
#!/bin/bash

# Check if inside a Git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not inside a Git repository. cd into one first."
    exit 1
fi

# Prompt for commit details
read -p "Commit type (feat/fix/docs/style/refactor/test/chore): " TYPE
read -p "Scope (module/folder affected, optional): " SCOPE
read -p "Short summary (imperative, <=50 chars): " SUMMARY
read -p "Body (optional, press Enter to skip, wrap manually at ~72 chars): " BODY
read -p "Footer (optional, issue refs or BREAKING CHANGE): " FOOTER

# Build commit message
COMMIT_MSG=""
if [ -n "$SCOPE" ]; then
    COMMIT_MSG="$TYPE($SCOPE): $SUMMARY"
else
    COMMIT_MSG="$TYPE: $SUMMARY"
fi

if [ -n "$BODY" ]; then
    COMMIT_MSG="$COMMIT_MSG

$BODY"
fi

if [ -n "$FOOTER" ]; then
    COMMIT_MSG="$COMMIT_MSG

$FOOTER"
fi

# Preview and confirm
echo
echo "=== Commit message preview ==="
echo "$COMMIT_MSG"
echo "=============================="
read -p "Proceed with commit? (y/n): " CONFIRM

if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
    git commit -m "$COMMIT_MSG"
    echo "✅ Commit created successfully!"
else
    echo "❌ Commit canceled."
fi
```

**Alias for convenience:**
```bash
alias commit="/home/sconl/systems-engineer/.global/20260215_git_commit_helper.sh"
```
- Add to `~/.bashrc` or `~/.zshrc` and `source` the file.
- Now you can run `commit` from **any Git repository**.

---

### 5️⃣ Practical Workflow Step-by-Step

1. **Navigate to the repo:**
```bash
cd ~/systems-engineer/Systems/Sconl/Spark/GitHub/pages
```

2. **Pull latest changes:**
```bash
git pull
```

3. **Make edits:**
- Rename, edit, add, delete files.
- Example: `mv oldfilename.ext newfilename.ext`

4. **Commit changes with helper:**
```bash
commit
```
- Fill in type, scope, summary, body, footer
- Preview and confirm commit

5. **Push changes:**
```bash
git push
```

6. **Repeat daily:**
- `git pull` → edit → `commit` → `git push`
- Works in all cloned repositories

7. **Optional:**
- Use branches for features: `git checkout -b feature/xyz`
- Stage manually if desired: `git add -A`
- Check status and history: `git status`, `git log --oneline --graph --decorate`

---

### 6️⃣ Notes & Best Practices

- **Global template and helper**: Works for all repositories, not limited to one folder.
- **SSH authentication**: Secure, avoids password prompts.
- **Interactive helper**: Ensures consistent, high-quality commit messages.
- **Date-stamped template and helper filenames**: Allows versioning and tracking updates.
- **Alias `commit`**: Streamlines workflow, replacing `git commit` with guided input.

---

### 7️⃣ Optional Future Enhancements

- Auto-stage all changes before running commit
- Include default scopes or pre-filled bodies for standard workflows
- Integrate with pre-commit hooks for formatting, linting, or validation
- Maintain a versioned `.global` folder across multiple machines for consistency

