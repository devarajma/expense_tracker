# How to Run the Expense Tracker App

## ⚠️ Important: Database Limitation on Web

**The app uses SQLite which does NOT work in web browsers.** You must run it on:
- ✅ Android Emulator
- ✅ iOS Simulator  
- ✅ Physical Android/iOS device

## 🚀 Quick Start - Android Emulator

### Step 1: Start Android Emulator
```bash
# Open Android Studio
# Go to: Tools → Device Manager → Create Device
# Or use command line:
~/Library/Android/sdk/emulator/emulator -list-avds
~/Library/Android/sdk/emulator/emulator -avd <device_name>
```

### Step 2: Run the App
```bash
cd /Users/devarajanma/expense_tracker
flutter run
```

The app will automatically detect the emulator and install.

## Alternative: iOS Simulator (macOS only)

```bash
open -a Simulator
flutter run
```

## 🔧 Troubleshooting

### No Android Emulator?
1. Open Android Studio
2. Go to More Actions → Virtual Device Manager
3. Create a new device (Pixel 5 recommended)
4. Start the emulator

### Check Available Devices
```bash
flutter devices
```

You should see your emulator/simulator listed.

## ✨ Once Running

1. **Sign Up**: Create account (e.g., test@test.com, password: 123456)
2. **Add Data**: Try adding income/expenses
3. **Explore**: Test all 10 modules!

---

**Web Note**: The app runs visually on web but database operations will fail. This is a Flutter/SQLite limitation, not a bug in the code.
