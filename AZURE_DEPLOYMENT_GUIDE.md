# MERN Stack Application - Azure Deployment Guide

## Prerequisites
- Microsoft Azure Account
- MongoDB Atlas Account
- Git installed
- Node.js installed locally

## Step 1: MongoDB Atlas Setup

### Create MongoDB Atlas Cluster
1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Sign up or log in to your account
3. Create a new project
4. Click "Build a Database"
5. Choose the free tier (M0)
6. Select your preferred region
7. Click "Create Cluster"

### Configure Network Access
1. In MongoDB Atlas, go to "Network Access"
2. Click "Add IP Address"
3. Select "Allow Access from Anywhere" (or add specific Azure IP ranges)
4. Click "Confirm"

### Create Database User
1. Go to "Database Access"
2. Click "Add New Database User"
3. Create username and password
4. Choose "Built-in Role" > "Atlas admin"
5. Click "Add User"

### Get Connection String
1. Click "Connect" on your cluster
2. Select "Connect your application"
3. Choose "Node.js" and version "4.0 or later"
4. Copy the connection string
5. Replace `<username>`, `<password>`, and `<dbname>` with your values

Example: `mongodb+srv://username:password@cluster.mongodb.net/dbname?retryWrites=true&w=majority`

---

## Step 2: Azure Setup

### Create Azure Resource Group
```bash
az group create --name mern-app-rg --location eastus
```

### Create Azure Web App
```bash
az appservice plan create \
  --name mern-app-plan \
  --resource-group mern-app-rg \
  --sku B1 \
  --is-linux

az webapp create \
  --resource-group mern-app-rg \
  --plan mern-app-plan \
  --name mern-app-yourname \
  --runtime "NODE|18-lts" \
  --deployment-local-git
```

Replace `mern-app-yourname` with a unique name (will be your app URL).

### Get Deployment Credentials
```bash
az webapp deployment list-publishing-credentials \
  --resource-group mern-app-rg \
  --name mern-app-yourname \
  --query "{username: publishingUserName, password: publishingUserPassword}"
```

Save the username and password - you'll need them for Git deployment.

---

## Step 3: Local Preparation

### Setup Environment Variables
```bash
# Copy the example env file
cp server/.env.example server/.env

# Edit server/.env with your values:
# PORT=5000
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/dbname?retryWrites=true&w=majority
# NODE_ENV=production
```

### Install Dependencies Locally
```bash
# Install root dependencies
npm install

# Install server dependencies
cd server
npm install
cd ..

# Install client dependencies
cd client
npm install
cd ..
```

### Build React App Locally
```bash
cd client
npm run build
cd ..
```

---

## Step 4: Git Setup & Deployment

### Initialize Git Repository
```bash
git init
git add .
git commit -m "Initial MERN app commit"
```

### Add Azure Remote
```bash
az webapp deployment source config-local-git \
  --resource-group mern-app-rg \
  --name mern-app-yourname

# The output will be your Git URL, save it
# Format: https://<username>@mern-app-yourname.scm.azurewebsites.net/mern-app-yourname.git
```

### Add Remote and Push
```bash
git remote add azure https://<username>@mern-app-yourname.scm.azurewebsites.net/mern-app-yourname.git

git push azure master
# Use the password from Step 2 when prompted
```

---

## Step 5: Configure Azure Environment Variables

### Via Azure Portal
1. Go to Azure Portal
2. Navigate to your Web App
3. Click "Configuration" in the left menu
4. Click "New Application Setting"
5. Add these settings:

| Name | Value |
|------|-------|
| `MONGODB_URI` | Your MongoDB connection string |
| `NODE_ENV` | `production` |
| `PORT` | `8080` |

6. Click "Save"

### Via Azure CLI
```bash
az webapp config appsettings set \
  --resource-group mern-app-rg \
  --name mern-app-yourname \
  --settings \
    MONGODB_URI="mongodb+srv://username:password@cluster.mongodb.net/dbname?retryWrites=true&w=majority" \
    NODE_ENV="production"
```

---

## Step 6: Configure Deployment

### Update Web App Settings
```bash
# Set startup command
az webapp config set \
  --resource-group mern-app-rg \
  --name mern-app-yourname \
  --startup-file "build.sh"
```

### Enable Logs
```bash
az webapp log config \
  --resource-group mern-app-rg \
  --name mern-app-yourname \
  --web-server-logging filesystem
```

---

## Step 7: Test Your Deployment

### Check Application Status
```bash
# Get your app URL
az webapp show \
  --resource-group mern-app-rg \
  --name mern-app-yourname \
  --query defaultHostName
```

### Access Your App
Open your browser and go to: `https://mern-app-yourname.azurewebsites.net`

### Test API Endpoint
```bash
curl https://mern-app-yourname.azurewebsites.net/api/health
```

Expected response:
```json
{"status": "Server is running"}
```

### View Logs
```bash
az webapp log tail \
  --resource-group mern-app-rg \
  --name mern-app-yourname
```

---

## Step 8: Troubleshooting

### If App Doesn't Start
1. Check logs: `az webapp log tail --resource-group mern-app-rg --name mern-app-yourname`
2. Verify MongoDB connection string is correct
3. Ensure PORT environment variable is set
4. Check that build.sh executed successfully

### If Database Connection Fails
1. Verify MongoDB Atlas user credentials
2. Check IP whitelist in MongoDB Atlas (allow Azure IPs)
3. Verify database name in connection string
4. Test connection string locally before deploying

### If React App Doesn't Load
1. Verify `npm run build` created `/client/build` folder
2. Check that server.js serves static files from build folder
3. Look for 404 errors in browser console

### SSH into App for Debugging
```bash
az webapp create-remote-connection \
  --resource-group mern-app-rg \
  --name mern-app-yourname
```

---

## Step 9: Updates and Redeployment

### Make Code Changes
1. Edit files locally
2. Rebuild React: `cd client && npm run build && cd ..`
3. Commit: `git add . && git commit -m "Update message"`
4. Push to Azure: `git push azure master`

---

## Step 10: Monitoring and Maintenance

### Monitor Application Performance
```bash
az monitor metrics list-definitions \
  --resource-group mern-app-rg \
  --resource-type "Microsoft.Web/sites" \
  --resource mern-app-yourname
```

### Scale Your App
```bash
az appservice plan update \
  --resource-group mern-app-rg \
  --name mern-app-plan \
  --sku S1  # Change from B1 to S1 for production
```

### Backup Configuration
Always keep your MongoDB connection string and deployment credentials secure!

---

## Useful Commands Reference

```bash
# List all resources
az webapp list --resource-group mern-app-rg

# Get detailed app info
az webapp show --resource-group mern-app-rg --name mern-app-yourname

# Restart app
az webapp restart --resource-group mern-app-rg --name mern-app-yourname

# Delete app (if needed)
az webapp delete --resource-group mern-app-rg --name mern-app-yourname
```

---

## Environment Variables Checklist

- [ ] MONGODB_URI set in Azure
- [ ] NODE_ENV set to "production"
- [ ] PORT set to 8080
- [ ] All sensitive data removed from code
- [ ] .env file is in .gitignore
- [ ] build.sh has execute permissions

---

## Deployment Checklist

- [ ] MongoDB Atlas cluster created
- [ ] Database user created with credentials
- [ ] Connection string obtained and tested
- [ ] Azure Resource Group created
- [ ] Azure Web App created with Node.js runtime
- [ ] Git local setup completed
- [ ] Azure remote added and code pushed
- [ ] Environment variables configured
- [ ] Application loads successfully
- [ ] API endpoints responding
- [ ] Database connectivity verified

---

## Security Best Practices

1. **Never commit .env file** - Add to .gitignore
2. **Use strong MongoDB passwords** (20+ characters)
3. **Enable IP whitelisting** if possible in MongoDB Atlas
4. **Use HTTPS only** - Azure provides free SSL
5. **Keep dependencies updated** - Run `npm audit` regularly
6. **Monitor logs** for errors and suspicious activity
7. **Use Azure Key Vault** for sensitive production data
8. **Restrict deployment credentials** - Don't share with others

---

## Performance Tips

1. Enable compression in Express
2. Use CDN for static assets
3. Implement caching strategies
4. Optimize database queries
5. Use MongoDB indexes for frequently queried fields
6. Monitor and scale based on load
7. Use Azure Application Insights for detailed monitoring

---

## Additional Resources

- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [MongoDB Atlas Documentation](https://docs.mongodb.com/atlas/)
- [Express.js Documentation](https://expressjs.com/)
- [React Documentation](https://react.dev/)
- [Node.js Best Practices](https://nodejs.org/en/docs/guides/nodejs-performance-best-practices/)

---

Happy Deploying! 🚀
