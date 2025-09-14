#!/usr/bin/env bash
# =========================================================================================
# Script: read-ci-mode/script.sh
#
# Purpose:
#   - Used by the 'read-ci-mode' composite GitHub Action to extract the value of `ci_mode`
#     from a given .tfvars file.
#   - Outputs the value as a GitHub Actions output for use in downstream workflow steps.
#   - Adds a concise summary for traceability in the Actions UI.
#
# How it works:
#   - Takes the .tfvars file path as the first argument.
#   - Validates the file exists.
#   - Uses awk to extract the value of ci_mode (supports spaces and double quotes).
#   - Sets the output variable `ci_mode` and writes a summary.
#   - Emits errors and fails if the file is missing or ci_mode is not found.
#
# Best Practices:
#   - Only outputs the ci_mode value (no secrets).
#   - Fails fast and provides clear error messages for CI/CD reliability.
# =========================================================================================

set -euo pipefail

# --- Parse Arguments ---
tfvars_file="${1:-}"  # First argument: path to the tfvars file (empty string if unset)
dir="$(dirname "$tfvars_file")"  # Get the directory containing the tfvars file
if [[ "$dir" == "." ]]; then dir=""; fi  # Normalize to empty string if at repo root

echo "[DEBUG] tfvars_file: $tfvars_file"
echo "[DEBUG] dir: $dir"

# --- Check if the tfvars file exists ---
if [[ ! -f "$tfvars_file" ]]; then
  echo "::error file=$tfvars_file::File not found"
  echo "## CI Mode" >> "$GITHUB_STEP_SUMMARY"
  echo "**❌ No tfvars file found at \`$tfvars_file\`**" >> "$GITHUB_STEP_SUMMARY"
  exit 1
fi

# --- Extract ci_mode value with awk (supports spaces and double quotes) ---
ci_mode=$(awk -F'ci_mode *= *"' 'match($0, /ci_mode *= *"([^"]+)"/, arr) { print arr[1]; exit }' "$tfvars_file" || true)

# --- Handle missing ci_mode value ---
if [[ -z "$ci_mode" ]]; then
  echo "::error file=$tfvars_file::No ci_mode found in $tfvars_file"
  echo "[DEBUG] ci_mode not found in $tfvars_file"
  echo "ci_mode=" >> "$GITHUB_OUTPUT"  # Set empty output for downstream safety
  echo "## CI Mode" >> "$GITHUB_STEP_SUMMARY"
  echo "**❌ No \`ci_mode\` found in \`$tfvars_file\`**" >> "$GITHUB_STEP_SUMMARY"
  exit 1
fi

# --- Output ci_mode to GitHub Actions ---
echo "ci_mode=$ci_mode" >> "$GITHUB_OUTPUT"

# --- Concise summary: highlight ci_mode value ---
echo "## CI Mode" >> "$GITHUB_STEP_SUMMARY"
echo "📝 \`$ci_mode\`" >> "$GITHUB_STEP_SUMMARY"
echo "" >> "$GITHUB_STEP_SUMMARY"
echo "> PLAN will run \`terraform plan\`" >> "$GITHUB_STEP_SUMMARY"
echo "> APPLY will run \`terraform apply\`" >> "$GITHUB_STEP_SUMMARY"
echo "> DESTROY will run \`terraform destroy\`" >> "$GITHUB_STEP_SUMMARY"

# --- Debug output and notice for CI logs ---
echo "[DEBUG] ci_mode: '$ci_mode'"
echo "::notice::CI Mode Detected: $ci_mode"