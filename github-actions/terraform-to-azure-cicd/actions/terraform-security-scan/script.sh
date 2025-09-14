#!/usr/bin/env bash

# --- Best practice for bash scripts, especially in CI/CD.
# -e: Exit immediately if any command fails.
# -u: Treat unset variables as errors.
# -o pipefail: If any command in a pipeline fails, the pipeline fails.
set -euo pipefail

# --- Parse arguments ---
FILE="${1:-}"                 # Path to .tfvars file (required)
PLAN_FILE="${2:-tfplan}"      # Path to plan file (default: tfplan in same dir)
PLAN_FILE_JSON="${PLAN_FILE}.json"  # Path to JSON plan file

# --- If FILE variable is zero then exit ---
if [[ -z "$FILE" ]]; then
  echo "::error::No .tfvars file provided"
  echo "Usage: $0 <tfvars-file> [plan-file]"
  exit 1
fi

# --- Extract directory ---
DIR="$(dirname "$FILE")"
[[ "$DIR" == "." ]] && DIR=""
cd "$DIR"

# --- Check required files exist ---
if [[ ! -f "$PLAN_FILE" ]]; then
  echo "::error::Plan file '$PLAN_FILE' not found in directory '$DIR'"
  echo "❌ Plan file not found: $PLAN_FILE" > "$GITHUB_STEP_SUMMARY"
  exit 1
fi

if [[ ! -f "$PLAN_FILE_JSON" ]]; then
  echo "::error::Plan file '$PLAN_FILE_JSON' not found in directory '$DIR'"
  echo "❌ Plan file not found: $PLAN_FILE_JSON" > "$GITHUB_STEP_SUMMARY"
  exit 1
fi

# --- Debug info ---
echo "[DEBUG] .tfvars file: $FILE"
echo "[DEBUG] Plan file: $PLAN_FILE"
echo "[DEBUG] Plan file JSON: $PLAN_FILE_JSON"
echo "[DEBUG] Directory: $DIR"
echo "[DEBUG] Directory listing:"
ls -alh

# --- Run Checkov against the JSON plan file ---
set +e
checkov_output=$(checkov -f "$PLAN_FILE_JSON" -o cli 2>&1)
checkov_exit=$?
set -e

# --- Set result and help text ---
if [ $checkov_exit -eq 0 ]; then
  checkov_result="✅ Succeeded"
else
  checkov_result="❌ Failed"
fi

help=$(cat <<EOF
> - Checkov scanned your Terraform plan (resolved resources) for misconfigurations and security issues.
> - If errors are found, review the findings below and fix all critical issues before deploying.
> - No success information is written to stdout as shown in the verbose output below.
EOF
)

checkov_details=$(cat <<EOF
<details><summary>Show Checkov verbose output</summary>

\`\`\`
$checkov_output
\`\`\`
</details>
EOF
)

# --- Build Markdown summary ---
summary=$(cat <<EOF
## Checkov Security Scan (Terraform Plan)
$checkov_result
$help
$checkov_details
EOF
)

# --- Write summary to GitHub Actions UI ---
echo "$summary" > "$GITHUB_STEP_SUMMARY"

# --- Fail fast if Checkov found issues ---
if [[ $checkov_exit -ne 0 ]]; then
  echo "::error::Checkov scan found issues (exit code $checkov_exit)"
  exit $checkov_exit
fi