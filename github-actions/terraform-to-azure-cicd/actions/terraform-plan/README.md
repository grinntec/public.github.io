# Terraform Plan GitHub Action

This composite GitHub Action runs `terraform plan` in the directory corresponding to a given `.tfvars` file, using a generated backend config for Azure. It summarizes the plan results, provides error handling for state lock issues, exports a JSON plan for security scans, and writes a full Markdown report to the Actions UI.

---

## Features

- **Automated plan execution:**  
  Runs `terraform plan` with a backend config file, targeting the correct directory for your environment.
- **Backend config validation:**  
  Fails fast if the backend config file is missing, ensuring state is stored correctly.
- **Secure private module access:**  
  Supports GitHub PAT integration for accessing private Terraform modules.
- **Detailed Markdown summary:**  
  Summarizes plan status, lock errors, and includes an expandable section with the full output.
- **State lock error detection:**  
  Detects and highlights state locking errors, helping you resolve common CI/CD pipeline blockers.
- **JSON export for scanning:**  
  Automatically exports the plan in JSON for use by security or compliance tools.

---

## Usage

Add this action after creating your backend config file:

```yaml
- name: Terraform Plan
  uses: ./.github/actions/terraform-plan
  with:
    file: environments/dev/terraform.tfvars
  env:
    GH_PAT: ${{ secrets.GRINNTEC_TERRAFORM_DEPLOYMENTS_AZURE_PAT }}
    TF_VAR_azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    TF_VAR_azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
```

**Note:**  
- The action expects a backend config file named `backend.tfvars` in the same directory as the `.tfvars` file.

---

## Inputs

| Name  | Description                        | Required | Example                              |
|-------|------------------------------------|----------|--------------------------------------|
| file  | Path to the `.tfvars` file         | Yes      | `environments/dev/terraform.tfvars`  |

---

## Environment Variables

| Name                        | Description                                  |
|-----------------------------|----------------------------------------------|
| GH_PAT                      | GitHub PAT for private module access         |
| TF_VAR_azure_subscription_id| Azure Subscription ID (for provider config)  |
| TF_VAR_azure_tenant_id      | Azure Tenant ID (for provider config)        |

---

## How It Works

1. **Directory detection:**  
   Extracts directory from the provided `.tfvars` file path and operates there.
2. **Backend config validation:**  
   Ensures `backend.tfvars` exists before running `terraform init`.
3. **Module authentication:**  
   Configures git for private module pulls if `GH_PAT` is set.
4. **Runs `terraform init`** with backend config.
5. **Runs `terraform plan`**, writing the output to `tfplan` and showing results.
6. **Error handling:**  
   If plan fails due to state lock, summarizes the error for fast debugging.
7. **Markdown summary:**  
   Full plan results, lock errors, and expandable output for easy review.
8. **JSON export:**  
   Exports plan as JSON for use by tools like Checkov or Infracost.

---

## Example Workflow

```yaml
jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Extract tfvars values
        uses: ./.github/actions/extract-tfvars
        with:
          file: environments/dev/terraform.tfvars

      - name: Create Terraform backend config file
        uses: ./.github/actions/create-terraform-backend-config-file
        with:
          app_name: ${{ steps.extract.outputs.app_name }}
          env: ${{ steps.extract.outputs.env }}
          location: ${{ steps.extract.outputs.location }}
          file: environments/dev/terraform.tfvars
          resource_group_name: terraform-state
          storage_account_name: tfstateaccountsandbox
          container_name: tfstatecontainer
          subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          tenant_id: ${{ secrets.AZURE_TENANT_ID }}
          dir: environments/dev

      - name: Terraform Plan
        uses: ./.github/actions/terraform-plan
        with:
          file: environments/dev/terraform.tfvars
        env:
          GH_PAT: ${{ secrets.GRINNTEC_TERRAFORM_DEPLOYMENTS_AZURE_PAT }}
```

---

## Troubleshooting

- **Backend config not found:**  
  Ensure `backend.tfvars` exists in the target directory before running this action.
- **State lock errors:**  
  If summary shows state lock, wait for the lock to expire or manually unlock it.
- **Plan failed:**  
  Review the Actions summary for error details and fix configuration issues.
- **Missing PAT:**  
  If using private modules, ensure `GH_PAT` is set and has proper repo access.

---

## Limitations

- Only works with plan and backend config files in the same directory as the `.tfvars` file.
- Does not unlock remote state automatically.
- Designed for use with Azure backends; may be adapted for other providers.

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
