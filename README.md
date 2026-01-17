# MERN Stack Application Deployment to Azure

Complete MERN (MongoDB, Express, React, Node.js) stack application with Azure deployment support.

## 📁 Project Structure

```
deploy-MERN/
├── server/                          # Express.js Backend
│   ├── models/                      # Mongoose schemas
│   │   └── Item.js
│   ├── controllers/                 # Route controllers
│   │   └── itemController.js
│   ├── routes/                      # API routes
│   │   └── items.js
│   ├── server.js                    # Main server file
│   ├── package.json
│   └── .env.example                 # Environment template
│
├── client/                          # React Frontend
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/              # React components
│   │   │   ├── ItemForm.js
│   │   │   ├── ItemForm.css
│   │   │   ├── ItemList.js
│   │   │   └── ItemList.css
│   │   ├── App.js                   # Main app component
│   │   ├── App.css
│   │   ├── index.js
│   │   └── index.css
│   └── package.json
│
├── package.json                     # Root package.json
├── build.sh                         # Azure build script
├── quickstart.sh                    # Local development setup
├── .gitignore
├── AZURE_DEPLOYMENT_GUIDE.md        # Detailed deployment guide
└── README.md                        # This file
```

## 🚀 Quick Start (Local Development)

### 1. Prerequisites
- Node.js 16+ installed
- MongoDB Atlas account (free tier available)
- Git installed

### 2. Setup

```bash
# Make quickstart script executable
chmod +x quickstart.sh

# Run quick start
./quickstart.sh
```

### 3. Configure MongoDB

```bash
# Copy environment template
cp server/.env.example server/.env

# Edit server/.env with your MongoDB Atlas connection string
# Example: mongodb+srv://username:password@cluster.mongodb.net/dbname
```

### 4. Start Development

```bash
npm run dev
```

This starts:
- Frontend: http://localhost:3000 (React)
- Backend: http://localhost:5000 (Express)

## 🌐 Azure Deployment

### Quick Overview
1. Create MongoDB Atlas cluster
2. Create Azure Web App
3. Push code to Azure
4. Configure environment variables
5. Test the live application

### Detailed Steps
See [AZURE_DEPLOYMENT_GUIDE.md](./AZURE_DEPLOYMENT_GUIDE.md) for complete step-by-step instructions.

### Deploy with Azure CLI

```bash
# Create resource group
az group create --name mern-app-rg --location eastus

# Create app service plan
az appservice plan create \
  --name mern-app-plan \
  --resource-group mern-app-rg \
  --sku B1 \
  --is-linux

# Create web app
az webapp create \
  --resource-group mern-app-rg \
  --plan mern-app-plan \
  --name mern-app-yourname \
  --runtime "NODE|18-lts" \
  --deployment-local-git

# Build the app
npm run build

# Configure and push to Azure
git add .
git commit -m "Initial commit"
git remote add azure <your-azure-git-url>
git push azure master
```

## 📦 Available Scripts

### Root Level
```bash
npm run install-all      # Install all dependencies
npm run build            # Build React app
npm run dev              # Start both server and client
npm start                # Start production server
```

### Server Level (cd server/)
```bash
npm start                # Start Express server
npm run dev              # Start with nodemon (auto-reload)
```

### Client Level (cd client/)
```bash
npm start                # Start React dev server
npm run build            # Create production build
npm test                 # Run tests
```

## 🗄️ API Endpoints

### Base URL (Production)
```
https://mern-app-yourname.azurewebsites.net/api
```

### Local Development
```
http://localhost:5000/api
```

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/items` | Get all items |
| GET | `/items/:id` | Get single item |
| POST | `/items` | Create new item |
| PUT | `/items/:id` | Update item |
| DELETE | `/items/:id` | Delete item |

### Example Requests

```bash
# Health check
curl http://localhost:5000/api/health

# Get all items
curl http://localhost:5000/api/items

# Create item
curl -X POST http://localhost:5000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"My Item","description":"Description"}'

# Update item
curl -X PUT http://localhost:5000/api/items/63f7a1b2c3d4e5f6g7h8i9j0 \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Item","completed":true}'

# Delete item
curl -X DELETE http://localhost:5000/api/items/63f7a1b2c3d4e5f6g7h8i9j0
```

## 🔧 Configuration

### Environment Variables

Create `server/.env` with these variables:

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# MongoDB Connection
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/dbname?retryWrites=true&w=majority
```

### For Azure Production

Set these in Azure Web App > Configuration > Application Settings:

```
MONGODB_URI: <your-connection-string>
NODE_ENV: production
PORT: 8080
```

## 📊 Database Schema

### Item Model
```javascript
{
  _id: ObjectId,
  name: String (required),
  description: String,
  completed: Boolean,
  createdAt: Date
}
```

## 🔐 Security Checklist

- [ ] Never commit `.env` file
- [ ] Use strong MongoDB passwords
- [ ] Enable CORS only for trusted domains
- [ ] Use HTTPS in production
- [ ] Validate all user inputs
- [ ] Keep dependencies updated
- [ ] Use environment variables for sensitive data
- [ ] Enable MongoDB IP whitelist

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Kill process on port 5000 (macOS/Linux)
lsof -ti:5000 | xargs kill -9

# Kill process on port 5000 (Windows)
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

### MongoDB Connection Error
1. Verify connection string is correct
2. Check IP is whitelisted in MongoDB Atlas
3. Verify username and password
4. Ensure database exists

### React App Not Loading
1. Check that `npm run build` completed successfully
2. Verify `client/build` folder exists
3. Check browser console for errors
4. Ensure backend is running

### Azure Deployment Issues
See [AZURE_DEPLOYMENT_GUIDE.md](./AZURE_DEPLOYMENT_GUIDE.md) troubleshooting section

## 📚 Learning Resources

- [MongoDB Atlas Documentation](https://docs.mongodb.com/atlas/)
- [Express.js Guide](https://expressjs.com/)
- [React Documentation](https://react.dev/)
- [Node.js Best Practices](https://nodejs.org/en/docs/guides/)
- [Azure App Service Docs](https://docs.microsoft.com/azure/app-service/)
- [MERN Stack Tutorial](https://www.mongodb.com/languages/javascript/mongodb-and-node-tutorial)

## 📄 License

ISC

## 🤝 Support

For issues and questions:
1. Check the [AZURE_DEPLOYMENT_GUIDE.md](./AZURE_DEPLOYMENT_GUIDE.md)
2. Review application logs
3. Check MongoDB Atlas dashboard
4. Review Azure Portal for app service status

---

**Happy Coding! 🎉**
