# Setup Instructions for New Users

## Quick Start (5 Minutes)

### Step 1: Get the Latest Code
```bash
git pull origin main
```

### Step 2: Clean & Install Dependencies
```bash
flutter clean
flutter pub get
```

### Step 3: Run on Android/iOS (NOT Web!)

**For Android Emulator:**
```bash
# Start your Android emulator first, then:
flutter run
```

**For iOS Simulator (Mac only):**
```bash
open -a Simulator
flutter run
```

**For Physical Device:**
```bash
# Connect your device, then:
flutter devices  # Find your device ID
flutter run -d <device-id>
```

### Step 4: First Time Registration

⚠️ **IMPORTANT**: Password requirements are strict!

Use this test account:
- **Username**: `testuser`
- **Email**: `test@test.com`
- **Password**: `Test123!@#`
- **Confirm Password**: `Test123!@#`

**Password must have:**
- ✅ 8+ characters
- ✅ Uppercase letter (A-Z)
- ✅ Lowercase letter (a-z)
- ✅ Number (0-9)
- ✅ Special character (!@#$%^&*...)

## Common Issues

### ❌ "Registration not working"
**Cause**: Running on web browser (SQLite doesn't work on web)
**Solution**: Run on Android emulator or iOS simulator instead

### ❌ "Password validation fails"
**Cause**: Password doesn't meet strict requirements
**Solution**: Use the test password above: `Test123!@#`

### ❌ "Build errors"
**Cause**: Old dependencies cached
**Solution**: Run `flutter clean && flutter pub get` again

## What's Been Fixed

✅ Android build configuration (desugaring enabled)
✅ Package compatibility issues resolved
✅ Dashboard UI overflow fixed
✅ All changes committed to Git

## Need Help?

Check `flutter doctor -v` to verify your Flutter installation is correct.

---

**Happy coding! 🎉**
