# Terraform Auto-Format & Push GitHub Action

This composite GitHub Action automatically runs `terraform fmt -recursive` in the target directory, commits and pushes any formatting changes, and writes a detailed Markdown summary to the Actions UI. Use this to enforce consistent Terraform code style across your repository.

---

## Features

- **Automated formatting:**  
  Runs `terraform fmt -recursive` in the directory of the provided file, fixing style and alignment issues across all `.tf` and `.tfvars` files.
- **Git commit & push:**  
  If formatting changes are made, automatically commits and pushes them to your branch using the provided author (defaults to GitHub Actions bot).
- **Clear summary reporting:**  
  Writes a Markdown summary to the Actions UI, listing changed files and showing diffs for each.
- **Safe & traceable:**  
  Only commits formatting changes—no functional code changes. Shows debug logs and unified diffs for auditability.
- **Supports multi-directory and monorepo setups:**  
  Operates relative to the given file, not just at repo root.

---

## Usage

Add to your workflow wherever you want to enforce Terraform formatting:

```yaml
- name: Terraform Format
  uses: ./.github/actions/terraform-fmt
  with:
    file: environments/dev/terraform.tfvars
    author_name: github-actions[bot]              # Optional
    author_email: github-actions[bot]@users.noreply.github.com   # Optional
```

**Typical workflow context:**

```yaml
jobs:
  fmt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Terraform Format
        uses: ./.github/actions/terraform-fmt
        with:
          file: src/env/dev/terraform.tfvars
```

---

## Inputs

| Name         | Description                             | Required | Default                                  |
|--------------|-----------------------------------------|----------|------------------------------------------|
| file         | Path to any `.tf` or `.tfvars` file in the target directory | Yes      | N/A                                      |
| author_name  | Git commit author name                  | No       | `github-actions[bot]`                    |
| author_email | Git commit author email                 | No       | `github-actions[bot]@users.noreply.github.com` |

---

## How It Works

- Determines the target directory based on the provided file.
- Runs `terraform fmt -recursive -diff -list=true` to auto-format all Terraform code in the directory and subdirectories.
- Checks for formatting changes using `git diff`.
- If changes are detected:
  - Stages, commits, and pushes them to your branch.
  - Writes a summary with a list of changed files and expandable diffs.
- If no changes, writes a summary stating formatting is already compliant.

---

## Example Output

If formatting changes are made, you’ll see:

```
## Terraform Auto-Format

⚠️ **Terraform formatting was applied and committed.**

The following files were reformatted automatically:

#### `src/env/dev/main.tf`
<details><summary>Show diff</summary>

```diff
[unified diff]
```
</details>
...
A commit was made and pushed to your branch by the bot.
```

If no changes were needed:

```
## Terraform Auto-Format

✅ **No formatting changes were needed.**
```

---

## Best Practices

- Use this action in PR pipelines to prevent style drift.
- Always review formatting diffs before merging.
- No functional changes are ever committed; only whitespace, alignment, and syntax corrections.

---

## Limitations

- Only works with files tracked by git.
- Will commit and push formatting changes directly—ensure branch protections and pull request reviews are in place as needed.
- Does not run on files outside the given directory.

---

## License

[MIT License](../LICENSE) © 2025 Grinntec

---
