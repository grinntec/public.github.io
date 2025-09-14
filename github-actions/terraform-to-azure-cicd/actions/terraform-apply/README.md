# Terraform Apply GitHub Action

This composite GitHub Action runs `terraform apply` using a pre-existing plan file in the target directory. It is designed for secure, automated CI/CD pipelines deploying infrastructure to Azure, with full summary reporting and best-practice error handling.

---

## Features

- **Automated Terraform apply:**  
  Runs `terraform apply -auto-approve <plan-file>`, applying planned changes with no manual intervention.
- **Secure GitHub PAT integration:**  
  Configures git with a provided Personal Access Token (PAT) for private Terraform modules.
- **Directory-aware:**  
  Applies the plan in the correct directory, based on the path to the `.tfvars` file.
- **Detailed workflow summary:**  
  Outputs a Markdown summary to the Actions UI, including apply results and full details in expandable sections.
- **Fails fast:**  
  If the apply step fails, the workflow stops and provides actionable error output.

---

## Usage

Add this action after you have generated a Terraform plan file:

```yaml
- name: Terraform Apply
  uses: ./.github/actions/terraform-apply
  with:
    file: environments/dev/terraform.tfvars
  env:
    GH_PAT: ${{ secrets.GRINNTEC_TERRAFORM_DEPLOYMENTS_AZURE_PAT }}
    TF_VAR_azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    TF_VAR_azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
```

**Note:**  
- The action expects a plan file named `tfplan` to exist in the same directory as the `.tfvars` file.  
- You may override author name/email inputs if needed for git operations.

---

## Inputs

| Name        | Description                    | Required | Example                                |
|-------------|-------------------------------|----------|----------------------------------------|
| file        | Path to the `.tfvars` file    | Yes      | `environments/dev/terraform.tfvars`    |

---

## Environment Variables

Set these via your workflow `env:` block for secure authentication and Azure deployment:

| Name                        | Description                                  |
|-----------------------------|----------------------------------------------|
| GH_PAT                      | GitHub PAT for private module access         |
| TF_VAR_azure_subscription_id| Azure Subscription ID (for provider config)  |
| TF_VAR_azure_tenant_id      | Azure Tenant ID (for provider config)        |

---

## How It Works

- **Directory detection:**  
  Determines the directory from the provided `.tfvars` file path and applies in that directory.
- **Plan file validation:**  
  Checks for the presence of `tfplan` before running `terraform apply`.
- **GitHub PAT setup:**  
  Configures git to use your PAT for any private Terraform modules.
- **Apply and summary:**  
  Runs `terraform apply -auto-approve tfplan` and captures all output.  
  Cleans output for readability and writes a detailed summary to the Actions UI, including a collapsible section with the full apply log.
- **Error handling:**  
  Fails the job if apply does not succeed and provides a clear error message.

---

## Example Workflow

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Terraform Plan
        uses: ./.github/actions/terraform-plan
        with:
          file: environments/dev/terraform.tfvars
        env:
          GH_PAT: ${{ secrets.GRINNTEC_TERRAFORM_DEPLOYMENTS_AZURE_PAT }}

      - name: Terraform Apply
        uses: ./.github/actions/terraform-apply
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
  Ensure `terraform plan` was run and produced a plan file named `tfplan` in the target directory.
- **Apply failed:**  
  Review error output in the Actions summary for state lock, permission, or resource issues.
- **GitHub PAT issues:**  
  Make sure `GH_PAT` is set and has proper access to any private Terraform modules.

---

## Limitations

- Only works with a plan file named `tfplan` in the same directory as the `.tfvars` file.
- Does not support remote state unlock or apply retries.
- Designed for use with Azure, but may be adapted for other clouds.

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
