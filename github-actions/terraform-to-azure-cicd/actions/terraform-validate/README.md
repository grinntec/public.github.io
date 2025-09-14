# Terraform Validate GitHub Action

This composite GitHub Action runs `terraform validate` in the directory associated with a given `.tfvars` file. It ensures your Terraform code is syntactically and structurally correct before you plan or apply changes, providing actionable Markdown summaries for traceability and auditability in CI/CD workflows.

---

## Features

- **Automated validation:**  
  Runs `terraform validate` in the correct directory, checking all `.tf` files for syntax errors, missing variables, and logical issues.
- **Private module support:**  
  If a GitHub Personal Access Token (`GH_PAT`) is set, configures git for private Terraform module access automatically.
- **Clear status output:**  
  Summarizes results in the GitHub Actions UI, with success/failure banners and expandable error details.
- **Fail-fast error handling:**  
  The workflow stops immediately if validation fails, helping you catch issues early.
- **Debug and traceability:**  
  Prints debug info and directory listings for easier troubleshooting in multi-directory setups.

---

## Usage

Add this action anywhere you want to validate Terraform code before running plan or apply:

```yaml
- name: Terraform Validate
  uses: ./.github/actions/terraform-validate
  with:
    file: environments/dev/terraform.tfvars
  env:
    GH_PAT: ${{ secrets.GRINNTEC_TERRAFORM_DEPLOYMENTS_AZURE_PAT }} # optional, for private modules
```

**Typical workflow context:**

```yaml
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Terraform Validate
        uses: ./.github/actions/terraform-validate
        with:
          file: src/env/dev/terraform.tfvars
        env:
          GH_PAT: ${{ secrets.GRINNTEC_TERRAFORM_DEPLOYMENTS_AZURE_PAT }}
```

---

## Inputs

| Name  | Description                                 | Required | Example                                |
|-------|---------------------------------------------|----------|----------------------------------------|
| file  | Path to any `.tfvars` file in the target directory | Yes      | `environments/dev/terraform.tfvars`    |

---

## Environment Variables

| Name   | Description                                  |
|--------|----------------------------------------------|
| GH_PAT | GitHub PAT for private module access (optional) |

---

## How It Works

1. **Determines the target directory** from the provided file path.
2. **Configures git for private modules** if `GH_PAT` is set.
3. **Runs `terraform init -backend=false`** to ensure required providers/modules are available (never touches remote state).
4. **Runs `terraform validate -no-color`** and captures the output.
5. **Writes a Markdown summary** to the Actions UI showing pass/fail and any errors, with expandable details.
6. **Fails the workflow** if validation does not succeed.

---

## Example Output

If validation passes:

```
## Terraform Validate

✅ **Your Terraform code passed validation checks**

> Checks your Terraform configuration files for syntax errors and internal consistency, ensuring your code is structurally correct before planning or applying changes.
```

If validation fails:

```
## Terraform Validate

❌ **Your Terraform code failed validation checks**  

Terraform found issues with your configuration.

<details><summary>Show terraform validate output</summary>

```text
[Validation error output]
```
</details>

**What should you do?**
- Review the errors above and fix them in your Terraform code.
- Validation checks for syntax errors, missing variables, and logical issues before you run plan/apply.
```

---

## Best Practices

- Always run `terraform validate` before planning or applying changes.
- Use this action in PR and deployment pipelines to catch configuration errors early.
- If working with private modules, pass your PAT via the `GH_PAT` environment variable.

---

## Limitations

- Only validates `.tf` files in the directory of the provided `.tfvars` file.
- Does not check for cloud-specific issues (use TFLint or Checkov for deeper analysis).
- Fails the job immediately on validation errors—review the summary for troubleshooting.

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
