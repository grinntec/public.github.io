#!/usr/bin/env bash

# --- Best practice for bash scripts, especially in CI/CD.
# -e: Exit immediately if any command fails.
# -u: Treat unset variables as errors.
# -o pipefail: If any command in a pipeline fails, the pipeline fails.
set -euo pipefail

# --- Parse arguments ---
FILE="${1:-}"             # Path to .tfvars file (required)
PLAN_FILE="${2:-tfplan}"  # Path to plan file (default: tfplan in same dir)

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
if [[ ! -f "$PLAN_FILE" ]]; then
  echo "::error::Plan file '$PLAN_FILE' not found in directory '$DIR'"
  echo "❌ Plan file not found: $PLAN_FILE" >> "$GITHUB_STEP_SUMMARY"
  exit 1
fi

# --- Debug info ---
echo "[DEBUG] .tfvars file: $FILE"
echo "[DEBUG] Plan file: $PLAN_FILE"
echo "[DEBUG] Directory: $DIR"
echo "[DEBUG] Directory listing:"
ls -alh

# --- Debug GitHub PAT setup ---
# Required to pull the reusable module from GitHub
if [ -z "${GH_PAT+x}" ]; then # Checks if GH_PAT is set and/or empty or unset
  echo "[DEBUG] GH_PAT is not set"
else
  echo "[DEBUG] GH_PAT length: ${#GH_PAT}" # For security reason only print length to validate variable is not empty
fi
if [[ -n "${GH_PAT:-}" ]]; then # Runs only if variable is set and not empty
  git config --global url."https://${GH_PAT}:x-oauth-basic@github.com/".insteadOf "https://github.com/" # Use token for authentication instead of prompting for username/password
fi

# ------------------------------------------------------------------------------------------------ #

# --- Run Terraform Apply ---
echo "[DEBUG] Running terraform apply with plan file '$PLAN_FILE'"
set +e # temporarily disable exit on error
terraform apply -auto-approve "$PLAN_FILE" | tee apply_output_raw.txt
apply_exit=${PIPESTATUS[0]}
set -e # re-enable exit on error

# ------------------------------------------------------------------------------------------------ #

# --- Clean output for summary ---
# Remove ANSI color codes (and other terminal formatting escape sequences
apply_output=$(sed -r 's/\x1B\[[0-9;]*[mK]//g' apply_output_raw.txt)

# --- Set apply_result depending on apply_exit ---
if [ $apply_exit -eq 0 ]; then
  apply_result="✅ Succeeded"
else
  apply_result="❌ Failed"
fi

# Help text for users used in summary
help=$(cat <<EOF

> - The "terraform apply" step applies the planned changes to your Azure infrastructure.
> - If apply succeeds, your cloud resources have been updated.
> - If apply fails, review the output below for errors (e.g., state lock, permissions, or resource conflicts).
> - Only run apply after carefully reviewing the plan.
> - Check the Azure Portal for resource status if unsure.
EOF
)

# Details from command
apply_details="
<details><summary>Show terraform apply output</summary>
\`\`\`
$apply_output
\`\`\`
</details>
"

# --- Build Markdown summary for GitHub Actions UI ---
summary=$(cat <<EOF
## Terraform Apply
$apply_result
$help
$apply_details
EOF
)

# --- Write Summary to GitHub ---
echo "$summary" >> "$GITHUB_STEP_SUMMARY"

# --- Fail fast if apply failed ---
if [ $apply_exit -ne 0 ]; then
  echo "::error::terraform apply failed (exit code $apply_exit)"
  exit $apply_exit
fi