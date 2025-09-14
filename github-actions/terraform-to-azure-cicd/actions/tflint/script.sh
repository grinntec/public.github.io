#!/usr/bin/env bash
set -euo pipefail

# Script: tflint/script.sh
# Purpose: Run TFLint in the directory of the provided .tfvars file, auto-fix if possible, and summarize the results for GitHub Actions.

TFVARS_FILE="$1"
DIR=$(dirname "$TFVARS_FILE")
if [[ "$DIR" == "." ]]; then DIR=""; fi

echo "[DEBUG] Running tflint in directory: '$DIR'"

if [[ ! -d "$DIR" ]]; then
  echo "::error::Directory '$DIR' does not exist"
  exit 1
fi

tflint --version || true

set +e
cd "$DIR"

# Run TFLint in fix mode (if supported), else just lint
tflint_output=$(tflint --fix --format=default --no-color 2>&1)
tflint_exit=$?
cd - >/dev/null

# Detect if TFLint made any changes by checking git diff
cd "$DIR"
fixed_files=$(git diff --name-only | grep -E '\.tf$|\.tfvars$' || true)
cd - >/dev/null

if [[ $tflint_exit -eq 0 && -z "$fixed_files" ]]; then
  # No issues found, nothing changed
  summary="## TFLint Checks

✅ **No linting issues were found.**  

> Analyzes your Terraform code for potential errors, security issues, and best-practice violations specific to your cloud provider before you deploy any changes.
"
elif [[ -n "$fixed_files" ]]; then
  # Some files were auto-fixed
  summary="## TFLint Checks

⚠️ **TFLint found and auto-fixed some issues.**  
Your code was reformatted to match style and best practices.  
Please review the changes below.

"
  for file in $fixed_files; do
    diff_content=$(git --no-pager diff "$file")
    summary+="
#### \`$file\`
<details><summary>Show diff</summary>

\`\`\`diff
$diff_content
\`\`\`
</details>
"
  done
elif [[ $tflint_exit -ne 0 ]]; then
  # Lint failed, show the error
  summary="## TFLint Checks

❌ **Linting failed.**  
TFLint found issues that could not be auto-fixed.  
Please address them manually.

<details><summary>Show TFLint output</summary>

\`\`\`
$tflint_output
\`\`\`
</details>
"
fi

echo -e "$summary" >> "$GITHUB_STEP_SUMMARY"
echo -e "$summary" > "$GITHUB_WORKSPACE/tflint-summary.md"

exit 0