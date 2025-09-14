#!/usr/bin/env bash
# =========================================================================================
# Script: extract-tfvars/script.sh
#
# Purpose:
#   - Extracts app_name, env, and location from a terraform.tfvars file and exposes them as GitHub Actions outputs.
#   - Intended for use in a composite action to make these values available to downstream steps.
#
# How it works:
#   - Takes the tfvars file path as the first argument (defaults to terraform.tfvars).
#   - Takes the working directory as the second argument (defaults to .).
#   - Changes to the working directory, validates the file exists, prints its contents for debugging.
#   - Extracts app_name, env, and location using grep and sed, ignoring commented lines.
#   - Sets these as outputs for GitHub Actions and prints a Markdown summary.
#
# Why this is needed:
#   - Allows dynamic, environment-driven workflows in CI/CD by extracting tfvars values at runtime.
#   - Avoids hardcoding or duplicating tfvars values in workflow YAML.
#
# Best Practices:
#   - Use set -euo pipefail for safety.
#   - Print debug output for traceability.
# =========================================================================================

set -euo pipefail

tfvars_file="${1:-terraform.tfvars}"      # Path to the tfvars file (default: terraform.tfvars)
working_directory="${2:-.}"               # Directory to run extraction in (default: .)

echo "[DEBUG] tfvars_file: $tfvars_file"
echo "[DEBUG] working_directory: $working_directory"

cd "$working_directory"

# --- Validate the tfvars file exists ---
if [[ ! -f "$tfvars_file" ]]; then
  echo "::error file=$tfvars_file::File not found"
  exit 1
fi

# --- Print the contents of the tfvars file for debugging ---
echo "[DEBUG] Listing contents of $tfvars_file:"
cat "$tfvars_file"
echo "---EOF---"

# --- Extract values using grep and sed ---
# - Only matches non-commented lines.
# - Handles both quoted and unquoted values.
app_name=$(grep -E '^[[:space:]]*app_name[[:space:]]*=' "$tfvars_file" | grep -v '^#' | sed -E 's/^[^=]+=[[:space:]]*"?([^"]*)"?/\1/' | tail -n1)
env=$(grep -E '^[[:space:]]*env[[:space:]]*=' "$tfvars_file" | grep -v '^#' | sed -E 's/^[^=]+=[[:space:]]*"?([^"]*)"?/\1/' | tail -n1)
location=$(grep -E '^[[:space:]]*location[[:space:]]*=' "$tfvars_file" | grep -v '^#' | sed -E 's/^[^=]+=[[:space:]]*"?([^"]*)"?/\1/' | tail -n1)

# --- Set outputs for GitHub Actions ---
echo "[DEBUG] Captured Output Values"
echo "app_name=$app_name" >> "$GITHUB_OUTPUT"
echo "env=$env" >> "$GITHUB_OUTPUT"
echo "location=$location" >> "$GITHUB_OUTPUT"

# --- Print the outputs for debugging (may not be readable in all contexts) ---
cat "$GITHUB_OUTPUT" || echo "[DEBUG] (GITHUB_OUTPUT not readable in this context)"