# Configure Git for Private Terraform Modules GitHub Action

This composite GitHub Action configures `git` to allow Terraform to fetch private modules from GitHub repositories using a Personal Access Token (PAT). It's essential when your Terraform configurations reference private module sources such as `git::https://github.com/your-org/private-terraform-module.git`.

---

## Features

- **Configures global git credentials:**  
  Sets up git so that any `https://github.com/` URL is automatically rewritten to include your GitHub PAT, allowing `terraform init` and other tools to clone private modules without manual intervention.
- **Supports modular and reusable workflows:**  
  Makes it easy to add private module support to any Terraform CI/CD pipeline.
- **Security:**  
  Does **not** echo the token to logs and is safe for use in GitHub Actions.

---

## Usage

Add a step before any Terraform operation that fetches private modules:

```yaml
- name: Configure git for private modules
  uses: ./.github/actions/configure-git-private-modules
  with:
    github_token: ${{ secrets.YOUR_GITHUB_PAT }}
```

Replace `YOUR_GITHUB_PAT` with a secret that has at least `repo` scope for read access.

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
| github_token  | GitHub PAT for private repo access     | Yes      | `${{ secrets.GH_PAT }}`              |

---

## How It Works

- Sets a global git config:
  ```
  git config --global url."https://<github_token>:x-oauth-basic@github.com/".insteadOf "https://github.com/"
  ```
- This causes all `https://github.com/` URLs (used by Terraform modules) to use the token for authentication automatically.
- Only affects the current workflow runner; it does **not** persist globally.

---

## Security

- **Never echo or log the actual token.**
- Use [GitHub Actions secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) to provide the token securely.
- Use the least privilege required (`repo` scope for private repos).

---

## Best Practices

- Use this action **before** any Terraform step that reads private modules.
- Rotate your PAT regularly and use organization secrets if possible.
- Do **not** use the same PAT for unrelated workflows or repositories.

---

## License

MIT (or your repository’s license)

---