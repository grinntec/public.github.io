# Configure Git for Private Terraform Modules GitHub Action

This composite GitHub Action configures `git` to use a GitHub Personal Access Token (PAT) for accessing private Terraform modules hosted on GitHub. It ensures that any Terraform operation—such as `terraform init`—can fetch private modules without manual authentication, enabling secure, automated CI/CD pipelines.

---

## Features

- **Automatic git credential setup:**  
  Configures global git credentials so any `https://github.com/` URL is transparently rewritten to include your GitHub PAT, allowing seamless authentication for private Terraform modules.
- **Security-first design:**  
  Never prints the PAT to logs, redacts tokens from debug output, and uses secure GitHub Actions secrets to pass credentials.
- **Status output:**  
  Provides clear status output (`configured=true/false`) and summary notices in the Actions UI for auditability and debugging.
- **Modular and reusable:**  
  Works in any workflow, repo, or environment where Terraform needs private module access.

---

## Usage

Add a step before any Terraform operation that requires private module access:

```yaml
- name: Configure git for private modules
  uses: ./.github/actions/configure-git-private-modules
  with:
    github_token: ${{ secrets.YOUR_GITHUB_PAT }}
```

Replace `YOUR_GITHUB_PAT` with a secret that has at least `repo` scope for read access to the needed modules.

**Example in a workflow:**

```yaml
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configure git for private modules
        uses: ./.github/actions/configure-git-private-modules
        with:
          github_token: ${{ secrets.GRINNTEC_TERRAFORM_DEPLOYMENTS_AZURE_PAT }}

      - name: Terraform Init
        run: terraform init
```

---

## Inputs

| Name          | Description                            | Required | Example                              |
|---------------|----------------------------------------|----------|--------------------------------------|
| github_token  | GitHub PAT for private repo access     | Yes      | `${{ secrets.GRINNTEC_TERRAFORM_DEPLOYMENTS_AZURE_PAT }}` |

---

## Outputs

| Name        | Description                                                 | Example  |
|-------------|-------------------------------------------------------------|----------|
| configured  | Whether git config was set successfully (`true`/`false`)    | `true`   |

---

## How It Works

- Sets a global git config:
  ```
  git config --global url."https://<github_token>:x-oauth-basic@github.com/".insteadOf "https://github.com/"
  ```
- This causes all `https://github.com/` URLs (used by Terraform modules) to use the token for authentication automatically.
- Only affects the current workflow runner; does **not** persist outside the workflow run.

---

## Security

- **Never prints or logs the actual token.**
- Redacts any accidental token in debug output.
- Accepts only via secure GitHub Actions secrets.
- Use the least privilege required (`repo` scope for private repos).

---

## Best Practices

- Use this action **before** any Terraform step that reads private modules.
- Rotate your PAT regularly and use organization secrets if possible.
- Do **not** use the same PAT for unrelated workflows or repositories.
- Remove the git config after workflow completion if extra security is desired (not strictly necessary for ephemeral CI runners).

---

## Troubleshooting

- If `configured=false` or you see errors about module access:
  - Ensure the PAT is set and passed correctly via workflow secrets.
  - Ensure the PAT has sufficient permissions (`repo` scope).
  - Check for typos or misconfigured secret names.
  - Review workflow logs for debug output and notices.

---

## License

MIT (or your repository’s license)

---
