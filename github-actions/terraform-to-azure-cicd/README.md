# Terraform-to-Azure CI/CD

This workflow is part of the Terraform-to-Azure deployment automation pipeline.
Its primary role is to detect changes to terraform.tfvars files in pull requests or direct pushes to the main branch, and then trigger targeted downstream processing for each changed file.

- [Architecture](https://www.grinntec.net/architecture/terraform-to-azure-cicd/)
- [Design Pattern: Detect](https://www.grinntec.net/design-patterns/github-actions/automate-terraform-deployment-detect/)
- [Design Pattern: Process](https://www.grinntec.net/design-patterns/github-actions/automate-terraform-deployment-process/)
