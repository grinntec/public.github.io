# Create Terraform Backend Config File GitHub Action

This composite GitHub Action generates a `backend.tfvars` file for Azure Blob Storage, enabling modular and environment-specific Terraform state management. It uses supplied variables (app name, environment, location, resource group, storage account, etc.) and the tfvars file path to create a backend config that ensures each environment’s state is uniquely keyed and securely stored.

---

## Features

- **Automates backend configuration:**  
  Creates a `backend.tfvars` file with all required Azure backend settings for your Terraform workflow.
- **Unique state key per environment/directory:**  
  Uses the tfvars file path and environment variables to ensure state is correctly segmented.
- **Supports modular, multi-environment automation:**  
  Works with any directory structure; config can be placed in the appropriate folder for downstream Terraform steps.
- **Validates all inputs:**  
  Fails fast if any required value is missing.
- **Clear output:**  
  Emits notices to the Actions UI and exposes relevant values as outputs for traceability.

---

## Usage

Add this action after extracting your environment/app/location variables:

```yaml
- name: Create Terraform backend config file
  uses: ./.github/actions/create-terraform-backend-config-file
  with:
    app_name: myapp
    env: dev
    location: westeurope
    file: ./environments/dev/terraform.tfvars
    resource_group_name: rg-tfstate
    storage_account_name: tfstateaccount
    container_name: tfstatecontainer
    subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    tenant_id: ${{ secrets.AZURE_TENANT_ID }}
    dir: ./environments/dev
```

**Example workflow context:**

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      # ... previous steps ...
      - name: Create backend config file
        uses: ./.github/actions/create-terraform-backend-config-file
        with:
          app_name: ${{ steps.extract.outputs.app_name }}
          env: ${{ steps.extract.outputs.env }}
          location: ${{ steps.extract.outputs.location }}
          file: ${{ inputs.tfvars_file }}
          resource_group_name: ${{ env.AZURE_RESOURCE_GROUP_NAME }}
          storage_account_name: ${{ env.AZURE_STORAGE_ACCOUNT_NAME }}
          container_name: ${{ env.AZURE_CONTAINER_NAME }}
          subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          tenant_id: ${{ secrets.AZURE_TENANT_ID }}
          dir: ${{ steps.showfile.outputs.dir }}
```

---

## Inputs

| Name                | Description                                                      | Required | Example                         |
|---------------------|------------------------------------------------------------------|----------|----------------------------------|
| app_name            | Application name                                                 | Yes      | `webapp`                        |
| env                 | Environment (e.g., dev, prod)                                    | Yes      | `dev`                           |
| location            | Azure location (e.g., eastus, westeurope)                        | Yes      | `westeurope`                    |
| file                | Path to the `terraform.tfvars` file                              | Yes      | `environments/dev/terraform.tfvars` |
| resource_group_name | Azure resource group for backend                                 | Yes      | `rg-tfstate`                    |
| storage_account_name| Storage account name for backend                                 | Yes      | `tfstateaccount`                |
| container_name      | Blob container name for backend                                  | Yes      | `tfstatecontainer`              |
| subscription_id     | Azure Subscription ID                                            | Yes      | `${{ secrets.AZURE_SUBSCRIPTION_ID }}` |
| tenant_id           | Azure Tenant ID                                                  | Yes      | `${{ secrets.AZURE_TENANT_ID }}` |
| dir                 | Directory to place backend config (optional, defaults to current)| No       | `./environments/dev`            |

---

## Outputs

| Name       | Description                                   | Example                    |
|------------|-----------------------------------------------|----------------------------|
| app_name   | Echoed value of `app_name`                    | `webapp`                   |
| env        | Echoed value of `env`                         | `dev`                      |
| location   | Echoed value of `location`                    | `westeurope`               |

---

## How It Works

- Receives all backend config and environment variables as inputs.
- Calculates a unique state key based on the tfvars file path, environment, and app name.
- Writes a `backend.tfvars` file to the specified directory, containing all relevant Azure backend settings:
  - `resource_group_name`
  - `storage_account_name`
  - `container_name`
  - `key` (unique per directory/environment)
  - `subscription_id`
  - `tenant_id`
- Emits a workflow notice with the backend config file path for auditability.

---

## Best Practices

- Use this action before any `terraform init` or plan/apply steps to ensure backend config is present.
- Always provide all required Azure backend values as inputs—avoid hardcoding secrets in workflow YAML.
- Place the backend config file in the same directory as your Terraform code for easy reference.

---

## Limitations

- Only works with standard HCL assignment syntax and expected variable names.
- Fails if any required input is missing.
- Assumes you want one backend config per environment/directory.

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
