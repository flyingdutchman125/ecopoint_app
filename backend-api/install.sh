#!/bin/bash

echo "=========================================="
echo "EcoPoint API - Complete Installation"
echo "=========================================="
echo ""
echo "This will set up your EcoPoint API from scratch."
echo ""

read -p "Continue with installation? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo ""
echo "Step 1: Checking prerequisites..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 18+ first."
    echo "Visit: https://nodejs.org/"
    exit 1
fi
echo "✓ Node.js $(node --version)"

echo ""
echo "Step 2: Creating environment file..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✓ .env created from template"
    echo ""
    echo "⚠️  IMPORTANT: Edit .env file now with your credentials:"
    echo "   nano .env"
    echo ""
    read -p "Press Enter after configuring .env..."
else
    echo "✓ .env already exists"
fi

echo ""
echo "Step 3: Installing dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "❌ Installation failed"
    exit 1
fi
echo "✓ Dependencies installed"

echo ""
echo "Step 4: Validating project structure..."
./validate.sh
if [ $? -ne 0 ]; then
    echo "❌ Validation failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ Installation Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Setup Database:"
echo "   - Go to Supabase Dashboard → SQL Editor"
echo "   - Copy & run: database/init.sql"
echo ""
echo "2. Start Development Server:"
echo "   npm run dev"
echo ""
echo "3. Test the API:"
echo "   curl http://localhost:3000/health"
echo ""
echo "4. Read Documentation:"
echo "   - README.md (API reference)"
echo "   - QUICKSTART.md (setup guide)"
echo "   - DEPLOYMENT.md (production guide)"
echo ""
echo "Happy coding! 🚀"
echo ""
