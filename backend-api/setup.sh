#!/bin/bash

echo "=========================================="
echo "EcoPoint API - Setup Script"
echo "=========================================="
echo ""

if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

echo "✓ Node.js found: $(node --version)"
echo ""

if [ ! -f .env ]; then
    echo "📋 Creating .env file from .env.example..."
    cp .env.example .env
    echo "✓ .env file created"
    echo "⚠️  Please edit .env and add your credentials:"
    echo "   - SUPABASE_URL"
    echo "   - SUPABASE_SERVICE_ROLE_KEY"
    echo "   - OPENAI_API_KEY"
    echo ""
else
    echo "✓ .env file already exists"
    echo ""
fi

echo "📦 Installing dependencies..."
npm install

if [ $? -eq 0 ]; then
    echo "✓ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Edit .env file with your credentials"
echo "2. Run database/init.sql in your Supabase SQL editor"
echo "3. Start the server:"
echo "   npm run dev    (development mode)"
echo "   npm start      (production mode)"
echo ""
echo "Health check: http://localhost:3000/health"
echo ""
