#!/usr/bin/env bash
# =========================================================================================
# Script: show-file/script.sh
#
# Purpose:
#   - Used by the 'show-file' composite GitHub Action to print and output information
#     about a specified .tfvars file.
#   - Outputs the file path and its directory for traceability in CI/CD workflows.
#   - Optionally writes a summary for the Actions UI.
#
# How it works:
#   - Takes the tfvars file path as the first argument.
#   - Validates input and checks file existence.
#   - Sets outputs for downstream steps.
#   - Adds a Markdown summary for easy inspection in the Actions UI.
#
# Best Practices:
#   - Do not print secrets or sensitive values from tfvars files.
#   - Use outputs for modular workflows.
# =========================================================================================

set -euo pipefail

# Parse and Validate Input Arguments
tfvars_file="${1:-}"
# Reads the first argument as the path to the tfvars file.
# The :- means "if unset, use empty string" (avoids 'unbound variable' error).

if [[ -z "$tfvars_file" ]]; then
  echo "::error::No tfvars file provided to show-file.sh"
  exit 1
fi
# If no argument is given, print a GitHub Actions error and exit.

# Print Debug Info (for CI/CD)
echo "[DEBUG] tfvars_file: $tfvars_file"
echo "tfvars_file=$tfvars_file" >> "$GITHUB_OUTPUT"
# For traceability, print and also set as an output for downstream steps.

# Calculate and Output Directory Info
dir="$(dirname "$tfvars_file")"
echo "[DEBUG] dir: $dir"
echo "dir=$dir" >> "$GITHUB_OUTPUT"
# Use 'dirname' to get the directory where the tfvars file is (for modular workflows).

# Check File Existence and Print Outcome
if [[ -f "$tfvars_file" ]]; then
  echo "::notice::Found tfvars file: $tfvars_file"
else
  echo "::warning::tfvars file not found: $tfvars_file"
fi
# Use conditional test (-f) to check if the file exists.
# Print a GitHub Actions 'notice' or 'warning' to the workflow log.

# For further debugging, you might cat the file, add markdown summaries, or fail hard.
if [[ -f "$tfvars_file" ]]; then
  {
    echo "## TFVARS File Being Processed"
    echo ""
    echo "📄 \`$tfvars_file\`"
  } >> "$GITHUB_STEP_SUMMARY"
fi