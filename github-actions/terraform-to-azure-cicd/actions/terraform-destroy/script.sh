#!/usr/bin/env bash
set -euo pipefail

FILE="$1"  # Path to .tfvars file or module file

# --- Directory setup ---
DIR="$(dirname "$FILE")"
if [[ "$DIR" == "." ]]; then DIR=""; fi
echo "[DEBUG] Calculated DIR: '$DIR'"

# --- Debug info about GitHub PAT ---
if [ -z "${GH_PAT+x}" ]; then
  echo "[DEBUG] GH_PAT is not set"
else
  echo "[DEBUG] GH_PAT length: ${#GH_PAT}"
fi

# --- Configure git for private modules if needed ---
if [[ -n "${GH_PAT:-}" ]]; then
  git config --global url."https://${GH_PAT}:x-oauth-basic@github.com/".insteadOf "https://github.com/"
fi

cd "$DIR"

echo "[DEBUG] Listing files in directory: '$DIR'"
ls -alh

echo "[DEBUG] Running terraform destroy in '$DIR'"
set +e
terraform destroy -auto-approve -no-color | tee destroy_output_raw.txt
destroy_exit=${PIPESTATUS[0]}
set -e

# Strip ANSI escape codes for summary (even though -no-color should handle it)
destroy_output=$(sed -r 's/\x1B\[[0-9;]*[mK]//g' destroy_output_raw.txt)

if [ $destroy_exit -eq 0 ]; then
  destroy_result="✅ Succeeded"
else
  destroy_result="❌ Failed"
fi

destroy_help=$(cat <<EOF

> - The "terraform destroy" step removes the Azure resources managed by your configuration.
> - If destroy **succeeds** (✅), your cloud resources have been deleted.
> - If destroy **fails** (❌), review the output below for errors (e.g., state lock, missing permissions, dependencies).
> - **Warning:** Destroy is irreversible. Review the plan and output before running in production!
> - Check the Azure Portal to confirm all resources were removed.

EOF
)

destroy_details=$(cat <<EOF
<details><summary>Show terraform destroy output</summary>

\`\`\`
$destroy_output
\`\`\`
</details>
EOF
)

summary=$(cat <<EOF
## Terraform Destroy

$destroy_result

$destroy_help

$destroy_details
EOF
)

echo "$summary" >> "$GITHUB_STEP_SUMMARY"

exit $destroy_exit