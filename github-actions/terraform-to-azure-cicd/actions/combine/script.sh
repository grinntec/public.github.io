#!/bin/bash

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
echo "[DEBUG] app_name=$app_name" >> "$GITHUB_OUTPUT"
echo "[DEBUG] env=$env" >> "$GITHUB_OUTPUT"
echo "[DEBUG] location=$location" >> "$GITHUB_OUTPUT"
echo "[DEBUG] keys=app_name,env,location" >> "$GITHUB_OUTPUT"

# --- Markdown summary for Actions UI ---
cat <<EOF >> "$GITHUB_STEP_SUMMARY"
## Extracted Values for TF State File

| Key      | Value      |
|----------|------------|
| app_name | $app_name  |
| env      | $env       |
| location | $location  |
EOF

####################
# WORKING ^^^^^^^^
####################

# --- Print the outputs for debugging (may not be readable in all contexts) ---
cat "$GITHUB_OUTPUT" || echo "[DEBUG] (GITHUB_OUTPUT not readable in this context)"

# --- Input Validation ---------------------------------------------------------
for var in APP_NAME ENV LOCATION TFVARS_FILE RESOURCE_GROUP_NAME STORAGE_ACCOUNT_NAME CONTAINER_NAME SUBSCRIPTION_ID TENANT_ID DIR; do
  if [[ -z "${!var}" ]]; then
    echo "ERROR: $var is required but not set."
    exit 1
  fi
done

# --- Debug: Print all inputs --------------------------------------------------
echo "[DEBUG] Inputs:"
printf "  %-20s %s\n" "APP_NAME:" "$APP_NAME"
printf "  %-20s %s\n" "ENV:" "$ENV"
printf "  %-20s %s\n" "LOCATION:" "$LOCATION"
printf "  %-20s %s\n" "TFVARS_FILE:" "$TFVARS_FILE"
printf "  %-20s %s\n" "RESOURCE_GROUP_NAME:" "$RESOURCE_GROUP_NAME"
printf "  %-20s %s\n" "STORAGE_ACCOUNT_NAME:" "$STORAGE_ACCOUNT_NAME"
printf "  %-20s %s\n" "CONTAINER_NAME:" "$CONTAINER_NAME"
printf "  %-20s %s\n" "SUBSCRIPTION_ID:" "$SUBSCRIPTION_ID"
printf "  %-20s %s\n" "TENANT_ID:" "$TENANT_ID"
printf "  %-20s %s\n" "DIR:" "$DIR"