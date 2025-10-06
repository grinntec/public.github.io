# Azure Policy Definitions

This directory contains Azure Policy definitions for governance and compliance automation.

## Policy: CreatedOnDate.json

### Purpose
Automatically applies a `CreatedOnDate` tag to Azure resources and resource groups that don't already have this tag.

### Policy Details
- **Mode**: Indexed (applies to all resource types that support tags)
- **Effect**: Append
- **Target**: Resources and resource groups without `CreatedOnDate` tag

### How It Works
The policy uses the `append` effect to add a `CreatedOnDate` tag with the current UTC timestamp when:
1. A resource group is created without the tag, OR
2. Any resource is created without the tag

### Tag Value
- **Tag Name**: `CreatedOnDate`
- **Tag Value**: Current UTC timestamp using `utcNow()` function
- **Format**: ISO 8601 datetime format

### Policy Rule Structure
```json
{
  "if": {
    "allOf": [
      {
        "anyOf": [
          {
            "field": "type",
            "equals": "Microsoft.Resources/subscriptions/resourceGroups"
          },
          {
            "field": "tags['CreatedOnDate']",
            "exists": "false"
          }
        ]
      }
    ]
  },
  "then": {
    "effect": "append",
    "details": [
      {
        "field": "tags['CreatedOnDate']",
        "value": "[utcNow()]"
      }
    ]
  }
}
```

### Use Cases
- **Resource Lifecycle Management** - Track when resources were created
- **Cost Management** - Identify old resources for cleanup
- **Compliance Reporting** - Audit resource creation dates
- **Automated Cleanup** - Enable time-based deletion policies

### Deployment
This policy can be assigned at:
- **Management Group** level for organization-wide enforcement
- **Subscription** level for subscription-specific governance
- **Resource Group** level for targeted application

### Integration
This policy works in conjunction with:
- Automated cleanup scripts that use the `CreatedOnDate` tag
- Cost management reports
- Resource lifecycle automation
- Compliance dashboards

### Benefits
- **Automatic Tagging** - No manual intervention required
- **Consistent Timestamps** - Standardized UTC format
- **Retroactive Application** - Applies to existing untagged resources
- **Zero Impact** - Append effect doesn't modify existing tags