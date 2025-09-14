#!/usr/bin/env bash
set -euo pipefail

# =========================================================================================
# Script: detect-changed-tfvars-files/script.sh
#
# Purpose:
#   Detect which .tfvars files have changed in this commit/PR, output as a JSON array for
#   downstream GitHub Actions workflow steps.
#
# How it works:
#   - On main branch: compares origin/main...HEAD to find all changed files.
#   - On PR/feature branch: diffs against the base branch to find all .tfvars files changed in the PR.
#   - Always outputs a JSON array (empty if none).
#
# Usage:
#   Intended to be run as part of the composite action 'detect-changed-tfvars-files'.
#
# Dependencies:
#   - jq (for JSON formatting; pre-installed on GitHub runners)
#
# Output:
#   - Sets the 'changed_tfvars' output for the composite action.
# =========================================================================================

#!/usr/bin/env bash
set -euo pipefail

branch_name=$(git rev-parse --abbrev-ref HEAD)
echo "[DEBUG] branch_name: $branch_name"

# Always fetch latest to avoid missing bot commits
git fetch origin main

if [ "$branch_name" = "main" ]; then
  echo "[DEBUG] Running: git diff --name-only HEAD~1 HEAD"
  changed_files=$(git diff --name-only HEAD~1 HEAD | grep 'terraform.tfvars$' | sort -u || true)
else
  base_branch="origin/main"
  if [ -n "${GITHUB_BASE_REF:-}" ]; then
    base_branch="origin/${GITHUB_BASE_REF}"
  fi
  echo "[DEBUG] Running: git diff --name-only $base_branch...HEAD"
  changed_files=$(git diff --name-only "$base_branch"...HEAD | grep 'terraform.tfvars$' | sort -u || true)
fi

echo "[DEBUG] changed_files (filtered):"
echo "$changed_files"

# Convert to JSON array
if [[ -z "$changed_files" ]]; then
  json_files="[]"
else
  json_files=$(echo "$changed_files" | jq -R . | jq -s -c)
fi
echo "[DEBUG] json_files (final JSON array): $json_files"

echo "changed_tfvars<<EOF" >> "$GITHUB_OUTPUT"
echo "$json_files" >> "$GITHUB_OUTPUT"
echo "EOF" >> "$GITHUB_OUTPUT"