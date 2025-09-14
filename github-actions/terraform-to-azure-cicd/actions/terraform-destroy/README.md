# Terraform Destroy GitHub Action

This composite GitHub Action runs `terraform destroy` in the directory associated with a given `.tfvars` file, automating the teardown of Azure infrastructure in CI/CD pipelines. It securely configures access to private Terraform modules, provides a detailed Markdown summary of the destroy operation, and fails fast on errors.

---

## Features

- **Automated resource teardown:**  
  Runs `terraform destroy -auto-approve` with full error handling and log capture.
- **Secure GitHub PAT integration:**  
  Configures git with a provided Personal Access Token (PAT) for private module access.
- **Directory-aware:**  
  Applies destroy in the correct directory, based on the `.tfvars` file location.
- **Detailed workflow summary:**  
  Outputs a Markdown summary to the Actions UI, including destroy results and expandable output.
- **Fail-fast error handling:**  
  Stops the workflow on any errors, with clear logs for troubleshooting.

---

## Usage

Add this action where you need to automate resource deletion:

```yaml
- name: Terraform Destroy
  uses: ./.github/actions/terraform-destroy
  with:
    file: environments/dev/terraform.tfvars
  env:
    GH_PAT: ${{ secrets.GRINNTEC_TERRAFORM_DEPLOYMENTS_AZURE_PAT }}
    TF_VAR_azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    TF_VAR_azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
```

**Note:**  
The action runs destroy in the directory containing the specified `.tfvars` file.

---

## Inputs

| Name  | Description                        | Required | Example                              |
|-------|------------------------------------|----------|--------------------------------------|
| file  | Path to the `.tfvars` file         | Yes      | `environments/dev/terraform.tfvars`  |

---

## Environment Variables

Set these via your workflow `env:` block for secure authentication and Azure access:

| Name                        | Description                                  |
|-----------------------------|----------------------------------------------|
| GH_PAT                      | GitHub PAT for private module access         |
| TF_VAR_azure_subscription_id| Azure Subscription ID (for provider config)  |
| TF_VAR_azure_tenant_id      | Azure Tenant ID (for provider config)        |

---

## How It Works

- **Directory detection:**  
  Determines the directory from the provided `.tfvars` file path and runs destroy in that directory.
- **GitHub PAT setup:**  
  Configures git to use your PAT for any private Terraform modules.
- **Run destroy:**  
  Executes `terraform destroy -auto-approve -no-color` and captures all output.
- **Summary output:**  
  Removes ANSI color codes, writes a detailed Markdown summary to the Actions UI, including an expandable section with the full destroy log.
- **Error handling:**  
  Workflow fails if destroy does not succeed, with error details in the summary.

---

## Example Workflow

```yaml
jobs:
  teardown:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Terraform Destroy
        uses: ./.github/actions/terraform-destroy
        with:
          file: environments/dev/terraform.tfvars
        env:
          GH_PAT: ${{ secrets.GRINNTEC_TERRAFORM_DEPLOYMENTS_AZURE_PAT }}
          TF_VAR_azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          TF_VAR_azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
```

---

## Troubleshooting

- **Plan file not found:**  
  Ensure the working directory contains the necessary Terraform configuration.
- **Destroy failed:**  
  Review output in the Actions summary for state lock, permission, or resource dependency issues.
- **PAT issues:**  
  Confirm `GH_PAT` is set and has proper access to private Terraform modules.

---

## Limitations

- Only works in the directory containing the specified `.tfvars` file.
- Does not support remote state unlock or destroy retries.
- Designed for use with Azure, but can be adapted for other clouds.

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
