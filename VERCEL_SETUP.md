# Vercel Deployment Configuration

## Environment Variables Required

You need to set the following environment variable in your Vercel project:

### MONGODB_URI
Your MongoDB connection string from MongoDB Atlas.

**How to set it:**

1. Go to your Vercel project dashboard
2. Navigate to **Settings** → **Environment Variables**
3. Add a new variable:
   - **Name**: `MONGODB_URI`
   - **Value**: Your MongoDB connection string (e.g., `mongodb+srv://username:password@cluster.mongodb.net/dbname?retryWrites=true&w=majority`)
   - **Environment**: Production, Preview, Development (select all)

### Get MongoDB Connection String:

1. Go to [MongoDB Atlas](https://cloud.mongodb.com)
2. Click **Connect** on your cluster
3. Choose **Connect your application**
4. Copy the connection string
5. Replace `<password>` with your database user password
6. Replace `dbname` with your database name

### After Setting Variables:

Redeploy your application or trigger a new deployment for the changes to take effect.

## Testing the API

Once deployed, test your API health endpoint:
```
https://your-app.vercel.app/api/health
```

You should see:
```json
{
  "status": "Server is running",
  "timestamp": "2026-01-17T...",
  "database": "connected"
}
```
