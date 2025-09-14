# Build Matrix from CI Modes GitHub Action

This composite GitHub Action converts a JSON mapping of directory-to-mode into an array of objects, making it easy to use as a matrix in downstream jobs. It is ideal for dynamically generating test, validation, or deployment jobs based on the CI modes determined for multiple Terraform (or other) directories.

---

## Features

- **Input:** Accepts a JSON object mapping directory names to CI modes (e.g., `{"test-00":"validate","test-01":"apply"}`).
- **Output:** Produces a JSON array of `{dir, mode}` objects suitable for use as a [matrix strategy](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs) in GitHub Actions.
- **Robust:** Validates the output and falls back to an empty matrix if the input is invalid.
- **Portable:** Works with any CI mode naming scheme.

---

## Usage

### With Other Actions

This action is typically used after a step that determines which directories changed and what CI mode should be run in each (for example, after [determine-ci-mode](../determine-ci-mode/)).

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

### Use as a Matrix

Pass the output to job matrix:

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

- **Shell Script:** Uses Bash and [jq](https://stedolan.github.io/jq/) to transform the input map to an array.
- **Validation:** Ensures the output is valid JSON. If not, emits an empty array to avoid workflow failures.

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

## Best Practices

- Always validate the `ci_modes` input is a valid JSON object.
- Use `"matrix": ${{ fromJson(outputs.matrix) }}` for dynamic job creation.
- Combine with other detection actions for a fully automated, flexible CI pipeline.

---