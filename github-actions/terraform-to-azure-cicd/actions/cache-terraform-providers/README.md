# Cache Terraform Providers Composite Action

This GitHub composite action sets up caching for Terraform provider plugins to speed up CI/CD runs. By leveraging the `.terraform.lock.hcl` file as a cache key, it ensures your workflows only download provider binaries when their versions change, leading to faster and more reliable Terraform automation.

---

## Features

- **Provider Plugin Caching:**  
  Uses the [actions/cache](https://github.com/actions/cache) action to cache the Terraform provider plugins directory between workflow runs.
- **Automatic Cache Keying:**  
  The cache is keyed by the OS and a hash of all matched `.terraform.lock.hcl` files, so the cache automatically updates when provider versions change.
- **Configurable:**  
  Customize the plugin cache directory and the lockfile pattern if needed.
- **Fallback Restore:**  
  Attempts to restore from the most recent compatible cache if an exact match is not found.

---

## Usage

```yaml
- name: Cache Terraform Providers
  uses: ./.github/actions/cache-terraform-providers
  with:
    # Optional: override the plugin cache directory (default is .terraform.d/plugin-cache)
    plugin_cache_dir: ${{ github.workspace }}/.terraform.d/plugin-cache
    # Optional: override the lockfile pattern (default is '**/.terraform.lock.hcl')
    lockfile_pattern: '**/.terraform.lock.hcl'
```

**Example in a workflow:**

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cache Terraform Providers
        uses: ./.github/actions/cache-terraform-providers

      - name: Terraform Init
        env:
          TF_PLUGIN_CACHE_DIR: ${{ github.workspace }}/.terraform.d/plugin-cache
        run: terraform init
```

---

## Inputs

| Name             | Description                                                | Required | Default                                      |
|------------------|------------------------------------------------------------|----------|----------------------------------------------|
| plugin_cache_dir | Directory to store plugin binaries                         | No       | `${{ github.workspace }}/.terraform.d/plugin-cache` |
| lockfile_pattern | File pattern to hash for cache key                         | No       | `'**/.terraform.lock.hcl'`                   |

---

## How It Works

- The action uses [actions/cache@v4](https://github.com/actions/cache) to cache the Terraform plugin cache directory.
- The cache key is constructed as:  
  `terraform-${{ runner.os }}-${{ hashFiles(inputs.lockfile_pattern) }}`
- When provider versions change (i.e., the lockfile changes), the cache is invalidated and a new cache is created.
- Fallback restore keys allow reuse of older caches if possible.

---

## Best Practices

- **Set `TF_PLUGIN_CACHE_DIR` in all Terraform steps** to match the directory used in this action.
- **Do not use this cache for state or module data**—it is only for provider plugins.
- **If using multiple lockfiles/repositories,** be aware that all matched lockfiles are hashed together for the cache key.
- **Ensure permissions** on the cache directory are compatible with your runner setup.

---

## References

- [Terraform Provider Caching](https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_plugin_cache_dir)
- [actions/cache documentation](https://github.com/actions/cache)

---
