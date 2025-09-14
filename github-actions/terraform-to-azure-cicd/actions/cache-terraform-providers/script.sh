#!/usr/bin/env bash
# =========================================================================================
# Script: cache-terraform-providers/script.sh
#
# Purpose:
#   - Used by the composite action to print debug information about the Terraform provider
#     cache configuration and result.
#   - Shows which plugin cache directory and lockfile pattern are being used.
#   - Lists all files matching the lockfile pattern for traceability.
#   - Reports whether the cache was hit or missed, and prints the cache key used.
#
# Usage:
#   - Called by the composite action after the cache step.
#   - Arguments:
#       $1: plugin_cache_dir (directory for provider plugins)
#       $2: lockfile_pattern (pattern for lockfile(s) used in cache key)
#       $3: cache-hit (string 'true' or 'false', from actions/cache output)
#
# Best Practices:
#   - Print all relevant config and cache status for easier troubleshooting in CI logs.
#   - Use ::group:: and ::endgroup:: for log folding in GitHub Actions UI.
# =========================================================================================

set -euo pipefail

# --- Print debug info about the cache configuration ---
echo "[DEBUG] plugin_cache_dir: $1"
echo "[DEBUG] lockfile_pattern: $2"
echo "[DEBUG] github.workspace: $GITHUB_WORKSPACE"
echo "[DEBUG] Runner OS: $RUNNER_OS"

# --- List all files matching the lockfile pattern (for traceability) ---
echo "[DEBUG] ::group::Files matching lockfile_pattern"
find . -type f -name "$(basename "$2")"
echo "[DEBUG] ::endgroup::"

# --- Report cache result (hit or miss) ---
if [[ "${3:-}" == 'true' ]]; then
  echo "[DEBUG] Terraform provider cache hit!"
  echo "::notice::Terraform provider cache hit!"
else
  echo "[DEBUG] No cache hit for Terraform providers, will populate cache."
  echo "::notice::No cache hit for Terraform providers, will populate cache."
fi

# --- Print the cache key used (for troubleshooting and traceability) ---
# Note: This is a simplified hash, not the actual key used by actions/cache if multiple files match.
echo "Cache key used: terraform-${RUNNER_OS}-$(sha256sum "$2" 2>/dev/null | awk '{print $1}')"