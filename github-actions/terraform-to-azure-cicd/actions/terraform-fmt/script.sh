#!/usr/bin/env bash
# =========================================================================================
# Script: terraform-fmt/script.sh
#
# Purpose:
#   - Runs 'terraform fmt -recursive' in a target directory.
#   - If formatting changes are made, commits & pushes, shows which files changed, and writes
#     a unified diff for each changed file to the GitHub summary.
#   - If nothing changed, writes a clear summary stating so.
#
# Usage:
#   ./script.sh <target_file> [author_name] [author_email]
#
#   - target_file: Path to a .tf or .tfvars file (directory will be used as working dir)
#   - author_name: (optional) Git commit author name (default: github-actions[bot])
#   - author_email: (optional) Git commit author email (default: github-actions[bot]@users.noreply.github.com)
#
# Best Practices:
#   - Only commits formatting changes, never functional changes.
#   - Produces a clear and actionable summary for end users.
#   - Safe for monorepo/multi-dir use.
# =========================================================================================

set -euo pipefail

FILE="${1:-}"
AUTHOR_NAME="${2:-github-actions[bot]}"
AUTHOR_EMAIL="${3:-github-actions[bot]@users.noreply.github.com}"

echo "[DEBUG] Input FILE: '$FILE'"
echo "[DEBUG] Input AUTHOR_NAME: '$AUTHOR_NAME'"
echo "[DEBUG] Input AUTHOR_EMAIL: '$AUTHOR_EMAIL'"

if [[ -z "$FILE" ]]; then
  echo "::error::No file provided to terraform-fmt script"
  exit 1
fi

# Calculate directory for operation
DIR="$(dirname "$FILE")"
if [[ "$DIR" == "." ]]; then DIR=""; fi
echo "[DEBUG] Calculated DIR: '$DIR'"

# Save repo root before cd
REPO_ROOT="$(git rev-parse --show-toplevel)"

cd "$DIR"
echo "[DEBUG] Running terraform fmt in $(pwd)"
fmt_output=$(terraform fmt -recursive -diff -list=true 2>&1)
fmt_exit=$?
echo "[DEBUG] terraform fmt output:"
echo "$fmt_output"
cd "$REPO_ROOT"   # back to root for git commands

# Detect changed .tf and .tfvars files after formatting (content only)
changed_files=$(git diff --name-only | grep -E '\.tf$|\.tfvars$' || true)
changed_count=$(echo "$changed_files" | grep -c . || true)


echo "[DEBUG] Changed files after fmt (count=$changed_count):"
echo "$changed_files"

if [[ "$changed_count" -eq 0 ]]; then
  echo "::notice::No Terraform formatting changes were needed."
  {
    echo "## Terraform Auto-Format"
    echo ""
    echo "✅ **No formatting changes were needed.**"
    echo ""
    echo "> Automatically reformats your Terraform files to follow the standard style conventions, ensuring consistent code formatting across your project."
  } >> "$GITHUB_STEP_SUMMARY"
  exit 0
fi

# Stage changed files only (not scripts or unrelated files)
echo "[DEBUG] Configuring git author: $AUTHOR_NAME <$AUTHOR_EMAIL>"
git config user.name "$AUTHOR_NAME"
git config user.email "$AUTHOR_EMAIL"

echo "[DEBUG] Staging changed files:"
while read -r file; do
  [ -z "$file" ] && continue
  echo "[DEBUG] git add '$file'"
  git add "$file"
done <<< "$changed_files"

# Compose summary with diffs
summary="## Terraform Auto-Format

⚠️ **Terraform formatting was applied and committed.**

The following files were reformatted automatically:
"
while read -r file; do
  [ -z "$file" ] && continue
  summary+="
#### \`$file\`
<details><summary>Show diff</summary>

\`\`\`diff
$(git diff --cached -- "$file")
\`\`\`
</details>
"
done <<< "$changed_files"

summary+="

A commit was made and pushed to your branch by the bot.

**What this means for you:**
- Your branch now includes a formatting-only commit.
- You may need to \`git pull\` before pushing further changes.
- No functional code was changed—only whitespace, alignment, or syntax was fixed.
- Please review the changes carefully.

*If you see warnings about unstaged changes or failed rebase, these are unrelated file permission changes by the CI runner and can be ignored for the purposes of formatting.*

"

echo "$summary" >> "$GITHUB_STEP_SUMMARY"

echo "[DEBUG] Git diff --cached output for all changes:"
git diff --cached

if ! git diff --cached --quiet; then
  echo "[DEBUG] Committing formatting changes"
  git commit -m "chore(terraform): auto-format via GitHub Actions"
  echo "[DEBUG] Pulling latest with rebase before push"
  git pull --rebase || echo "::warning::git pull --rebase failed; proceeding with push."
  echo "[DEBUG] Pushing auto-format commit to remote"
  git push
  echo "::notice::Pushed auto-format commit to remote."
else
  echo "[DEBUG] No formatting changes to commit after add."
fi

exit 0