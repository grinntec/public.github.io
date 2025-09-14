#!/usr/bin/env bash
# =========================================================================================
# Script: ensure-tf-lockfile-exists/script.sh
#
# Purpose:
#   - Ensures every directory containing .tf files has a .terraform.lock.hcl.
#   - Runs 'terraform init -backend=false' in any directory missing the lockfile.
#
# Why this is needed:
#   - The .terraform.lock.hcl file locks provider versions for reproducible, deterministic
#     Terraform runs. Without it, provider versions may drift, leading to unexpected results
#     or CI/CD failures.
#   - Some CI/CD pipelines or Terraform commands (e.g., validate, plan) require the lockfile
#     to exist, even if you are not applying changes.
#   - This script ensures all relevant directories are ready for safe, consistent automation.
#
# How it works:
#   - Finds all unique directories with .tf files (handles spaces safely).
#   - For each, checks for .terraform.lock.hcl and runs init if missing.
#   - Reports which directories were initialized.
#
# Best Practices:
#   - Use set -euo pipefail for safety.
#   - Print clear debug and error messages for CI/CD logs.
# =========================================================================================

set -euo pipefail

# Array to track which directories were initialized
initialized_dirs=()

# Find all unique directories containing .tf files, handling spaces safely
while IFS= read -r -d '' dir; do
  if [[ ! -f "$dir/.terraform.lock.hcl" ]]; then
    echo "[DEBUG] Initializing $dir to create lockfile"
    if terraform -chdir="$dir" init -backend=false; then
      initialized_dirs+=("$dir")
    else
      echo "[DEBUG] Failed to initialize $dir" >&2
      echo "::error::⚠️ Failed to initialize $dir" >&2
      exit 1
    fi
  fi
done < <(find . -type f -name "*.tf" -print0 | xargs -0 -n1 dirname | sort -u | tr '\n' '\0')

# Report results
if (( ${#initialized_dirs[@]} > 0 )); then
  echo "[DEBUG] Lockfiles created in: ${initialized_dirs[*]}"
  echo "::notice::Lockfiles created in: ${initialized_dirs[*]}"
else
  echo "[DEBUG] All necessary Terraform lockfiles are present."
  echo "::notice::All necessary Terraform lockfiles are present."
fi