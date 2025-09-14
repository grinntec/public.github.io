# Extract tfvars Values GitHub Action

This composite GitHub Action extracts key variables (`app_name`, `env`, and `location`) from a specified `terraform.tfvars` file and exposes them as outputs. It enables modular, environment-driven workflows for Terraform projects, making it easy to pass configuration between steps and jobs in CI/CD pipelines.

---

## Features

- **Flexible Extraction:**  
  Reads variables from any `.tfvars` file (default: `terraform.tfvars`) in any directory.
- **Standard Output Variables:**  
  Outputs `app_name`, `env`, and `location` for downstream use.
- **Traceable and Modular:**  
  Outputs a comma-separated list of all extracted keys. Designed to support multi-environment and multi-directory Terraform pipelines.
- **Safe for CI/CD:**  
  Does not print sensitive values to logs. Only exposes required variables as outputs.
- **Markdown Summary:**  
  Writes a clear summary of extracted values to the GitHub Actions UI for auditability.

---

## Usage

Add this action to your workflow to extract variables from a tfvars file:

```yaml
- name: Extract tfvars values
  id: extract
  uses: ./.github/actions/extract-tfvars
  with:
    file: path/to/terraform.tfvars              # Optional, default is 'terraform.tfvars'
    working_directory: ./environments/dev       # Optional, default is '.'

# Use the outputs in later steps:
- name: Show extracted values
  run: |
    echo "App Name: ${{ steps.extract.outputs.app_name }}"
    echo "Env: ${{ steps.extract.outputs.env }}"
    echo "Location: ${{ steps.extract.outputs.location }}"
    echo "Keys: ${{ steps.extract.outputs.keys }}"
```

---

## Inputs

| Name                | Description                                                      | Required | Default             |
|---------------------|------------------------------------------------------------------|----------|---------------------|
| `file`              | Path to the `.tfvars` file to extract variables from             | No       | `terraform.tfvars`  |
| `working_directory` | Directory to run extraction in                                   | No       | `.`                 |

---

## Outputs

| Name       | Description                                   | Example                    |
|------------|-----------------------------------------------|----------------------------|
| app_name   | Value of `app_name` from the tfvars file      | `webapp`                   |
| env        | Value of `env` from the tfvars file           | `dev`                      |
| location   | Value of `location` from the tfvars file      | `westeurope`               |
| keys       | Comma-separated list of extracted keys        | `app_name,env,location`    |

---

## How It Works

- The action calls a shell script (`script.sh`) with the file path and working directory as arguments.
- The script:
  - Changes into the specified working directory.
  - Validates that the file exists, and prints its contents for debugging.
  - Extracts `app_name`, `env`, and `location` using robust Bash, `grep`, and `sed`.
  - Sets each variable as a GitHub Actions output and writes a summary for the Actions UI.
  - Outputs a comma-separated list of all successfully extracted keys for traceability.

---

## Best Practices

- Use this action at the start of jobs that need environment- or application-specific variables.
- Combine with actions such as [create-terraform-backend-config-file](../create-terraform-backend-config-file/) for full automation.
- Keep sensitive variables out of tfvars files if you do not want them surfaced in outputs.

---

## Limitations

- Only extracts the variables `app_name`, `env`, and `location`.
  (Modify the script to extract other variables if needed.)
- Expects variables to be in standard HCL assignment format (e.g., `app_name = "myapp"`).
- Does not fail if a variable is missing; missing variables are empty in outputs.

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
