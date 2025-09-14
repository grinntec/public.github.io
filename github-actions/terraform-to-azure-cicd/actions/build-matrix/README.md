# Build Matrix from CI Modes GitHub Action

This composite GitHub Action transforms a JSON mapping of directory names to CI modes (such as `{"test-00":"validate","test-01":"apply"}`) into an array of objects, allowing dynamic matrix job creation in downstream workflows. It is designed to automate testing, validation, or deployment pipelines for multiple Terraform (or other) directories.

---

## Features

- **Input:**  
  Accepts a JSON object mapping directory names to CI modes (e.g., `{"test-00":"validate","test-01":"apply"}`).

- **Output:**  
  Produces a JSON array of `{dir, mode}` objects, ready for use as a [matrix strategy](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs) in GitHub Actions.

- **Validation:**  
  Checks that the input is valid; outputs an empty matrix and emits a warning if input is invalid.

- **Portable and Flexible:**  
  Works with any directory and CI mode naming scheme.

---

## Usage Example

This action is typically used after a step that determines which directories changed and what CI mode should be run for each (such as `determine-ci-mode`).

```yaml
jobs:
  determine-matrix:
    runs-on: ubuntu-latest
    steps:
      - name: Get CI modes
        id: ci-modes
        # ... your action that outputs ci_modes as JSON ...

      - name: Build matrix from CI modes
        id: matrix
        uses: ./.github/actions/build-matrix-from-ci-modes
        with:
          ci_modes: ${{ steps.ci-modes.outputs.ci_modes }}

      - name: Show matrix
        run: echo '${{ steps.matrix.outputs.matrix }}'
```

Use the output for a matrix job:

```yaml
jobs:
  run-matrix:
    needs: determine-matrix
    runs-on: ubuntu-latest
    strategy:
      matrix: ${{ fromJson(needs.determine-matrix.outputs.matrix) }}
    steps:
      - run: |
          echo "Directory: ${{ matrix.dir }}"
          echo "Mode: ${{ matrix.mode }}"
```

---

## Inputs

| Name      | Description                                                        | Required | Example                                     |
|-----------|--------------------------------------------------------------------|----------|---------------------------------------------|
| ci_modes  | JSON object mapping directory to CI mode (e.g., `{"a":"plan"}`)    | Yes      | `{"test-00":"validate","test-01":"apply"}`  |

---

## Outputs

| Name   | Description                                                    | Example                                                                                           |
|--------|----------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| matrix | JSON array of `{dir, mode}` objects for use as a matrix        | `[{"dir":"test-00","mode":"validate"},{"dir":"test-01","mode":"apply"}]`                          |

---

## Implementation Details

- **Shell Script:**  
  Uses Bash and [`jq`](https://stedolan.github.io/jq/) to convert the input mapping to an array.
- **Validation:**  
  Ensures the output is valid JSON. If input is invalid, emits an empty array and a warning in the Actions log.

#### Example transformation

**Input:**
```json
{
  "test-00": "validate",
  "test-01": "apply"
}
```

**Output:**
```json
[
  {"dir": "test-00", "mode": "validate"},
  {"dir": "test-01", "mode": "apply"}
]
```

---

## Requirements

- **jq** must be available on the runner (GitHub-hosted runners include this by default).

---

## Troubleshooting

- **Output is `[]`:**  
  Check that your input is a valid JSON object (not an array). Example valid input: `{"test-00":"validate","test-01":"apply"}`.
- **Warning about invalid JSON:**  
  Double-check that your workflow passes the correct variable and that it is properly quoted/escaped.

---

## Best Practices

- Always validate the `ci_modes` input is a valid JSON object.
- Use `"matrix": ${{ fromJson(outputs.matrix) }}` for dynamic job creation.
- Combine with other detection actions for a fully automated, flexible CI pipeline.

---

## License

[MIT License](../LICENSE) © 2025 Grinntec
