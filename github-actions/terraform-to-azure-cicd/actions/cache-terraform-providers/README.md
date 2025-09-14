# Cache Terraform Providers Composite Action

This composite GitHub Action caches Terraform provider plugins to speed up CI/CD runs. By using the `.terraform.lock.hcl` file(s) as cache keys, it ensures provider binaries are only downloaded when versions change—making your pipeline faster, more reliable, and cost-efficient.

---

## Features

- **Provider Plugin Caching:**  
  Uses [actions/cache](https://github.com/actions/cache) to cache the Terraform provider plugin directory between workflow runs.
- **Automatic Cache Keying:**  
  Keys the cache by OS and a hash of matched `.terraform.lock.hcl` files, so changes to provider versions automatically refresh the cache.
- **Configurable:**  
  Customize both the plugin cache directory and the lockfile pattern via inputs.
- **Fallback Restore:**  
  Will attempt to restore from the most recent compatible cache if an exact match is not available.
- **Debugging & Traceability:**  
  Provides detailed debug output and cache status in the workflow logs, helping you troubleshoot cache behavior.

---

## Usage

Add this action before your Terraform steps:

```yaml
- name: Cache Terraform Providers
  uses: ./.github/actions/cache-terraform-providers
  with:
    # Optional: override the plugin cache directory (default shown below)
    plugin_cache_dir: ${{ github.workspace }}/.terraform.d/plugin-cache
    # Optional: override the lockfile pattern (default shown below)
    lockfile_pattern: '**/.terraform.lock.hcl'
```

**Typical workflow example:**

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
| plugin_cache_dir | Directory to store provider plugin binaries                | No       | `${{ github.workspace }}/.terraform.d/plugin-cache` |
| lockfile_pattern | File pattern to hash for cache key                         | No       | `'**/.terraform.lock.hcl'`                   |

---

## How It Works

- **Caching:**  
  Uses [actions/cache@v4](https://github.com/actions/cache) to cache the plugin directory.
- **Cache Key:**  
  The cache key is constructed as:  
  ```
  terraform-${{ runner.os }}-${{ hashFiles(inputs.lockfile_pattern) }}
  ```
- **Fallbacks:**  
  If an exact cache is not found, the action attempts to restore from less-specific keys (by OS, and then by prefix).
- **Debug Script:**  
  After caching, a debug script prints information about the cache directory, matched lockfiles, and whether the cache was hit or missed.

---

## Best Practices

- **Set `TF_PLUGIN_CACHE_DIR`** in all Terraform steps to match the cached directory.
- **Do not use this cache for state or module data**—it is only for provider plugins.
- **If using multiple lockfiles/repositories,** be aware that all matched lockfiles are hashed together for the cache key.
- **Rotate provider versions intentionally**—changing the lockfile will refresh the cache.

---

## Troubleshooting

- **Cache not being hit:**  
  - Confirm your lockfile(s) are present and match the pattern.
  - Check debug output for the actual cache key used.
  - Ensure `TF_PLUGIN_CACHE_DIR` is set consistently in all steps.
- **Provider binaries are always downloaded:**  
  - The lockfile may be changing (check for unintended updates).
  - Cache save/restore could be failing due to permissions or runner setup.

---

## References

- [Terraform Provider Caching](https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_plugin_cache_dir)
- [actions/cache documentation](https://github.com/actions/cache)

---
