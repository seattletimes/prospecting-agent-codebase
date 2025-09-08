#!/bin/bash

# Redeployment Script for Prospecting Agent API
# This script rebuilds and redeploys the application to existing Azure resources

set -e  # Exit on any error

# Configuration (should match initial deployment)
RESOURCE_GROUP="rg-prospecting-agent-dev"
APP_SERVICE="prospecting-agent-api-dev"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Starting Redeployment for Prospecting Agent API${NC}"
echo "=================================================="

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}🔐 Not logged into Azure. Please log in...${NC}"
    az login
fi

# Verify resource group exists
echo -e "${BLUE}🔍 Verifying Azure resources...${NC}"
if ! az group show --name $RESOURCE_GROUP &> /dev/null; then
    print_error "Resource group '$RESOURCE_GROUP' not found. Please run initial-deploy.sh first."
    exit 1
fi

# Verify app service exists
if ! az webapp show --name $APP_SERVICE --resource-group $RESOURCE_GROUP &> /dev/null; then
    print_error "App Service '$APP_SERVICE' not found. Please run initial-deploy.sh first."
    exit 1
fi

print_status "Azure resources verified"

# Get current environment variables (for backup)
echo -e "${BLUE}💾 Backing up current environment variables...${NC}"
az webapp config appsettings list \
    --name $APP_SERVICE \
    --resource-group $RESOURCE_GROUP \
    --output table > deploy/current-settings-backup.txt

print_status "Environment variables backed up to deploy/current-settings-backup.txt"

# Ask if user wants to update environment variables
echo -e "${YELLOW}🔑 Do you want to update environment variables? (y/n)${NC}"
read -p "Update environment variables? " UPDATE_ENV

if [[ $UPDATE_ENV =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🔑 Please provide the environment variables:${NC}"
    read -p "Enter X_API_KEY (or press Enter to keep current): " X_API_KEY
    read -p "Enter ADPOINT_AUTH_HEADER (or press Enter to keep current): " ADPOINT_AUTH_HEADER
    
    # Update environment variables if provided
    if [ ! -z "$X_API_KEY" ] || [ ! -z "$ADPOINT_AUTH_HEADER" ]; then
        echo -e "${BLUE}⚙️  Updating environment variables...${NC}"
        
        SETTINGS=""
        if [ ! -z "$X_API_KEY" ]; then
            SETTINGS="$SETTINGS X_API_KEY=\"$X_API_KEY\""
        fi
        if [ ! -z "$ADPOINT_AUTH_HEADER" ]; then
            SETTINGS="$SETTINGS ADPOINT_AUTH_HEADER=\"$ADPOINT_AUTH_HEADER\""
        fi
        
        if [ ! -z "$SETTINGS" ]; then
            az webapp config appsettings set \
                --name $APP_SERVICE \
                --resource-group $RESOURCE_GROUP \
                --settings $SETTINGS \
                --output table
            print_status "Environment variables updated"
        fi
    fi
fi

# Create new deployment package
echo -e "${BLUE}📦 Creating new deployment package...${NC}"
cd ..
zip -r deploy/prospecting-agent-api.zip . -x "*.git*" "*.venv*" "deploy/*" "*.pyc" "__pycache__/*" "*.DS_Store"

print_status "New deployment package created: deploy/prospecting-agent-api.zip"

# Deploy the application
echo -e "${BLUE}🚀 Deploying updated application to Azure...${NC}"
az webapp deployment source config-zip \
    --name $APP_SERVICE \
    --resource-group $RESOURCE_GROUP \
    --src deploy/prospecting-agent-api.zip \
    --output table

print_status "Application redeployed successfully"

# Restart the app service to ensure clean deployment
echo -e "${BLUE}🔄 Restarting App Service...${NC}"
az webapp restart \
    --name $APP_SERVICE \
    --resource-group $RESOURCE_GROUP \
    --output table

print_status "App Service restarted"

# Get the app URL
APP_URL=$(az webapp show \
    --name $APP_SERVICE \
    --resource-group $RESOURCE_GROUP \
    --query defaultHostName --output tsv)

# Test the deployment
echo -e "${BLUE}🧪 Testing deployment...${NC}"
sleep 10  # Wait for app to fully start

if curl -s -f "https://$APP_URL/docs" > /dev/null; then
    print_status "Deployment test successful - API documentation is accessible"
else
    print_warning "Deployment test failed - API documentation not accessible. Check the logs."
fi

echo ""
echo -e "${GREEN}🎉 Redeployment completed successfully!${NC}"
echo "=================================================="
echo -e "${BLUE}📋 Deployment Summary:${NC}"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  App Service: $APP_SERVICE"
echo "  Deployment Time: $(date)"
echo ""
echo -e "${BLUE}🌐 Application URLs:${NC}"
echo "  Main App: https://$APP_URL"
echo "  API Docs: https://$APP_URL/docs"
echo "  ReDoc: https://$APP_URL/redoc"
echo ""
echo -e "${BLUE}📊 Monitoring:${NC}"
echo "  App Service Logs: az webapp log tail --name $APP_SERVICE --resource-group $RESOURCE_GROUP"
echo "  Application Insights: Check Azure Portal for detailed monitoring"
echo ""
echo -e "${YELLOW}💡 Next Steps:${NC}"
echo "  1. Test your updated API endpoints"
echo "  2. Monitor the application for any issues"
echo "  3. Check Application Insights for performance metrics"
echo ""
print_status "Redeployment completed!"
