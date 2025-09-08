#!/bin/bash

# Initial Azure Deployment Script for Prospecting Agent API
# This script creates all necessary Azure resources and deploys the application

set -e  # Exit on any error

# Configuration
RESOURCE_GROUP="rg-prospecting-agent-dev"
APP_SERVICE_PLAN="prospecting-agent-plan-dev"
APP_SERVICE="prospecting-agent-api-dev"
APP_INSIGHTS="prospecting-agent-insights-dev"
LOCATION="West US"
PYTHON_VERSION="3.11"
PLAN_SKU="S1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Initial Azure Deployment for Prospecting Agent API${NC}"
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

# Login to Azure
echo -e "${BLUE}🔐 Logging into Azure...${NC}"
az login

# Get subscription info
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo -e "${BLUE}📋 Using subscription: ${SUBSCRIPTION_ID}${NC}"

# Prompt for environment variables
echo -e "${YELLOW}🔑 Please provide the following environment variables:${NC}"
read -p "Enter X_API_KEY: " X_API_KEY
read -p "Enter ADPOINT_AUTH_HEADER (Base64 encoded): " ADPOINT_AUTH_HEADER

if [ -z "$X_API_KEY" ] || [ -z "$ADPOINT_AUTH_HEADER" ]; then
    print_error "Both X_API_KEY and ADPOINT_AUTH_HEADER are required!"
    exit 1
fi

# Create resource group
echo -e "${BLUE}📦 Creating resource group: ${RESOURCE_GROUP}${NC}"
az group create \
    --name $RESOURCE_GROUP \
    --location "$LOCATION" \
    --output table

print_status "Resource group created successfully"

# Create App Service Plan
echo -e "${BLUE}🏗️  Creating App Service Plan: ${APP_SERVICE_PLAN}${NC}"
az appservice plan create \
    --name $APP_SERVICE_PLAN \
    --resource-group $RESOURCE_GROUP \
    --location "$LOCATION" \
    --sku $PLAN_SKU \
    --is-linux \
    --output table

print_status "App Service Plan created successfully"

# Create App Insights
echo -e "${BLUE}📊 Creating Application Insights: ${APP_INSIGHTS}${NC}"
az monitor app-insights component create \
    --app $APP_INSIGHTS \
    --location "$LOCATION" \
    --resource-group $RESOURCE_GROUP \
    --output table

# Get App Insights instrumentation key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
    --app $APP_INSIGHTS \
    --resource-group $RESOURCE_GROUP \
    --query instrumentationKey --output tsv)

print_status "Application Insights created successfully"

# Create App Service
echo -e "${BLUE}🌐 Creating App Service: ${APP_SERVICE}${NC}"
az webapp create \
    --name $APP_SERVICE \
    --resource-group $RESOURCE_GROUP \
    --plan $APP_SERVICE_PLAN \
    --runtime "PYTHON|$PYTHON_VERSION" \
    --output table

print_status "App Service created successfully"

# Configure App Service settings
echo -e "${BLUE}⚙️  Configuring App Service settings...${NC}"

# Set environment variables
az webapp config appsettings set \
    --name $APP_SERVICE \
    --resource-group $RESOURCE_GROUP \
    --settings \
        X_API_KEY="$X_API_KEY" \
        ADPOINT_AUTH_HEADER="$ADPOINT_AUTH_HEADER" \
        APPINSIGHTS_INSTRUMENTATIONKEY="$INSTRUMENTATION_KEY" \
        APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=$INSTRUMENTATION_KEY" \
        PYTHONPATH="/home/site/wwwroot" \
        SCM_DO_BUILD_DURING_DEPLOYMENT="true" \
    --output table

# Configure startup command
az webapp config set \
    --name $APP_SERVICE \
    --resource-group $RESOURCE_GROUP \
    --startup-file "startup.sh" \
    --output table

print_status "App Service configured successfully"

# Create deployment package
echo -e "${BLUE}📦 Creating deployment package...${NC}"
cd ..
zip -r deploy/prospecting-agent-api.zip . -x "*.git*" "*.venv*" "deploy/*" "*.pyc" "__pycache__/*" "*.DS_Store"

print_status "Deployment package created: deploy/prospecting-agent-api.zip"

# Deploy the application
echo -e "${BLUE}🚀 Deploying application to Azure...${NC}"
az webapp deployment source config-zip \
    --name $APP_SERVICE \
    --resource-group $RESOURCE_GROUP \
    --src deploy/prospecting-agent-api.zip \
    --output table

print_status "Application deployed successfully"

# Get the app URL
APP_URL=$(az webapp show \
    --name $APP_SERVICE \
    --resource-group $RESOURCE_GROUP \
    --query defaultHostName --output tsv)

echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo "=================================================="
echo -e "${BLUE}📋 Deployment Summary:${NC}"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  App Service: $APP_SERVICE"
echo "  App Service Plan: $APP_SERVICE_PLAN"
echo "  Application Insights: $APP_INSIGHTS"
echo "  Location: $LOCATION"
echo ""
echo -e "${BLUE}🌐 Application URLs:${NC}"
echo "  Main App: https://$APP_URL"
echo "  API Docs: https://$APP_URL/docs"
echo "  ReDoc: https://$APP_URL/redoc"
echo ""
echo -e "${BLUE}📊 Monitoring:${NC}"
echo "  App Insights: https://portal.azure.com/#@/resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/microsoft.insights/components/$APP_INSIGHTS"
echo ""
echo -e "${YELLOW}💡 Next Steps:${NC}"
echo "  1. Test your API endpoints using the URLs above"
echo "  2. Monitor your application in Application Insights"
echo "  3. Use the redeploy script for future updates: ./redeploy.sh"
echo ""
print_status "Initial deployment completed!"
