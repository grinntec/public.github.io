# Detect Changed `.tfvars` Files GitHub Action

This custom [composite GitHub Action](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) detects which `.tfvars` (Terraform variable) files have changed in your repository. It outputs a structured JSON array of changed files, making it easy to drive downstream CI/CD workflows such as targeted Terraform validation, formatting, or deployment.

---

## Features

- **Robust Change Detection**  
  - For Pull Requests (PRs) or feature branches, compares against the PR base (`main` or other) to find all changed `.tfvars` files.
  - For direct commits to the default branch (e.g., `main`), compares the most recent commit to its parent to find changed `.tfvars` files.
- **Outputs JSON Arrays**  
  - Outputs a `changed_tfvars` JSON array (empty if none), suitable for use in matrix or conditional jobs.
- **Safe and Easy to Integrate**  
  - Handles shallow clones, missing files, and various repo layouts.
  - Can be used as a prerequisite for downstream targeted Terraform jobs.

---

## Usage

Add a step to your workflow (or just use the [included workflow example](../../workflows/detect-changed-tfvars-files.yaml)):

```yaml
jobs:
  detect-changes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Detect Changed .tfvars Files
        id: detect
        uses: ./.github/actions/detect-changed-tfvars-files/

      - name: Show output
        run: |
          echo "Changed files: ${{ steps.detect.outputs.changed_tfvars }}"
```

### With a Matrix Job

```yaml
jobs:
  detect:
    runs-on: ubuntu-latest
    outputs:
      changed_files: ${{ steps.detect.outputs.changed_tfvars }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - id: detect
        uses: ./.github/actions/detect-changed-tfvars-files/

  process:
    needs: detect
    if: ${{ needs.detect.outputs.changed_files != '[]' }}
    strategy:
      matrix:
        tfvars_file: ${{ fromJson(needs.detect.outputs.changed_files) }}
    runs-on: ubuntu-latest
    steps:
      - run: echo "Processing ${{ matrix.tfvars_file }}"
```

---

## Inputs

**None.**  
This action requires no inputs.

---

## Outputs

| Name             | Description                                                        | Example                                                           |
|------------------|--------------------------------------------------------------------|-------------------------------------------------------------------|
| `changed_tfvars` | JSON array of changed `.tfvars` files (may be empty: `[]`)         | `["env/dev/terraform.tfvars","env/prod/terraform.tfvars"]`        |

---

## How It Works

1. **Branch Detection:**  
   Determines if running on the default branch or a PR branch.
2. **Git Diff:**  
   - On `main`: compares `HEAD~1` to `HEAD` for changed files.
   - On PR: compares `origin/main` (or PR base) to `HEAD`.
3. **File Filtering:**  
   Filters for files ending with `.tfvars`.
4. **Structured Output:**  
   Outputs results as a valid JSON array for easy use in GitHub Actions.

---

## Example

Suppose your repo has:

```
environments/
  dev/
    terraform.tfvars
  prod/
    terraform.tfvars
```

- If you change both files in a PR, the action outputs:
  ```
  ["environments/dev/terraform.tfvars","environments/prod/terraform.tfvars"]
  ```

---

## Script Details

The underlying script (`script.sh`):

- Uses robust bash (`set -euo pipefail`)
- Works with shallow clones
- Outputs debug info for troubleshooting
- Uses `jq` for safe JSON output
- Always outputs a valid JSON array (empty if no changes)

---

## Troubleshooting & Best Practices

- Always run checkout with `fetch-depth: 0` for accurate diffs.
- If you use a non-`main` default branch, adapt the script’s `base_branch`.
- Use the output as a matrix or for conditional downstream steps.
- The action will not fail if no `.tfvars` files are changed; it emits an empty array.

---

## License

MIT (or your repository’s license)

---