# Read CI Mode from .tfvars GitHub Action

This composite GitHub Action extracts the value of `ci_mode` from a specified Terraform `.tfvars` file. It is designed to help dynamic pipelines determine what CI/CD operation (e.g., validate, apply, destroy) should be performed for each environment or stack, based on configuration in the `.tfvars`.

---

## Features

- **Extracts `ci_mode` From Any `.tfvars` File**  
  Reads and outputs the `ci_mode` value, supporting files with spaces and double quotes.
- **Robust Error Handling**  
  Fails fast with clear messages if the file is missing or does not contain `ci_mode`.
- **Traceability**  
  Prints concise summaries to the GitHub Actions UI for audit and debugging.
- **Modular Output**  
  Sets the extracted `ci_mode` as a GitHub Actions output variable for use in downstream jobs.

---

## Usage

Add a step to your workflow:

```yaml
- name: Read CI mode
  uses: ./.github/actions/read-ci-mode
  id: ci_mode
  with:
    file: path/to/terraform.tfvars

# Use the output in later steps:
- name: Use CI mode
  run: echo "CI Mode is ${{ steps.ci_mode.outputs.ci_mode }}"
```

---

## Inputs

| Name | Description                      | Required | Example                       |
|------|----------------------------------|----------|-------------------------------|
| file | Path to the `.tfvars` file       | Yes      | `environments/dev/terraform.tfvars` |

---

## Outputs

| Name     | Description                        | Example   |
|----------|------------------------------------|-----------|
| ci_mode  | Extracted `ci_mode` value or empty | `apply`   |

---

## How It Works

- **Script Logic:**  
  - Takes the path to the `.tfvars` file as input.
  - Checks that the file exists.
  - Uses `awk` to extract the value of `ci_mode` (handles whitespace and quoted values).
  - Fails the workflow with an error if the file is missing or `ci_mode` is not present.
  - Writes a summary to the Actions UI for traceability.

- **Example tfvars:**
    ```hcl
    app_name   = "my-app"
    env        = "dev"
    ci_mode    = "apply"
    ```

---

## Example Output

If your `terraform.tfvars` contains:
```hcl
ci_mode = "apply"
```
The action output will be:
```
ci_mode=apply
```
And the Actions summary will include:
```
## CI Mode
`apply`
```

---

## Best Practices

- Use this action to drive conditional logic in your workflows (e.g., only run `terraform apply` if `ci_mode` is `apply`).
- Keep `ci_mode` values consistent across environments to simplify pipeline logic.
- Combine with actions that scan and process changed `.tfvars` files for modular, environment-driven CI/CD.

---

## Limitations

- Only extracts the first occurrence of `ci_mode` in the given file.
- Expects `ci_mode` to be in the format: `ci_mode = "value"`, with quotes as per Terraform syntax.
- Workflow will fail if `ci_mode` is not present or file does not exist.

---

## License

MIT (or your repository’s license)

---