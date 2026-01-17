# Azure MERN Deployment - Step-by-Step Instructions

Complete guide to deploy your MERN application to Microsoft Azure.

---

## 📋 PHASE 1: PRE-DEPLOYMENT SETUP (Days 0-1)

### Step 1: Install Required Tools

#### macOS
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js (includes npm)
brew install node

# Install Git
brew install git

# Install Azure CLI
brew install azure-cli

# Verify installations
node --version      # Should be v16 or higher
npm --version
git --version
az --version
```

#### Windows (PowerShell as Admin)
```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Node.js, Git, and Azure CLI
choco install nodejs git azure-cli -y

# Verify installations
node --version
npm --version
git --version
az --version
```

#### Linux (Ubuntu/Debian)
```bash
# Update package manager
sudo apt update

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Git
sudo apt install -y git

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify installations
node --version
npm --version
git --version
az --version
```

### Step 2: Create MongoDB Atlas Cluster

#### 2.1 Create MongoDB Atlas Account
1. Go to https://www.mongodb.com/cloud/atlas
2. Click "Try Free"
3. Fill in signup form with:
   - Email address
   - Password
   - Create company/project name
4. Verify your email address
5. Click "Agree and Create Account"

#### 2.2 Create First Cluster
1. You'll be prompted to create your first cluster
2. Select "Free" cluster tier
3. Choose your preferred cloud provider (AWS, GCP, or Azure)
4. Select region closest to your Azure region:
   - US East 1 (if using Azure East US)
   - Europe West 1 (if using Azure Europe West)
   - Asia-Pacific Southeast (if using Azure Southeast Asia)
5. Click "Create Cluster" - this takes 1-2 minutes

#### 2.3 Create Database User
1. Go to "Database Access" in the left menu
2. Click "Add New Database User"
3. Choose "Password" as authentication method
4. Create username: `mern_user` (or your choice)
5. Generate secure password (or create custom):
   - At least 20 characters
   - Mix of upper, lower, numbers, symbols
6. Choose built-in role: "Atlas admin"
7. Click "Add User"
8. **Save username and password securely!**

#### 2.4 Configure Network Access
1. Go to "Network Access" in the left menu
2. Click "Add IP Address"
3. For development:
   - Select "Add Current IP Address" (if connecting from home)
   - OR "Allow Access from Anywhere" (less secure, only for testing)
4. For production:
   - Add specific Azure IP ranges or your office IPs
5. Click "Confirm"

#### 2.5 Get Connection String
1. Go back to "Clusters" overview
2. Click "Connect" on your cluster
3. Select "Connect your application"
4. Choose "Node.js" from dropdown
5. Select version "4.0 or later"
6. Copy the connection string
7. Format it properly:
```
mongodb+srv://mern_user:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/mern_db?retryWrites=true&w=majority
```

**Save this string - you'll need it for Azure!**

### Step 3: Setup Your MERN Project

#### 3.1 Clone/Setup Project
```bash
# Navigate to your project directory
cd /Users/mac/Dev\ Apps/deploy-MERN

# Initialize git
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Make scripts executable
chmod +x quickstart.sh
chmod +x build.sh
```

#### 3.2 Install Dependencies
```bash
# Run the quick start script
./quickstart.sh

# Or manually:
npm install
cd server && npm install && cd ..
cd client && npm install && cd ..
```

#### 3.3 Configure Local Environment
```bash
# Copy environment template
cp server/.env.example server/.env

# Edit server/.env
# On macOS:
nano server/.env

# Add your MongoDB connection string:
# MONGODB_URI=mongodb+srv://mern_user:PASSWORD@cluster0.xxxxx.mongodb.net/mern_db?retryWrites=true&w=majority
```

#### 3.4 Test Locally
```bash
# Start development servers
npm run dev

# You should see:
# - React frontend at http://localhost:3000
# - Express backend at http://localhost:5000
# - React showing "MERN Stack Application"

# Test backend health:
curl http://localhost:5000/api/health

# Should return: {"status":"Server is running"}
```

---

## 📋 PHASE 2: AZURE SETUP (Days 1-2)

### Step 4: Create Azure Resources

#### 4.1 Login to Azure
```bash
# Open browser for login
az login

# Select your subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Verify login
az account show
```

#### 4.2 Create Resource Group
```bash
# Save these variables
RESOURCE_GROUP="mern-app-rg"
REGION="eastus"  # or your preferred region

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $REGION

# Verify creation
az group show --name $RESOURCE_GROUP
```

#### 4.3 Create App Service Plan
```bash
# Save variables
PLAN_NAME="mern-app-plan"
SKU="B1"  # B1 for testing, S1 for production

# Create plan
az appservice plan create \
  --name $PLAN_NAME \
  --resource-group $RESOURCE_GROUP \
  --sku $SKU \
  --is-linux

# Verify creation
az appservice plan show \
  --resource-group $RESOURCE_GROUP \
  --name $PLAN_NAME
```

#### 4.4 Create Web App
```bash
# Save variables (MUST be globally unique)
APP_NAME="mern-app-yourname"  # Change "yourname" to something unique

# Create web app
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $PLAN_NAME \
  --name $APP_NAME \
  --runtime "NODE|18-lts" \
  --deployment-local-git

# Verify creation
az webapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME

# Save your app URL
# Format: https://APP_NAME.azurewebsites.net
```

### Step 5: Setup Git Deployment

#### 5.1 Get Deployment Credentials
```bash
# Get credentials for Git deployment
az webapp deployment list-publishing-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query "{Username: publishingUserName, Password: publishingUserPassword}" \
  --output json

# Save the output! You'll need:
# - Username (format: $APP_NAME)
# - Password (long random string)
```

#### 5.2 Setup Git Remote
```bash
# Get the Git clone URL
AZURE_GIT_URL=$(az webapp deployment source config-local-git \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query url --output tsv)

echo "Git URL: $AZURE_GIT_URL"

# Add Azure as git remote
git remote add azure $AZURE_GIT_URL

# Verify
git remote -v
```

#### 5.3 Initial Git Setup
```bash
# From your project root directory
cd /Users/mac/Dev\ Apps/deploy-MERN

# Stage all files
git add .

# Commit
git commit -m "Initial MERN app commit - ready for Azure deployment"

# Check status
git status
```

---

## 📋 PHASE 3: DEPLOYMENT (Days 2-3)

### Step 6: Configure Azure Environment Variables

#### 6.1 Via Azure CLI (Recommended)
```bash
# Set environment variables
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --settings \
    "MONGODB_URI=mongodb+srv://mern_user:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/mern_db?retryWrites=true&w=majority" \
    "NODE_ENV=production" \
    "PORT=8080"

# Verify settings
az webapp config appsettings list \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME
```

#### 6.2 Via Azure Portal (Alternative)
1. Go to Azure Portal (https://portal.azure.com)
2. Search for "App Services"
3. Click your app name
4. In left menu, click "Configuration"
5. Click "New Application Setting"
6. Add these one by one:

| Name | Value |
|------|-------|
| MONGODB_URI | mongodb+srv://mern_user:PASSWORD@cluster0.xxxxx.mongodb.net/mern_db?retryWrites=true&w=majority |
| NODE_ENV | production |
| PORT | 8080 |

7. Click "Save" after each entry

### Step 7: Build and Deploy

#### 7.1 Build React App
```bash
# Navigate to client directory
cd /Users/mac/Dev\ Apps/deploy-MERN/client

# Build production version
npm run build

# Verify build folder created
ls -la build/

# Go back to root
cd ..
```

#### 7.2 Commit Build and Push to Azure
```bash
# Add build folder to git
git add -A

# Commit
git commit -m "Production build and deployment configuration"

# Deploy to Azure
git push azure master

# Provide credentials when prompted:
# Username: (from Step 5.1)
# Password: (from Step 5.1)

# This will take 3-5 minutes. Watch for:
# - Deployment script running
# - npm install executing
# - Build completing
# - App starting successfully
```

#### 7.3 Monitor Deployment
```bash
# Watch logs in real-time
az webapp log tail \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME

# Or view logs via portal:
# Your App > Deployment Center > Logs
```

---

## 📋 PHASE 4: TESTING & VERIFICATION (Day 3-4)

### Step 8: Test Your Deployed Application

#### 8.1 Get Your App URL
```bash
# Get the default host name
APP_URL=$(az webapp show \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --query defaultHostName --output tsv)

echo "Your app is running at: https://$APP_URL"

# Save this URL - it's your live application!
```

#### 8.2 Test API Health
```bash
# Test health endpoint
curl https://YOUR_APP_NAME.azurewebsites.net/api/health

# Expected response:
# {"status":"Server is running"}
```

#### 8.3 Test in Browser
1. Open browser
2. Go to: `https://mern-app-yourname.azurewebsites.net`
3. You should see:
   - Purple gradient header with "MERN Stack Application"
   - "Running on Microsoft Azure"
   - "Add New Item" form
   - Empty state message

#### 8.4 Test Functionality
1. **Test Create Item:**
   - Type item name: "Test Item"
   - Click "Add Item"
   - Check item appears in list

2. **Test Complete Item:**
   - Click checkbox next to item
   - Verify strikethrough appears

3. **Test Delete Item:**
   - Click red X button
   - Verify item is removed

4. **Test Persistence:**
   - Refresh page (F5)
   - Item should still be there (stored in MongoDB)

#### 8.5 Troubleshoot Issues

**If page doesn't load:**
```bash
# Check logs
az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME

# Check if app crashed
az webapp show --resource-group $RESOURCE_GROUP --name $APP_NAME --query state

# Restart app
az webapp restart --resource-group $RESOURCE_GROUP --name $APP_NAME
```

**If API returns 500 error:**
1. Check MongoDB connection string in Azure settings
2. Verify MongoDB Atlas user credentials
3. Check IP is whitelisted in MongoDB Atlas
4. Review error logs

**If items don't save:**
1. Test MongoDB connection:
```bash
# Copy your connection string and test locally first
node -e "const mongoose = require('mongoose'); mongoose.connect('YOUR_CONNECTION_STRING').then(() => console.log('✓ MongoDB connected')).catch(e => console.log('✗ Error:', e.message))"
```

2. Ensure MONGODB_URI is set in Azure
3. Check database user has proper permissions

---

## 📋 PHASE 5: MONITORING & MAINTENANCE (Ongoing)

### Step 9: Setup Monitoring

#### 9.1 Enable Application Logging
```bash
# Enable detailed logs
az webapp log config \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --web-server-logging filesystem \
  --detailed-error-messages true \
  --failed-request-tracing true
```

#### 9.2 View Real-Time Logs
```bash
# Stream logs continuously
az webapp log tail \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --provider application

# Press Ctrl+C to stop
```

#### 9.3 Monitor Performance (Azure Portal)
1. Go to Azure Portal
2. Open your Web App
3. In left menu, under "Monitoring":
   - Click "Metrics" to see CPU, Memory, Response Time
   - Click "Application Insights" for detailed analytics
   - Click "Alerts" to set up notifications

### Step 10: Updates & Redeployment

#### 10.1 Make Code Changes
```bash
# Edit your files locally
# For example, modify client/src/App.js or add features

# Build React app
npm run build

# Commit changes
git add .
git commit -m "Feature: Add description here"

# Deploy to Azure
git push azure master
```

#### 10.2 Common Updates

**Update Dependencies:**
```bash
# Check for outdated packages
npm outdated

# Update packages safely
npm update

# Or for specific package
npm install express@latest

# Commit and deploy
git add package*.json
git commit -m "Update dependencies"
git push azure master
```

**Scale Application:**
```bash
# Upgrade to higher tier for production
az appservice plan update \
  --resource-group $RESOURCE_GROUP \
  --name $PLAN_NAME \
  --sku S1  # Change from B1 to S1

# This supports more traffic and better performance
```

---

## 📋 PHASE 6: SECURING YOUR APPLICATION

### Step 11: Security Checklist

#### 11.1 Verify Security Settings
```bash
# Check HTTPS only enforcement
az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --https-only true

# Set minimum TLS version
az webapp config set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --min-tls-version 1.2
```

#### 11.2 MongoDB Atlas Security
1. Go to MongoDB Atlas
2. Go to "Network Access"
3. Remove "Allow from Anywhere" access
4. Add specific Azure IP ranges (if known)
5. Or setup Azure Private Link for more security

#### 11.3 Application Security
```bash
# Enable Web Application Firewall (optional)
# This is in Azure Portal > Web App > Web Application Firewall

# Check for security vulnerabilities
npm audit

# Fix vulnerabilities
npm audit fix
```

---

## 🆘 TROUBLESHOOTING GUIDE

### Issue: "Cannot GET /"
**Solution:**
1. Verify React build exists: Check `/client/build` folder
2. Verify server.js serves static files correctly
3. Check app logs: `az webapp log tail ...`
4. Restart app: `az webapp restart ...`

### Issue: MongoDB Connection Error
**Solution:**
1. Verify connection string in Azure settings
2. Test locally first
3. Check IP whitelisting in MongoDB Atlas
4. Verify database user exists and has correct password
5. Check database name in connection string

### Issue: Application Times Out
**Solution:**
1. Check app tier (B1 might be too slow) - upgrade to S1
2. Monitor memory/CPU usage
3. Check for infinite loops or blocking operations
4. Restart app and monitor

### Issue: Deployment Fails
**Solution:**
1. Check git logs: `git log --oneline`
2. Review Azure deployment logs
3. Ensure all dependencies are listed in package.json
4. Verify build.sh script has execute permissions

### Issue: High Memory Usage
**Solution:**
1. Check for memory leaks in code
2. Verify MongoDB connection pooling
3. Restart app regularly if needed
4. Upgrade app tier
5. Monitor with Azure Application Insights

---

## 📞 GETTING HELP

### Check These Resources
1. **Logs:** `az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME`
2. **Azure Portal:** Review your Web App > Monitoring sections
3. **MongoDB Atlas:** Check Monitoring tab
4. **Application Insights:** Deep performance analysis

### Useful Links
- [Azure App Service Docs](https://docs.microsoft.com/azure/app-service/)
- [MongoDB Troubleshooting](https://docs.mongodb.com/atlas/troubleshoot-connection/)
- [Express.js Guide](https://expressjs.com/)
- [React Debugging](https://react.dev/learn/react-developer-tools)

---

## ✅ FINAL CHECKLIST

- [ ] All prerequisites installed
- [ ] MongoDB Atlas cluster created
- [ ] Database user created
- [ ] Connection string obtained
- [ ] Project cloned/created
- [ ] Dependencies installed
- [ ] Tested locally (both frontend and backend)
- [ ] Azure Resource Group created
- [ ] Azure App Service created
- [ ] Git deployment configured
- [ ] Environment variables set in Azure
- [ ] React app built for production
- [ ] Code deployed to Azure
- [ ] Application loads in browser
- [ ] API health check returns 200
- [ ] Can create items
- [ ] Items persist after refresh
- [ ] Logging enabled
- [ ] HTTPS enforced
- [ ] Ready for production traffic

---

**Congratulations! Your MERN app is now running on Microsoft Azure! 🎉**

For questions or issues, reference the [AZURE_DEPLOYMENT_GUIDE.md](./AZURE_DEPLOYMENT_GUIDE.md) for more details.
