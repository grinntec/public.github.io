# Terraform Cost Estimate GitHub Action

This composite GitHub Action runs [Infracost](https://www.infracost.io/) on your Terraform plan file to estimate the **monthly cloud cost** of your planned infrastructure changes. Designed for the Azure Terraform CI/CD pipeline, it integrates seamlessly into modular workflows and provides a clear Markdown summary in the Actions UI.

---

## Features

- **Runs Infracost on Terraform plans:**  
  Reads the generated plan JSON and outputs a cost breakdown for your infrastructure changes.
- **Fast, automated, and secure:**  
  Installs Infracost CLI, sets API key from secrets, and runs cost estimation in the correct directory.
- **Actionable summary:**  
  Outputs a Markdown cost report with expandable details for easy review in GitHub Actions.
- **Supports multi-directory, multi-env workflows:**  
  Works with any Terraform plan generated in a matrix or modular job.
- **Error handling:**  
  Fails the workflow early if the plan JSON or API key are missing.

---

## Usage

Add this action after you have generated a Terraform plan file and its JSON export:

```yaml
- name: Terraform Cost Estimate
  uses: ./.github/actions/terraform-cost-estimate
  with:
    file: environments/dev/terraform.tfvars
  env:
    INFRACOST_API_KEY: ${{ secrets.INFRACOST_API_KEY }}
```

**Typical workflow snippet:**

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Terraform Plan
        uses: ./.github/actions/terraform-plan
        with:
          file: environments/dev/terraform.tfvars
      - name: Terraform Cost Estimate
        uses: ./.github/actions/terraform-cost-estimate
        with:
          file: environments/dev/terraform.tfvars
        env:
          INFRACOST_API_KEY: ${{ secrets.INFRACOST_API_KEY }}
```

---

## Inputs

| Name  | Description                        | Required | Example                              |
|-------|------------------------------------|----------|--------------------------------------|
| file  | Path to the `.tfvars` file         | Yes      | `environments/dev/terraform.tfvars`  |

---

## Environment Variables

| Name               | Description                                      |
|--------------------|--------------------------------------------------|
| INFRACOST_API_KEY  | Infracost API key (from workflow secrets)        |

---

## How It Works

1. **Installs Infracost CLI** (if not already available).
2. **Validates API key** (fails early if not set).
3. **Generates Terraform plan JSON** using `terraform show -json tfplan > tfplan.json`.
4. **Runs Infracost breakdown** and writes results to a Markdown summary:
   - Shows estimated monthly cost.
   - Provides a detailed expandable section with the full cost breakdown.
   - Links to [Infracost documentation](https://www.infracost.io/docs/).
5. **Handles errors gracefully:**  
   - Fails if the plan JSON or API key are missing.
   - Writes a summary even if no cost data is found.

---

## Example Output

The Actions UI summary includes:

```
## Infracost: Estimated Monthly Cost

✅ Succeeded

> - Uses Infracost to read your plan and show costs
> - [Learn more about Infracost](https://www.infracost.io/docs/)
> - Always review the cost estimate before approving or merging any infrastructure changes!

<details><summary>Show cost estimate</summary>
<pre>
[Infracost cost breakdown table]
</pre>
</details>
```

---

## Best Practices

- **Always review cost estimates before merging or deploying changes.**
- Make sure your plan file and API key are present and correct.
- Use this action in matrix jobs for multi-env cost breakdown.
- Share cost reports with stakeholders to avoid budget surprises.

---

## Limitations

- Only works if your plan file (`tfplan.json`) is present in the correct directory.
- Requires a valid Infracost API key.
- The cost estimate is only as accurate as the Terraform plan and resource definitions.

---

## References

- [Infracost Documentation](https://www.infracost.io/docs/)
- [Terraform Plan JSON](https://developer.hashicorp.com/terraform/cli/commands/show#json-output-format)

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
