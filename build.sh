#!/usr/bin/env bash

# Build script for Azure App Service
echo "Installing dependencies..."

# Install server dependencies
cd server
npm install
if [ $? -ne 0 ]; then
  echo "Server npm install failed"
  exit 1
fi
cd ..

# Install client dependencies
cd client
npm install
if [ $? -ne 0 ]; then
  echo "Client npm install failed"
  exit 1
fi

# Build React app
echo "Building React app..."
npm run build
if [ $? -ne 0 ]; then
  echo "React build failed"
  exit 1
fi

cd ..

echo "Build completed successfully!"
