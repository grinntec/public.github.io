# Terraform-to-Azure CI/CD Automation

This directory contains the **modular building blocks** for a robust, environment-driven CI/CD pipeline that manages Terraform infrastructure on Azure. The workflow detects changes to `terraform.tfvars` files in pull requests or direct pushes to `main`, then triggers targeted processing for each changed file—enabling per-environment validation, linting, planning, security scanning, cost estimation, and deployment.

---

## Overview

- **Change Detection:**  
  Scans for changed `terraform.tfvars` files in PRs and direct commits (see [`workflows/detect-changed-tfvars-files.yaml`](./workflows/detect-changed-tfvars-files.yaml)).
- **Targeted Processing:**  
  For each changed file, launches a full pipeline (see [`workflows/process-changed-tfvars-files.yaml`](./workflows/process-changed-tfvars-files.yaml))—formatting, linting, validation, planning, security scan, cost estimate, and conditional apply/destroy.
- **Matrix-Driven:**  
  All jobs are driven by a matrix of changed files, so each environment, stack, or directory is processed independently and in parallel.
- **Composable Actions:**  
  Each step uses a composite GitHub Action from [`actions/`](./actions/) for traceability and modularity.
- **Best Practice Patterns:**  
  Implements [detect](https://www.grinntec.net/design-patterns/github-actions/automate-terraform-deployment-detect/) and [process](https://www.grinntec.net/design-patterns/github-actions/automate-terraform-deployment-process/) patterns for scalable, maintainable automation.

---

## Key Components

- [`workflows/detect-changed-tfvars-files.yaml`](./workflows/detect-changed-tfvars-files.yaml):  
  Detects changed `terraform.tfvars` files and triggers downstream processing.
- [`workflows/process-changed-tfvars-files.yaml`](./workflows/process-changed-tfvars-files.yaml):  
  Matrix workflow that runs all automation steps for each changed file.
- [`actions/`](./actions/):  
  Modular composite actions for each CI/CD step (format, lint, validate, plan, scan, cost, apply, destroy, etc.).

---

## Reference Architecture

- [Terraform-to-Azure CI/CD Overview](https://www.grinntec.net/architecture/terraform-to-azure-cicd/)
- [Detect Pattern](https://www.grinntec.net/design-patterns/github-actions/automate-terraform-deployment-detect/)
- [Process Pattern](https://www.grinntec.net/design-patterns/github-actions/automate-terraform-deployment-process/)

---

## How It Works

1. **On PR or push to main:**  
   - Workflow triggers only if a `terraform.tfvars` file changes.
2. **Detect changed files:**  
   - Custom action finds all changed `terraform.tfvars` files.
3. **Process each file:**  
   - Matrix job launches for each changed file.
   - Each job:
     - Extracts key variables (app, env, location)
     - Ensures lockfile and provider cache
     - Runs format, lint, validate, plan, security scan, cost estimate
     - Applies/destroys resources if `ci_mode` is set
4. **Traceable outputs:**  
   - Every step writes a Markdown summary to the Actions UI for auditability.

---

## Best Practices

- **Environment isolation:**  
  Every environment or stack is processed independently—no global state, no hardcoded environments.
- **Fail-fast:**  
  Most steps fail immediately on error, surfacing issues early.
- **Security:**  
  Only required secrets are passed to each job; follows least-privilege principles.
- **Auditable:**  
  All actions write concise Markdown summaries, making reviews and troubleshooting fast.

---

## Getting Started

1. Fork or clone this repository structure.
2. Add your `terraform.tfvars` files in environment-specific directories.
3. Ensure required GitHub secrets are set (`PAT`, Azure credentials, `INFRACOST_API_KEY`).
4. Customize workflows and actions as needed for your Azure setup.

---

## Documentation

- See each action's README in [`actions/`](./actions/) for usage, inputs, outputs, and troubleshooting.
- See [`workflows/`](./workflows/) for workflow orchestration details.

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
