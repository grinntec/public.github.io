#!/usr/bin/env bash
# =========================================================================================
# Script: configure-git-private-modules/script.sh
#
# Purpose:
#   - Configures git to use a GitHub Personal Access Token (PAT) for accessing private
#     Terraform modules hosted on GitHub.
#   - Verifies that the configuration is set and outputs a status for downstream steps.
#
# Usage:
#   - Expects the environment variable GITHUB_TOKEN to be set (do not echo this value).
#   - Intended for use in CI/CD pipelines or as part of a composite GitHub Action.
#
# How it works:
#   - Sets a global git config to rewrite all https://github.com URLs to use the PAT.
#   - Checks that the config was set and redacts the token in any debug output.
#   - Sets a GitHub Actions output variable 'configured' to 'true' or 'false'.
#   - Emits a notice for success or failure.
#
# Security:
#   - Never prints the PAT to logs.
#   - Redacts any accidental token in debug output.
# =========================================================================================

set -euo pipefail

# --- Validate input: Ensure GITHUB_TOKEN is set ---
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "::error::GITHUB_TOKEN environment variable is not set"
  echo "configured=false" >> "$GITHUB_OUTPUT"
  exit 1
fi

# --- Configure git to use the PAT for github.com URLs (secret never echoed) ---
git config --global url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/".insteadOf "https://github.com/"

# --- Check if the config now exists (but don't echo the secret) ---
config_entry="$(git config --global --get-regexp '^url\..*github\.com.*\.insteadOf$' || true)"
if [[ -n "$config_entry" ]]; then
  echo "[DEBUG] git config for private modules was set:"
  # Redact any accidental token in output
  echo "[DEBUG] $config_entry" | sed 's#https://[^:]*:x-oauth-basic@github.com#https://[REDACTED]@github.com#g'
  echo "::notice::GitHub PAT Access Configured"
  echo "configured=true" >> "$GITHUB_OUTPUT"
else
  echo "[DEBUG] git config for private modules NOT set!"
  echo "::notice::GitHub PAT Access NOT Configured"
  echo "configured=false" >> "$GITHUB_OUTPUT"
  exit 1
fi