#!/usr/bin/env bash

# Azure MERN Deployment Helper Script
# This script automates the Azure deployment process

set -e  # Exit on error

echo "🚀 Azure MERN Deployment Helper"
echo "================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}✗ Azure CLI is not installed${NC}"
    echo "Install from: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

echo -e "${GREEN}✓ Azure CLI found${NC}"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Git found${NC}"
echo ""

# Prompt for configuration
echo "📋 Configuration Setup"
echo "====================="
echo ""

read -p "Enter Azure Resource Group name (e.g., mern-app-rg): " RESOURCE_GROUP
read -p "Enter Azure Region (e.g., eastus, westus, eastasia): " REGION
read -p "Enter Azure App Name (must be globally unique, e.g., mern-app-john): " APP_NAME
read -p "Enter App Service Plan name (e.g., mern-app-plan): " PLAN_NAME
read -p "Enter SKU (B1 for testing, S1 for production): " SKU

# Validate inputs
if [ -z "$RESOURCE_GROUP" ] || [ -z "$REGION" ] || [ -z "$APP_NAME" ] || [ -z "$PLAN_NAME" ]; then
    echo -e "${RED}✗ All fields are required${NC}"
    exit 1
fi

echo ""
echo "📝 Configuration Summary:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Region: $REGION"
echo "  App Name: $APP_NAME"
echo "  Plan Name: $PLAN_NAME"
echo "  SKU: $SKU"
echo ""

read -p "Continue with these settings? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo "🔐 Logging into Azure..."
    az login
fi

echo -e "${GREEN}✓ Logged into Azure${NC}"
echo ""

# Get current subscription
SUBSCRIPTION=$(az account show --query id -o tsv)
echo "Using subscription: $SUBSCRIPTION"
echo ""

# Create resource group
echo "📦 Creating Resource Group..."
if az group exists --name "$RESOURCE_GROUP" | grep -q false; then
    az group create --name "$RESOURCE_GROUP" --location "$REGION"
    echo -e "${GREEN}✓ Resource Group created${NC}"
else
    echo -e "${YELLOW}⚠ Resource Group already exists${NC}"
fi

echo ""

# Create app service plan
echo "📦 Creating App Service Plan..."
PLAN_EXISTS=$(az appservice plan show --resource-group "$RESOURCE_GROUP" --name "$PLAN_NAME" 2>/dev/null | grep -c "name" || true)

if [ "$PLAN_EXISTS" -eq 0 ]; then
    az appservice plan create \
        --name "$PLAN_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --sku "$SKU" \
        --is-linux
    echo -e "${GREEN}✓ App Service Plan created${NC}"
else
    echo -e "${YELLOW}⚠ App Service Plan already exists${NC}"
fi

echo ""

# Create web app
echo "📦 Creating Web App..."
APP_EXISTS=$(az webapp show --resource-group "$RESOURCE_GROUP" --name "$APP_NAME" 2>/dev/null | grep -c "name" || true)

if [ "$APP_EXISTS" -eq 0 ]; then
    az webapp create \
        --resource-group "$RESOURCE_GROUP" \
        --plan "$PLAN_NAME" \
        --name "$APP_NAME" \
        --runtime "NODE|18-lts" \
        --deployment-local-git
    echo -e "${GREEN}✓ Web App created${NC}"
else
    echo -e "${YELLOW}⚠ Web App already exists${NC}"
fi

echo ""

# Get Git URL
echo "🔧 Setting up Git Deployment..."
GIT_URL=$(az webapp deployment source config-local-git \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --query url --output tsv)

echo -e "${GREEN}✓ Git remote URL: $GIT_URL${NC}"

# Check if git remote already exists
if git remote get-url azure > /dev/null 2>&1; then
    echo "Removing existing azure remote..."
    git remote remove azure
fi

# Add Azure remote
git remote add azure "$GIT_URL"
echo -e "${GREEN}✓ Git remote 'azure' added${NC}"

echo ""

# Get deployment credentials
echo "🔐 Getting Deployment Credentials..."
CREDS=$(az webapp deployment list-publishing-credentials \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --query "{Username: publishingUserName, Password: publishingUserPassword}")

echo -e "${YELLOW}Save these credentials:${NC}"
echo "$CREDS"
echo ""

# Prompt for MongoDB connection string
echo "📚 MongoDB Configuration"
echo "======================="
echo ""
read -p "Enter your MongoDB Atlas connection string: " MONGODB_URI

if [ -z "$MONGODB_URI" ]; then
    echo -e "${RED}✗ MongoDB connection string is required${NC}"
    exit 1
fi

echo ""

# Set environment variables
echo "🔧 Setting Environment Variables..."
az webapp config appsettings set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --settings \
        "MONGODB_URI=$MONGODB_URI" \
        "NODE_ENV=production" \
        "PORT=8080"

echo -e "${GREEN}✓ Environment variables set${NC}"

# Enable logging
echo "📊 Enabling Application Logging..."
az webapp log config \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --web-server-logging filesystem \
    --detailed-error-messages true

echo -e "${GREEN}✓ Logging enabled${NC}"

# Enforce HTTPS
echo "🔒 Enforcing HTTPS..."
az webapp config set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --https-only true

echo -e "${GREEN}✓ HTTPS enforced${NC}"

echo ""
echo "==============================================="
echo "✅ Azure Infrastructure Setup Complete!"
echo "==============================================="
echo ""
echo "📍 Your Application URL:"
APP_URL=$(az webapp show --resource-group "$RESOURCE_GROUP" --name "$APP_NAME" --query defaultHostName -o tsv)
echo "   https://$APP_URL"
echo ""
echo "🚀 Next Steps:"
echo "1. Build React app: npm run build"
echo "2. Commit changes: git add . && git commit -m 'Ready for deployment'"
echo "3. Deploy: git push azure master"
echo "4. Monitor: az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME"
echo "5. Test: Open https://$APP_URL in your browser"
echo ""
echo "📚 For detailed guide, see STEP_BY_STEP_GUIDE.md"
echo "==============================================="
echo ""
