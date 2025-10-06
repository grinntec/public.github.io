# GitHub Actions

This directory contains GitHub Actions workflows and custom actions for automating CI/CD pipelines and infrastructure deployment.

## Overview

GitHub Actions is an automation platform built into GitHub that enables you to create, run, and manage workflows directly in your repository. It allows you to automate tasks such as building, testing, and deploying code, as well as managing issues and pull requests. Workflows are defined using YAML files and can be triggered by events like pushes, pull requests, or on a schedule, making it easy to implement continuous integration and continuous delivery (CI/CD) pipelines for your projects.

## Directory Structure

- **terraform-to-azure-cicd/** - Comprehensive Terraform CI/CD pipeline for Azure deployments

## Key Features

### Workflow Automation
- **CI/CD Pipelines** - Automated build, test, and deployment processes
- **Infrastructure as Code** - Terraform deployment automation
- **Multi-environment Support** - Different workflows for dev, staging, and production
- **Matrix Builds** - Parallel execution for multiple configurations

### Custom Actions
- **Reusable Components** - Custom actions for common tasks
- **Terraform Operations** - Specialized actions for Terraform workflows
- **Azure Integration** - Actions specifically designed for Azure deployments
- **Security Scanning** - Automated security and compliance checks

## Getting Started

### Workflow Files Location
GitHub Actions workflows are stored in:
```
.github/
└── workflows/
    ├── ci.yaml
    ├── deploy.yaml
    └── security.yaml
```

### Basic Workflow Structure
```yaml
name: Workflow Name
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup
      run: echo "Setting up..."
    - name: Build
      run: echo "Building..."
```

## Common Triggers

### Event-Based Triggers
- **push** - Code pushes to specific branches
- **pull_request** - Pull request creation or updates
- **release** - Release creation or publication
- **schedule** - Cron-based scheduling
- **workflow_dispatch** - Manual workflow triggering

### Example Triggers
```yaml
on:
  push:
    branches: [main, develop]
    paths: ['src/**', '!docs/**']
  pull_request:
    types: [opened, synchronize, reopened]
  schedule:
    - cron: '0 2 * * 1'  # Every Monday at 2 AM
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'staging'
```

## Security Best Practices

### Secrets Management
```yaml
steps:
- name: Deploy to Azure
  env:
    AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
    AZURE_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
    AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
```

### Permission Management
```yaml
permissions:
  contents: read
  issues: write
  pull-requests: write
  id-token: write  # For OIDC authentication
```

### Environment Protection
```yaml
jobs:
  deploy:
    environment: production
    runs-on: ubuntu-latest
    steps:
    - name: Deploy
      run: echo "Deploying to production"
```

## Custom Actions Development

### Action Structure
```
action-name/
├── action.yaml      # Action definition
├── README.md        # Documentation
└── scripts/         # Implementation scripts
```

### Basic Action Definition
```yaml
name: 'Custom Action'
description: 'Description of what this action does'
inputs:
  input-name:
    description: 'Input description'
    required: true
    default: 'default-value'
outputs:
  output-name:
    description: 'Output description'
    value: ${{ steps.step-id.outputs.value }}
runs:
  using: 'composite'
  steps:
  - name: Run script
    shell: bash
    run: echo "Action logic here"
```

## Workflow Optimization

### Caching
```yaml
- name: Cache dependencies
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### Matrix Strategies
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    node-version: [14, 16, 18]
jobs:
  test:
    runs-on: ${{ matrix.os }}
    steps:
    - uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
```

### Conditional Execution
```yaml
steps:
- name: Deploy to production
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: echo "Deploying to production"
```

## Monitoring and Debugging

### Workflow Status
- View workflow runs in the Actions tab
- Check job logs for detailed output
- Monitor workflow execution times
- Set up notification for failures

### Debug Techniques
```yaml
steps:
- name: Debug information
  run: |
    echo "Event: ${{ github.event_name }}"
    echo "Ref: ${{ github.ref }}"
    echo "SHA: ${{ github.sha }}"
    echo "Actor: ${{ github.actor }}"
```

### Logging
```yaml
steps:
- name: Enhanced logging
  run: |
    echo "::notice::This is a notice"
    echo "::warning::This is a warning"
    echo "::error::This is an error"
```

## Integration Examples

### Slack Notifications
```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    channel: '#deployments'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Teams Notifications
```yaml
- name: Teams Notification
  uses: skitionek/notify-microsoft-teams@master
  with:
    webhook_url: ${{ secrets.TEAMS_WEBHOOK }}
    message: 'Deployment completed successfully'
```

## Cost Management

### Runner Usage
- Use self-hosted runners for cost reduction
- Optimize workflow execution time
- Use appropriate runner sizes
- Implement efficient caching strategies

### Resource Optimization
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 30  # Prevent long-running jobs
    steps:
    - name: Efficient build
      run: echo "Optimized build process"
```

## External Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [Grinntec GitHub Actions Articles](https://www.grinntec.net/tags/#github-actions)