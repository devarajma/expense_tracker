## Debug: Database Reset Instructions

### Issue
The bookings and wishlist tables are not being created even though they exist in the code.

### Root Cause
Database singleton is likely caching the old database instance from version 1, preventing the new tables from being created.

### Solution Options

#### Option 1: Manual Uninstall (RECOMMENDED)
1. Stop the flutter run command (press `q` in terminal)
2. On your iPhone simulator: Long press the expense tracker app icon
3. Select "Delete App"  
4. Run `flutter run` again
5. This forces a completely fresh database creation

#### Option 2: Add Database Reset Function
Add this to your app to force database recreation:

```dart
// In database_helper.dart
Future<void> resetDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, AppStrings.databaseName);
  await deleteDatabase(path);
  _database = null; // Reset singleton
}
```

Then call this from a debug button in settings.

### Verification
After reinstall, check:
- [ ] Can add booking without error
- [ ] Can add wishlist item without error  
- [ ] Tables show in database

### Tables That Should Exist
- users
- income  
- expenses
- inventory
- budgets
- categories
- gst_calculations
- **bookings** ← NEW
- **wishlist** ← NEW
