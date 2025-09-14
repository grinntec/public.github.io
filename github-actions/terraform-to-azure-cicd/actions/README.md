# Terraform-to-Azure CI/CD GitHub Actions

This directory contains a modular suite of **composite GitHub Actions** that enable robust, scalable, and secure CI/CD pipelines for Terraform-based Azure infrastructure. These actions are designed to work together or independently, supporting best practices like change detection, environment-driven configuration, automated linting/formatting, security scanning, cost estimation, and safe deployment/teardown.

---

## Overview

Each action is self-contained, with clear inputs/outputs, traceable logging, and actionable Markdown summaries written to the GitHub Actions UI. They are intended to be used in a [targeted Terraform deployment workflow](https://www.grinntec.net/architecture/terraform-to-azure-cicd/), where every changed `.tfvars` file triggers a complete, environment-specific automation pipeline.

**Reference Patterns:**
- [Architecture Overview](https://www.grinntec.net/architecture/terraform-to-azure-cicd/)
- [Detect Pattern](https://www.grinntec.net/design-patterns/github-actions/automate-terraform-deployment-detect/)
- [Process Pattern](https://www.grinntec.net/design-patterns/github-actions/automate-terraform-deployment-process/)

---

## Available Actions

| Action | Description |
|--------|-------------|
| **detect-changed-tfvars-files** | Detects which `.tfvars` files changed in PRs or direct pushes, outputs a JSON array for matrix jobs. |
| **extract-tfvars** | Extracts key variables (`app_name`, `env`, `location`) from a `terraform.tfvars` file as step outputs. |
| **read-ci-mode** | Reads the `ci_mode` value from a `.tfvars` file to drive conditional logic in workflows. |
| **show-file** | Prints the file path and directory of the `.tfvars` file being processed, for traceability. |
| **configure-git-private-modules** | Sets up `git` with a GitHub PAT for private Terraform module access. |
| **ensure-tf-lockfile-exists** | Ensures every Terraform directory has a `.terraform.lock.hcl` (runs `terraform init -backend=false` if missing). |
| **cache-terraform-providers** | Caches provider plugins using lockfile hashes for fast, reliable CI/CD runs. |
| **create-terraform-backend-config-file** | Generates a modular `backend.tfvars` file for Azure storage, keyed per environment. |
| **build-matrix** | Transforms a JSON map of `{dir:mode}` into a matrix array for dynamic job creation. |
| **terraform-fmt** | Runs `terraform fmt -recursive`, commits and pushes formatting changes, and summarizes diffs. |
| **tflint** | Runs [TFLint](https://github.com/terraform-linters/tflint) for linting and auto-fix of code style and best practices. |
| **terraform-validate** | Runs `terraform validate` to ensure syntax and structural correctness of Terraform code. |
| **terraform-plan** | Runs `terraform plan` with backend config, handles state lock errors, and exports a JSON plan for further scanning. |
| **terraform-security-scan** | Runs [Checkov](https://www.checkov.io/) against the JSON plan for misconfigurations and security issues. |
| **terraform-cost-estimate** | Runs [Infracost](https://www.infracost.io/) against the JSON plan for monthly cost estimation. |
| **terraform-apply** | Runs `terraform apply` using the generated plan file, with detailed output and error handling. |
| **terraform-destroy** | Runs `terraform destroy` to teardown resources, with full summary and audit trail. |
| **combine** | Utility for extracting multiple values from a tfvars file and setting outputs (used in backend config). |

---

## Best Practices

- **Composable:** Use actions together for a full pipeline, or individually for targeted operations.
- **Matrix-driven:** Pair with the detect/build-matrix pattern for per-environment or per-stack automation.
- **Security:** Always use workflow secrets for sensitive values (GitHub PATs, Azure credentials).
- **Traceability:** Actions output concise Markdown summaries for audit and debugging.
- **Fail-fast:** Most actions are designed to fail early with actionable error messages.

---

## Example Workflow

See [process-changed-tfvars-files.yaml](../workflows/process-changed-tfvars-files.yaml) for a complete example of how these actions are orchestrated in a matrix job.

---

## Documentation

Each action has its own README explaining:
- Purpose and use case
- Inputs and outputs
- Example usage
- Implementation details and best practices
- Troubleshooting tips

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
