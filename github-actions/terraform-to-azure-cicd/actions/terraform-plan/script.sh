#!/usr/bin/env bash

# --- Best practice for bash scripts, especially in CI/CD.
# -e: Exit immediately if any command fails.
# -u: Treat unset variables as errors.
# -o pipefail: If any command in a pipeline fails, the pipeline fails.
set -euo pipefail

# --- Parse arguments ---
FILE="${1:-}"             # Path to tfvars file
BACKEND_CONFIG="${2:-backend.tfvars}" # Path to backend config (default)
PLAN_FILE="${3:-tfplan}"  # Name for plan file

# --- If FILE variable is zero then exit
if [[ -z "$FILE" ]]; then
  echo "::error::No .tfvars file provided"
  echo "Usage: $0 <tfvars-file> [plan-file]"
  exit 1
fi

# --- Extract directory from FILE full path ---
DIR="$(dirname "$FILE")"
[[ "$DIR" == "." ]] && DIR=""
cd "$DIR"

# --- If PLAN_FILE doesn't exist in DIR then exit ---
if [[ ! -f "$BACKEND_CONFIG" ]]; then
  echo "::error::Backend config not found: $DIR"
  echo "❌ Backend config not found: $BACKEND_CONFIG" >> "$GITHUB_STEP_SUMMARY"
  exit 1
fi

# --- Debug info ---
echo "[DEBUG] FILE: '$FILE'"
echo "[DEBUG] BACKEND_CONFIG: '$BACKEND_CONFIG'"
echo "[DEBUG] PLAN_FILE: '$PLAN_FILE'"
echo "[DEBUG] DIR: '$DIR'"
echo "[DEBUG] Directory listing:"
ls -alh

# --- Debug GitHub PAT setup ---
if [ -z "${GH_PAT+x}" ]; then
  echo "[DEBUG] GH_PAT is not set"
else
  echo "[DEBUG] GH_PAT length: ${#GH_PAT}"
fi
if [[ -n "${GH_PAT:-}" ]]; then
  git config --global url."https://${GH_PAT}:x-oauth-basic@github.com/".insteadOf "https://github.com/"
fi

# ------------------------------------------------------------------------------------------------ #

echo "[DEBUG] Running terraform init"
terraform init -backend-config="$BACKEND_CONFIG" -input=false -no-color

echo "[DEBUG] Running terraform plan"
set +e
terraform plan -no-color -input=false -out="$PLAN_FILE" | tee plan_output_raw.txt
plan_exit=${PIPESTATUS[0]}
set -e

# ------------------------------------------------------------------------------------------------ #

# --- Clean output for summary: remove ANSI color codes ---
plan_output=$(sed -r 's/\x1B\[[0-9;]*[mK]//g' plan_output_raw.txt)

# --- Check for state file lock errors ---
lock_error=""
if [ $plan_exit -ne 0 ]; then
  if grep -q "Error: Error acquiring the state lock" plan_output_raw.txt || grep -q "state blob is already locked" plan_output_raw.txt; then
    lock_block=$(awk '/Error: Error acquiring the state lock/,/^$/' plan_output_raw.txt)
    [ -z "$lock_block" ] && lock_block=$(awk '/state blob is already locked/,/^$/' plan_output_raw.txt)
    [ -z "$lock_block" ] && lock_block="$(cat plan_output_raw.txt)"
    lock_error="🚨 **Terraform state is locked!**
State lock detected in backend.
You may need to manually unlock the state or wait for the lock to expire.

<details><summary>Show lock info</summary>
\`\`\`
$lock_block
\`\`\`
</details>
"
  fi
fi

# --- Set plan_result depending on plan_exit ---
if [ $plan_exit -eq 0 ]; then
  plan_result="✅ Succeeded"
else
  plan_result="❌ Failed"
fi

help=$(cat <<EOF
> - The "terraform plan" step checks what changes would be made to your Azure infrastructure if you applied your code.
> - If the plan succeeds, it means your configuration is valid and Terraform can calculate changes.
> - If the plan fails, check the output below for errors (e.g., naming issues, missing permissions, or invalid values).
> - No changes have been made to cloud resources yet—this is a dry run.
> - Review the plan output carefully before approving or applying any changes.
EOF
)

plan_details=$(cat <<EOF
<details><summary>Show terraform plan output</summary>

\`\`\`
${plan_output}
\`\`\`
</details>
EOF
)

# --- Build Markdown summary for GitHub Actions UI ---
summary=$(cat <<EOF
## Terraform Plan
${lock_error}
$plan_result
$help
$plan_details
EOF
)

# --- Write Summary to GitHub ---
echo "$summary" > "$GITHUB_STEP_SUMMARY"

# --- Fail fast if plan failed ---
if [ $plan_exit -ne 0 ]; then
  echo "::error::terraform plan failed (exit code $plan_exit)"
  exit $plan_exit
fi

# --- Export JSON plan for security scanning (Checkov, etc) ---
terraform show -json "$PLAN_FILE" > "${PLAN_FILE}.json"
echo "[DEBUG] JSON plan exported to ${PLAN_FILE}.json"
echo "[DEBUG] Directory listing:"
ls -alh