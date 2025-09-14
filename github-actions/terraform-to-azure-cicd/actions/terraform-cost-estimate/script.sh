#!/usr/bin/env bash
# ====================================================================
# Script: terraform-cost-estimate/script.sh
#
# Purpose:
#   - Runs Infracost on a Terraform plan JSON file.
#   - Outputs Markdown cost summary to GitHub Actions summary.
# ====================================================================

set -euo pipefail

PLAN_JSON="${1:-tfplan.json}"

if [[ ! -f "$PLAN_JSON" ]]; then
  echo "::error::Terraform plan JSON not found: $PLAN_JSON"
  exit 1
fi

if [ -z "${INFRACOST_API_KEY:-}" ]; then
  echo "::error::INFRACOST_API_KEY environment variable not set."
  exit 1
fi

echo "[DEBUG] Running infracost breakdown for: $PLAN_JSON"

# Run Infracost breakdown with table format
infracost breakdown --path="$PLAN_JSON" --format=table --out-file=infracost.txt

if [[ -s infracost.txt ]]; then
  {
    echo "## Infracost: Estimated Monthly Cost"
    echo 
    echo "✅ Succeeded"
    echo 
    echo "> - Uses Infracost to read your plan and show costs"
    echo "> - [Learn more about Infracost](https://www.infracost.io/docs/)"
    echo "> - Always review the cost estimate before approving or merging any infrastructure changes!"
    echo
    echo '<details><summary>Show cost estimate</summary>'
    echo
    echo '```'
    cat infracost.txt
    echo '```'
    echo '</details>'
  } >> "$GITHUB_STEP_SUMMARY"
else
  echo "## 💰 Infracost: No cost data found" >> "$GITHUB_STEP_SUMMARY"
fi

echo "[DEBUG] Cost estimation complete."