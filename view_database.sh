#!/bin/bash

# Script to find and open the SQLite database for the Expense Tracker app

echo "🔍 Finding expense_tracker.db in iOS Simulator..."

# Find the database file in the simulator's app data
DB_PATH=$(find ~/Library/Developer/CoreSimulator/Devices -name "expense_tracker.db" 2>/dev/null | head -1)

if [ -z "$DB_PATH" ]; then
    echo "❌ Database not found!"
    echo ""
    echo "Possible reasons:"
    echo "1. The app hasn't been run yet (database is created on first launch)"
    echo "2. Using a different simulator"
    echo "3. Database file has a different name"
    echo ""
    echo "💡 Try running the app first with: flutter run"
    exit 1
fi

echo "✅ Database found at:"
echo "$DB_PATH"
echo ""

# Get database info
DB_SIZE=$(du -h "$DB_PATH" | cut -f1)
echo "📊 Database size: $DB_SIZE"
echo ""

# Check if DB Browser for SQLite is installed
if command -v sqlitebrowser &> /dev/null; then
    echo "🚀 Opening in DB Browser for SQLite..."
    sqlitebrowser "$DB_PATH" &
    echo "✅ Database opened!"
elif [ -d "/Applications/DB Browser for SQLite.app" ]; then
    echo "🚀 Opening in DB Browser for SQLite..."
    open -a "DB Browser for SQLite" "$DB_PATH"
    echo "✅ Database opened!"
else
    echo "⚠️  DB Browser for SQLite not found!"
    echo ""
    echo "Choose an option:"
    echo "1. Install DB Browser: brew install --cask db-browser-for-sqlite"
    echo "2. Open with sqlite3 command line"
    echo ""
    read -p "Enter choice (1/2): " choice
    
    if [ "$choice" = "1" ]; then
        echo "📦 Installing DB Browser for SQLite..."
        brew install --cask db-browser-for-sqlite
        if [ $? -eq 0 ]; then
            echo "✅ Installation complete! Opening database..."
            open -a "DB Browser for SQLite" "$DB_PATH"
        fi
    elif [ "$choice" = "2" ]; then
        echo "🔧 Opening with sqlite3..."
        echo ""
        echo "Available commands:"
        echo "  .tables          - List all tables"
        echo "  .schema TABLE    - Show table structure"
        echo "  SELECT * FROM TABLE; - View data"
        echo "  .quit            - Exit"
        echo ""
        sqlite3 "$DB_PATH"
    fi
fi

echo ""
echo "📁 Full path copied to clipboard (you can paste it anywhere):"
echo "$DB_PATH" | pbcopy
echo "$DB_PATH"
