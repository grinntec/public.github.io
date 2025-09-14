#!/usr/bin/env bash
set -euo pipefail

# Script: terraform-validate/script.sh
# Purpose: Run 'terraform validate' in a target directory, summarize results for GitHub Actions summary, and help users understand outcomes.

TFVARS_FILE="${1:-}"

if [[ -z "$TFVARS_FILE" ]]; then
  echo "::error::No tfvars file provided"
  exit 1
fi

DIR=$(dirname "$TFVARS_FILE")
if [[ "$DIR" == "." ]]; then DIR=""; fi

# Debug: Print GH_PAT length (do NOT print the token itself!)
if [ -z "${GH_PAT+x}" ]; then
  echo "[DEBUG] GH_PAT is not set"
else
  echo "[DEBUG] GH_PAT length: ${#GH_PAT}"
fi

# Configure git for private modules if GH_PAT is set
if [[ -n "${GH_PAT:-}" ]]; then
  git config --global url."https://${GH_PAT}:x-oauth-basic@github.com/".insteadOf "https://github.com/"
fi

cd "$DIR"

echo "[DEBUG] Running terraform init in '$DIR'"
terraform init -backend=false -input=false -no-color

echo "[DEBUG] Running terraform validate in '$DIR'"
validate_output=$(terraform validate -no-color 2>&1)
validate_exit=$?

if [ $validate_exit -eq 0 ]; then
  # Success
  summary="## Terraform Validate

✅ **Your Terraform code passed validation checks**

> Checks your Terraform configuration files for syntax errors and internal consistency, ensuring your code is structurally correct before planning or applying changes.
"
else
  # Failure
  summary="## Terraform Validate

❌ **Your Terraform code failed validation checks**  

Terraform found issues with your configuration.

<details><summary>Show terraform validate output</summary>

\`\`\`
$validate_output
\`\`\`
</details>

**What should you do?**
- Review the errors above and fix them in your Terraform code.
- Validation checks for syntax errors, missing variables, and logical issues before you run plan/apply.
"
fi

echo -e "$summary" >> "$GITHUB_STEP_SUMMARY"

if [ $validate_exit -ne 0 ]; then
  echo "::error::terraform validate failed (exit code $validate_exit)"
  exit 1
fi