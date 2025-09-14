# Show File Processing GitHub Action

This composite GitHub Action is designed to print and output information about a specified `terraform.tfvars` (or any `.tfvars`) file during a CI/CD workflow. It aids in traceability, debugging, and auditability by making it clear which configuration file is being processed, what its directory is, and optionally providing summary information in the Actions UI.

---

## Features

- **Prints the file path and directory** being processed for each workflow run.
- **Validates file existence** and emits workflow notices or warnings.
- **Emits outputs** (`dir`) for use in downstream workflow steps.
- **Writes a Markdown summary** to the GitHub Actions UI for easy inspection.
- **Modular**—all logic is in a shell script for maintainability and reusability.

---

## Usage

Add a step to your workflow:

```yaml
- name: Show working file and directory
  uses: ./.github/actions/show-file
  id: showfile
  with:
    tfvars_file: path/to/terraform.tfvars

# Use the output directory in later steps:
- name: Do something in the same directory
  run: echo "Directory is ${{ steps.showfile.outputs.dir }}"
```

---

## Inputs

| Name         | Description                   | Required | Example                    |
|--------------|-------------------------------|----------|----------------------------|
| tfvars_file  | Path to the `.tfvars` file    | Yes      | `environments/dev/terraform.tfvars` |

---

## Outputs

| Name  | Description                                         | Example                    |
|-------|-----------------------------------------------------|----------------------------|
| dir   | Directory containing the tfvars file                | `environments/dev`         |

---

## How It Works

- The action calls a shell script (`script.sh`) with the path to the `.tfvars` file.
- The script:
  - Validates that a file path is provided.
  - Prints the file path and its containing directory.
  - Emits the directory as an output.
  - Checks if the file exists and emits a notice or warning.
  - Writes a Markdown summary to the Actions UI (if the file exists).

---

## Example Output

If called with `environments/dev/terraform.tfvars`, the summary in the Actions UI will include:

```
## tfvars file processed

**File:** `environments/dev/terraform.tfvars`

**Directory:** `environments/dev`
```

---

## Script Details

### `script.sh`

- Written in robust Bash (`set -euo pipefail`).
- Accepts the tfvars path as the first argument.
- Emits outputs for use with `steps.<id>.outputs.dir`.
- Prints notices/warnings for missing files.
- Writes step summary for easy debugging in the Actions UI.

---

## Best Practices

- Use this action at the beginning of any job that processes `.tfvars` files for clear traceability.
- Avoid leaking sensitive values—this action prints file locations, not contents.
- Use emitted outputs to make subsequent workflow steps modular and directory-aware.

---

## License

MIT (or your repository’s license)

---