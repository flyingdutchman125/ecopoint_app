#!/bin/bash

echo "=========================================="
echo "EcoPoint API - Project Validation"
echo "=========================================="
echo ""

errors=0
warnings=0

echo "🔍 Checking project structure..."
echo ""

required_dirs=(
  "src"
  "src/config"
  "src/controllers"
  "src/middlewares"
  "src/routes"
  "src/services"
  "database"
)

for dir in "${required_dirs[@]}"; do
  if [ -d "$dir" ]; then
    echo "✓ $dir/"
  else
    echo "✗ $dir/ - MISSING"
    ((errors++))
  fi
done

echo ""
echo "📄 Checking required files..."
echo ""

required_files=(
  "package.json"
  "src/server.js"
  "src/app.js"
  "src/config/supabase.js"
  "src/config/openai.js"
  "src/controllers/userController.js"
  "src/controllers/collectorController.js"
  "src/controllers/adminController.js"
  "src/middlewares/authMiddleware.js"
  "src/middlewares/errorHandler.js"
  "src/routes/userRoutes.js"
  "src/routes/collectorRoutes.js"
  "src/routes/adminRoutes.js"
  "src/services/aiVisionService.js"
  "src/services/scraperService.js"
  "src/services/osrmService.js"
  "src/services/walletService.js"
  "database/init.sql"
  ".env.example"
  ".gitignore"
  "README.md"
)

for file in "${required_files[@]}"; do
  if [ -f "$file" ]; then
    echo "✓ $file"
  else
    echo "✗ $file - MISSING"
    ((errors++))
  fi
done

echo ""
echo "⚙️  Checking configuration..."
echo ""

if [ -f ".env" ]; then
  echo "✓ .env file exists"
else
  echo "⚠ .env file not found (use .env.example as template)"
  ((warnings++))
fi

if [ -d "node_modules" ]; then
  echo "✓ Dependencies installed"
else
  echo "⚠ Dependencies not installed (run: npm install)"
  ((warnings++))
fi

echo ""
echo "📊 Summary"
echo "=========================================="
echo "Errors: $errors"
echo "Warnings: $warnings"
echo ""

if [ $errors -eq 0 ]; then
  echo "✅ Project structure is valid!"
  echo ""
  echo "Next steps:"
  echo "1. Configure .env file"
  echo "2. Run database/init.sql in Supabase"
  echo "3. Start server: npm run dev"
  exit 0
else
  echo "❌ Project validation failed!"
  echo "Please check missing files/directories above."
  exit 1
fi
