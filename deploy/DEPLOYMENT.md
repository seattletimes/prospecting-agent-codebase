# Azure Deployment Scripts

This folder contains scripts for deploying the Prospecting Agent API to Azure.

## Scripts

### 1. `initial-deploy.sh`
**Purpose**: Creates all Azure resources and performs the first deployment.

**What it does**:
- Creates a new resource group (`rg-prospecting-agent-dev`)
- Creates an App Service Plan (`prospecting-agent-plan-dev`) with S1 pricing tier
- Creates Application Insights (`prospecting-agent-insights-dev`)
- Creates an App Service (`prospecting-agent-api-dev`)
- Configures environment variables
- Packages and deploys the application

**Usage**:
```bash
./initial-deploy.sh
```

**Requirements**:
- Azure CLI installed and configured
- Valid Azure subscription
- Environment variables (X_API_KEY, ADPOINT_AUTH_HEADER)

### 2. `redeploy.sh`
**Purpose**: Updates an existing deployment with new code changes.

**What it does**:
- Verifies existing Azure resources
- Backs up current environment variables
- Optionally updates environment variables
- Creates a new deployment package
- Deploys the updated application
- Restarts the App Service
- Tests the deployment

**Usage**:
```bash
./redeploy.sh
```

**Requirements**:
- Initial deployment must be completed first
- Azure CLI installed and authenticated

## Prerequisites

1. **Install Azure CLI**: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
2. **Azure Subscription**: Active Azure subscription with appropriate permissions
3. **Environment Variables**: 
   - `X_API_KEY`: API key for endpoint authentication
   - `ADPOINT_AUTH_HEADER`: Base64 encoded credentials for Adpoint API

## Resource Naming Convention

All resources follow the pattern: `{service}-{environment}`

- **Resource Group**: `rg-prospecting-agent-dev`
- **App Service Plan**: `prospecting-agent-plan-dev`
- **App Service**: `prospecting-agent-api-dev`
- **Application Insights**: `prospecting-agent-insights-dev`

## Configuration

- **Location**: West US
- **Python Version**: 3.11
- **App Service Plan**: S1 (Standard)
- **Runtime**: Linux

## Generated Files

- `prospecting-agent-api.zip`: Deployment package
- `current-settings-backup.txt`: Backup of environment variables (created during redeploy)

## Troubleshooting

### Common Issues

1. **Azure CLI not found**: Install Azure CLI and ensure it's in your PATH
2. **Authentication failed**: Run `az login` to authenticate
3. **Resource group not found**: Run `initial-deploy.sh` first
4. **Deployment failed**: Check Azure Portal for detailed error messages

### Useful Commands

```bash
# Check Azure login status
az account show

# View App Service logs
az webapp log tail --name prospecting-agent-api-dev --resource-group rg-prospecting-agent-dev

# List all resources in the resource group
az resource list --resource-group rg-prospecting-agent-dev --output table

# Check App Service status
az webapp show --name prospecting-agent-api-dev --resource-group rg-prospecting-agent-dev --query state
```

## Security Notes

- Environment variables are stored securely in Azure App Service configuration
- API keys are not logged or displayed in plain text
- All deployments use HTTPS by default
- Application Insights provides monitoring and alerting capabilities
