#!/bin/bash

# Library Database Setup Script
# This script creates the database, runs the schema, and loads sample data

echo "🗄️  Setting up Library Database..."

# Database configuration
DB_NAME="ben_library_app"
DB_USER="postgres"

# Check if PostgreSQL is running
if ! pg_isready -q; then
    echo "❌ PostgreSQL is not running!"
    echo "   Start it with: brew services start postgresql@14"
    exit 1
fi

echo "✅ PostgreSQL is running"

# Drop existing database if it exists (WARNING: This deletes all data!)
echo "🗑️  Dropping existing database (if exists)..."
dropdb --if-exists -U $DB_USER $DB_NAME 2>/dev/null

# Create database
echo "📦 Creating database..."
createdb -U $DB_USER $DB_NAME

if [ $? -eq 0 ]; then
    echo "✅ Database created successfully"
else
    echo "❌ Failed to create database"
    exit 1
fi

# Run schema
echo "📋 Creating tables..."
psql -U $DB_USER -d $DB_NAME -f schema.sql -q

if [ $? -eq 0 ]; then
    echo "✅ Tables created successfully"
else
    echo "❌ Failed to create tables"
    exit 1
fi

# Load sample data
echo "📊 Loading sample data..."
psql -U $DB_USER -d $DB_NAME -f seed_data.sql -q

if [ $? -eq 0 ]; then
    echo "✅ Sample data loaded successfully"
else
    echo "❌ Failed to load sample data"
    exit 1
fi

# Show summary
echo ""
echo "🎉 Database setup complete!"
echo ""
echo "📊 Database Summary:"
psql -U $DB_USER -d $DB_NAME -c "
SELECT 
    (SELECT COUNT(*) FROM members) as members,
    (SELECT COUNT(*) FROM books) as books,
    (SELECT COUNT(*) FROM book_copies) as copies,
    (SELECT COUNT(*) FROM loans) as active_loans,
    (SELECT COUNT(*) FROM borrow_history) as past_loans;
"

echo ""
echo "🚀 Start your app with: npm run dev"
echo "🌐 Then visit: http://localhost:3000"
