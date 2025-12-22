# Database Access Guide

## Quick Access Script

Run this command to find and open your database:

```bash
./view_database.sh
```

This script will:
- 🔍 Automatically find the database in iOS Simulator
- 📊 Show database size and location
- 🚀 Open it in DB Browser for SQLite (or offer to install it)
- 📋 Copy the database path to your clipboard

## Manual Access

### Find Database Location

```bash
find ~/Library/Developer/CoreSimulator/Devices -name "expense_tracker.db" 2>/dev/null
```

### View with sqlite3 Command Line

```bash
# Replace with actual path
sqlite3 /path/to/expense_tracker.db
```

**Useful sqlite3 commands:**
```sql
.tables                           -- List all tables
.schema TABLE_NAME                -- Show table structure
SELECT * FROM users;              -- View all users
SELECT * FROM income LIMIT 10;    -- View first 10 incomes
.quit                             -- Exit
```

## Database Tables

Your app has the following tables:
- `users` - User accounts
- `income` - Income records
- `expenses` - Expense records
- `inventory` - Inventory items
- `inventory_history` - Stock action logs
- `bookings` - Customer bookings
- `wishlist` - Wishlist items
- `budget` - Budget settings

## Install DB Browser for SQLite

If not installed, run:
```bash
brew install --cask db-browser-for-sqlite
```

## Pro Tips

1. **Database resets when you uninstall the app**
2. **Each simulator has its own database** - make sure you're running on the same simulator
3. **The script copies the path to clipboard** - you can paste it into any SQL tool
4. **Database is created on first app launch** - won't exist until you run the app at least once
