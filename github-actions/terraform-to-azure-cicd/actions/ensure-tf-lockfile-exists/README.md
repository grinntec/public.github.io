# Ensure Terraform Lockfile Exists GitHub Action

This composite GitHub Action ensures that every directory containing Terraform code in your repository has a `.terraform.lock.hcl` lockfile. If any directory is missing this file, the action will run `terraform init -backend=false` in that directory to generate it. This guarantees provider version consistency, enables reliable caching, and prevents accidental provider upgrades in CI/CD pipelines.

---

## Features

- **Auto-detects Terraform directories:**  
  Scans your repo for all directories containing `.tf` files.
- **Creates missing `.terraform.lock.hcl` files:**  
  Runs `terraform init -backend=false` only where the lockfile is absent, so it never touches your remote backends or state.
- **Safe for CI/CD:**  
  Designed for GitHub Actions runners with clear output and error handling.
- **Enables robust provider caching:**  
  Required for using [Terraform provider plugin cache](https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_plugin_cache_dir).
- **Traceable output:**  
  Prints which directories were initialized or confirms all lockfiles are present.

---

## Usage

Add this action before any provider caching or Terraform plan/apply steps:

```yaml
- name: Ensure Terraform Lockfile Exists
  uses: ./.github/actions/ensure-tf-lockfile-exists
```

**Example in a workflow:**

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Ensure Terraform Lockfile Exists
        uses: ./.github/actions/ensure-tf-lockfile-exists

      - name: Cache Terraform Providers
        uses: ./.github/actions/cache-terraform-providers

      # ... more Terraform steps ...
```

---

## How It Works

- **Scans for all unique directories containing `.tf` files** using standard Unix utilities (`find`, `xargs`, `sort`).
- **For each directory:**  
  - Checks if `.terraform.lock.hcl` exists.
  - If missing, runs `terraform init -backend=false` in that directory to generate the lockfile (does not configure or contact the backend!).
  - If `terraform init` fails, the workflow fails fast.
- **Final output:**  
  - Reports what was done, or confirms all lockfiles are present.

---

## Why Use This?

- **Terraform Best Practice:**  
  Every directory with Terraform code should have a `.terraform.lock.hcl` to ensure provider version consistency and reproducibility.
- **Protects against drift:**  
  Prevents accidental provider upgrades in CI/CD.
- **Works with provider caching:**  
  Required for effective use of provider plugin cache.

---

## Requirements

- **Terraform CLI** must be available (pre-installed on most GitHub-hosted runners).
- **Bash** shell (default on Ubuntu runners).

---

## Limitations

- Only scans for `.tf` files (does not support non-standard extensions).
- Does not validate the contents of existing lockfiles—only checks for presence.
- Fails the workflow if `terraform init` fails for any directory.

---

## License

MIT (or your repository’s license)

---