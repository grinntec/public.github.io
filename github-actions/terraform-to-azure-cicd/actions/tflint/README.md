# TFLint GitHub Action

This composite GitHub Action runs [TFLint](https://github.com/terraform-linters/tflint) in the directory of your specified `.tfvars` file, automatically checking your Terraform code for errors, security issues, and best-practice violations. If supported, it auto-fixes style issues and commits formatting changes. All results are output as a Markdown summary in the GitHub Actions UI for easy review.

---

## Features

- **Runs TFLint in context:**  
  Automatically locates the directory of your `.tfvars` file and lints all Terraform files (`.tf`, `.tfvars`) there.
- **Auto-fix support:**  
  Runs TFLint in `--fix` mode if available, automatically correcting style and formatting issues.
- **Commit and diff reporting:**  
  If auto-fixes are made, commits the changes and shows unified diffs in the Actions summary.
- **Detailed, actionable summary:**  
  Always writes a Markdown summary to the Actions UI, including lists of auto-fixed files and expandable error or diff details.
- **Safe for multi-directory/monorepo use:**  
  Works in any repo structure—just provide the path to any `.tfvars` file in the environment you want to lint.

---

## Usage

Add this step to your workflow after checkout and before validation/plan steps:

```yaml
- name: Run TFLint
  uses: ./.github/actions/tflint
  with:
    file: environments/dev/terraform.tfvars
```

**Example in a workflow:**

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run TFLint
        uses: ./.github/actions/tflint
        with:
          file: environments/dev/terraform.tfvars
```

---

## Inputs

| Name  | Description                               | Required | Example                               |
|-------|-------------------------------------------|----------|---------------------------------------|
| file  | Path to any `.tfvars` file in the target directory | Yes      | `environments/dev/terraform.tfvars`   |

---

## How It Works

- **Installs TFLint CLI** (latest version, if not present).
- **Determines the working directory** from the provided file path.
- **Runs TFLint in `--fix` mode** (if supported), attempting to auto-correct style and best-practice issues.
- **Checks for changed files** using `git diff`.
- **If changes were made:**
  - Stages, commits, and pushes the formatting changes.
  - Shows a unified diff for each changed file in the Actions summary.
- **If no changes were made:**
  - Reports "No linting issues found" in the summary.
- **If linting fails:**  
  - Shows error details in the summary and marks the job as failed.

---

## Example Output

If TFLint auto-fixes files:

```
## TFLint Checks

⚠️ TFLint found and auto-fixed some issues.
Your code was reformatted to match style and best practices. Please review the changes below.

#### `environments/dev/main.tf`
<details><summary>Show diff</summary>

```diff
[unified diff]
```
</details>
...
```

If no issues are found:

```
## TFLint Checks

✅ No linting issues were found.

> Analyzes your Terraform code for potential errors, security issues, and best-practice violations specific to your cloud provider before you deploy any changes.
```

If linting fails:

```
## TFLint Checks

❌ Linting failed.
TFLint found issues that could not be auto-fixed. Please address them manually.

<details><summary>Show TFLint output</summary>

```text
[lint error output]
```
</details>
```

---

## Best Practices

- Run this action in PR pipelines and before any plan or apply workflow.
- Always review diffs and error output before merging or deploying.
- Use with [Terraform Format](../terraform-fmt/) and [Terraform Validate](../terraform-validate/) for comprehensive code quality enforcement.

---

## Limitations

- Only works with files tracked by git in the specified directory.
- Auto-fix only affects style/formatting; functional errors must be fixed manually.
- Does not lint files outside the directory of the given `.tfvars` file.

---

## References

- [TFLint Documentation](https://github.com/terraform-linters/tflint)

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
