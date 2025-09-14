#!/usr/bin/env bash
# =========================================================================================
# Script: create-terraform-backend-config-file/script.sh
#
# Purpose:
#   - Writes a backend.tfvars file for Terraform Azure backend configuration.
#   - Ensures state is uniquely keyed per environment/directory.
#   - Meant to be called by the composite action with 10 required arguments.
# =========================================================================================

set -euo pipefail

# Argument validation – require exactly 10 arguments
if [[ $# -ne 10 ]]; then
  echo "ERROR: Expected 10 arguments, got $#." >&2
  echo "Usage: $0 <APP_NAME> <ENV> <LOCATION> <TFVARS_FILE> <RESOURCE_GROUP_NAME> <STORAGE_ACCOUNT_NAME> <CONTAINER_NAME> <SUBSCRIPTION_ID> <TENANT_ID> <DIR>" >&2
  exit 1
fi

# Assign input args to descriptive variable names
APP_NAME="$1"
ENV="$2"
LOCATION="$3"
TFVARS_FILE="$4"
RESOURCE_GROUP_NAME="$5"
STORAGE_ACCOUNT_NAME="$6"
CONTAINER_NAME="$7"
SUBSCRIPTION_ID="$8"
TENANT_ID="$9"
DIR="${10}"

# Validate none are empty
for var in APP_NAME ENV LOCATION TFVARS_FILE RESOURCE_GROUP_NAME STORAGE_ACCOUNT_NAME CONTAINER_NAME SUBSCRIPTION_ID TENANT_ID DIR; do
  if [[ -z "${!var}" ]]; then
    echo "ERROR: $var is required but not set." >&2
    exit 1
  fi
done

# --- Calculate GIT_PATH: directory of tfvars file, for unique state key ---
# Remove '/terraform.tfvars' from the end, normalize slashes
GIT_PATH="$TFVARS_FILE"
if [[ "$GIT_PATH" == */terraform.tfvars ]]; then
  GIT_PATH="${GIT_PATH%/terraform.tfvars}"
elif [[ "$GIT_PATH" == *terraform.tfvars ]]; then
  GIT_PATH="${GIT_PATH%terraform.tfvars}"
fi
GIT_PATH="${GIT_PATH%/}"   # Remove trailing slash

# --- Construct backend key based on directory and naming convention ---
if [[ -z "$GIT_PATH" || "$GIT_PATH" == "." ]]; then
  # For root, use a simpler key
  KEY="/${APP_NAME}/${ENV}/${LOCATION}.tfstate"
else
  GIT_PATH="${GIT_PATH#./}"  # Remove leading './'
  KEY="${ENV}/${GIT_PATH}/${APP_NAME}.tfstate"
fi

# --- Write backend.tfvars in the specified DIR ---
BACKEND_PATH="${DIR}/backend.tfvars"
mkdir -p "${DIR}"

cat > "$BACKEND_PATH" <<EOF
resource_group_name  = "${RESOURCE_GROUP_NAME}"
storage_account_name = "${STORAGE_ACCOUNT_NAME}"
container_name       = "${CONTAINER_NAME}"
key                  = "${KEY}"
subscription_id      = "${SUBSCRIPTION_ID}"
tenant_id            = "${TENANT_ID}"
EOF

echo "::notice file=$BACKEND_PATH::backend.tfvars created and ready for use"
echo "backend_path=$BACKEND_PATH" >> "$GITHUB_OUTPUT"

