# Terraform-to-Azure CI/CD Workflows

This directory contains reusable and reference GitHub Actions workflows for automating Terraform deployments to Azure in a modular, environment-driven manner. These workflows form the backbone of a best-practice CI/CD pipeline, providing targeted change detection and robust processing for every environment or stack defined by a `.tfvars` file.

---

## Workflow Overview

### 1. **Detect Changed `.tfvars` Files**

- **Purpose:**  
  Detects changes to any `terraform.tfvars` file in PRs or direct pushes to `main`.
- **How it works:**  
  - Uses a custom composite action to robustly detect changed `.tfvars` files.
  - Outputs a JSON array of changed files.
  - Triggers downstream matrix jobs for each file.
- **Reference:**  
  [`detect-changed-tfvars-files.yaml`](./detect-changed-tfvars-files.yaml)

### 2. **Process Each Changed `.tfvars` File**

- **Purpose:**  
  For every changed file, runs a complete pipeline including formatting, linting, validation, planning, security scan, cost estimate, and deploy/destroy.
- **How it works:**  
  - Receives a single `.tfvars` path as input.
  - Orchestrates all modular composite actions in the correct directory, passing secrets as needed.
  - Drives environment-specific CI/CD: each matrix job is fully isolated per environment.
- **Reference:**  
  [`process-changed-tfvars-files.yaml`](./process-changed-tfvars-files.yaml)

---

## Key Features

- **Matrix-driven automation:**  
  Dynamically creates jobs for every changed `.tfvars` file—no hardcoded environments.
- **Composable actions:**  
  Each step uses a modular composite action for maximum reuse and traceability.
- **Security-first:**  
  Only necessary secrets are passed to each job; uses GitHub OIDC and least-privilege permissions.
- **Fail-fast:**  
  Jobs fail immediately on error, preventing bad deployments.
- **Auditability:**  
  All steps write clear Markdown summaries to the Actions UI, so every run is traceable.

---

## Usage

These workflows are designed to be used together:

1. **Detect workflow** is triggered on push or PR if any `.tfvars` file changes.
2. **Process workflow** is called as a matrix job, once per changed file.

**You can trigger these workflows manually, on push, or on PR.**

---

## Best Practices

- **Do not hardcode environment names**—let the matrix drive all per-env jobs.
- **Always run checkout with `fetch-depth: 0`** for accurate change detection.
- **Pass secrets as inputs, not environment variables, for safer credential handling.**
- **Use reusable workflows** to separate detection and processing for scalability.
- **Review Markdown summaries** after every run for audit and troubleshooting.

---

## References

- [Architecture Overview](https://www.grinntec.net/architecture/terraform-to-azure-cicd/)
- [Design Pattern: Detect](https://www.grinntec.net/design-patterns/github-actions/automate-terraform-deployment-detect/)
- [Design Pattern: Process](https://www.grinntec.net/design-patterns/github-actions/automate-terraform-deployment-process/)
- [Terraform CI/CD on Grinntec](https://www.grinntec.net/tags/#terraform)

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
