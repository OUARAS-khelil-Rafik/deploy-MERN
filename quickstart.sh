#!/usr/bin/env bash

# Quick Start Script for Local Development

echo "🚀 MERN Stack - Quick Start"
echo "============================"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install it first."
    exit 1
fi

echo "✓ Node.js version: $(node --version)"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Root npm install failed"
    exit 1
fi

# Install server dependencies
echo "📦 Installing server dependencies..."
cd server
npm install

if [ $? -ne 0 ]; then
    echo "❌ Server npm install failed"
    exit 1
fi

cd ..

# Install client dependencies
echo "📦 Installing client dependencies..."
cd client
npm install

if [ $? -ne 0 ]; then
    echo "❌ Client npm install failed"
    exit 1
fi

cd ..

echo ""
echo "✅ Installation complete!"
echo ""
echo "📝 Next steps:"
echo "1. Copy server/.env.example to server/.env"
echo "2. Add your MongoDB Atlas connection string to server/.env"
echo "3. Run: npm run dev"
echo ""
echo "The app will be available at:"
echo "  - Frontend: http://localhost:3000"
echo "  - Backend: http://localhost:5000"
echo ""
