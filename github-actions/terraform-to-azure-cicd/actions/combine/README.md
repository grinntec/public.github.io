# Combine and Extract Terraform Variables GitHub Action

This composite GitHub Action extracts key variables (`app_name`, `env`, and `location`) from a specified `terraform.tfvars` file, exposes them as outputs, and prepares contextual information for Azure backend configuration. It is designed for modular, automated Terraform workflows that need to dynamically consume and combine environment-specific variables for backend state and resource naming.

---

## Features

- **Flexible Extraction:**  
  Reads from any `terraform.tfvars` file, in any directory, and extracts standard variables.
- **Comprehensive Output:**  
  Exposes `app_name`, `env`, and `location` as outputs for downstream jobs, as well as a comma-separated list of keys.
- **Backend Config Support:**  
  Accepts all the required inputs to produce backend configuration, including resource group, storage account, container, subscription, tenant ID, and more.
- **Traceable and Modular:**  
  Prints debug output, checks file existence, summarizes key variables for auditability, and logs a Markdown summary in the Actions UI.
- **Safe for CI/CD:**  
  Handles errors robustly and does not expose secrets to logs.

---

## Usage

Add this action to your workflow to extract and combine variables from a tfvars file:

```yaml
- name: Combine and Extract tfvars Values
  id: combine
  uses: ./.github/actions/combine
  with:
    app_name: myapp                       # Required
    env: dev                              # Required
    location: westeurope                  # Required
    file: ./environments/dev/terraform.tfvars  # Required
    resource_group_name: rg-tfstate
    storage_account_name: tfstateaccount
    container_name: tfstatecontainer
    subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    tenant_id: ${{ secrets.AZURE_TENANT_ID }}
    dir: ./environments/dev               # Optional
```

**Example in a workflow:**

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Combine and Extract tfvars Values
        id: combine
        uses: ./.github/actions/combine
        with:
          app_name: ${{ secrets.APP_NAME }}
          env: ${{ secrets.ENV }}
          location: ${{ secrets.LOCATION }}
          file: ${{ inputs.tfvars_file }}
          resource_group_name: ${{ secrets.AZURE_RESOURCE_GROUP_NAME }}
          storage_account_name: ${{ secrets.AZURE_STORAGE_ACCOUNT_NAME }}
          container_name: ${{ secrets.AZURE_CONTAINER_NAME }}
          subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          tenant_id: ${{ secrets.AZURE_TENANT_ID }}
          dir: ${{ steps.showfile.outputs.dir }}

      - name: Use extracted values
        run: |
          echo "App Name: ${{ steps.combine.outputs.app_name }}"
          echo "Env: ${{ steps.combine.outputs.env }}"
          echo "Location: ${{ steps.combine.outputs.location }}"
          echo "Keys: ${{ steps.combine.outputs.keys }}"
```

---

## Inputs

| Name                | Description                                                      | Required | Example                         |
|---------------------|------------------------------------------------------------------|----------|----------------------------------|
| app_name            | Application name                                                 | Yes      | `webapp`                        |
| env                 | Environment (e.g., dev, prod)                                    | Yes      | `dev`                           |
| location            | Azure location (e.g., eastus, westeurope)                        | Yes      | `westeurope`                    |
| file                | Path to the `terraform.tfvars` file                              | Yes      | `environments/dev/terraform.tfvars` |
| resource_group_name | Azure resource group name for backend                            | Yes      | `rg-tfstate`                    |
| storage_account_name| Storage account name for backend                                 | Yes      | `tfstateaccount`                |
| container_name      | Blob container name for backend                                  | Yes      | `tfstatecontainer`              |
| subscription_id     | Azure Subscription ID                                            | Yes      | `${{ secrets.AZURE_SUBSCRIPTION_ID }}` |
| tenant_id           | Azure Tenant ID                                                  | Yes      | `${{ secrets.AZURE_TENANT_ID }}` |
| dir                 | Directory to place backend config (optional, defaults to current)| No       | `./environments/dev`            |

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

- The action calls a shell script (`script.sh`) with all relevant inputs.
- The script:
  - Changes to the specified working directory.
  - Validates the tfvars file exists and prints its contents for debugging.
  - Extracts `app_name`, `env`, and `location` using standard tools, sets these as outputs, and prints a Markdown summary.
  - Validates all required backend config inputs are provided.
  - Prints all inputs and outputs for traceability.

---

## Best Practices

- Use this action at the start of jobs to prepare and validate environment-specific backend configuration.
- Combine with downstream actions for backend config file creation, plan, apply, and destroy.
- Always provide all required Azure backend values as inputs—never hardcode secrets in your workflow files.

---

## Limitations

- Only extracts `app_name`, `env`, and `location` by default (customize script for more).
- Expects standard HCL assignment syntax in tfvars files.
- Will fail if required inputs are missing or tfvars file is not found.

---

## License

[MIT License](../LICENSE) © 2025 Grinntec
