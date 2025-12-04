# Smart Profit & Expense Analyzer

A comprehensive Flutter mobile application for small business owners to manage income, expenses, inventory, budgets, and generate financial reports with GST calculations.

## 🌟 Features

### 📊 Financial Management
- **Income Tracking**: Add, edit, and categorize income entries with date selection
- **Expense Management**: Track expenses with categories and optional bill attachments
- **Profit Analysis**: View daily and monthly profit with 6-month trend charts
- **Daily Dashboard**: Real-time summary of today's income, expenses, and profit

### 💰 Business Tools
- **GST Calculator**: Calculate CGST/SGST automatically with common rate presets
- **Inventory Management**: Track stock levels with low-stock alerts
- **Budget Tracking**: Set monthly budgets with visual progress bars and overspending alerts
- **Category Management**: Custom income and expense categories

### 📄 Reports & Analytics
- **PDF Reports**: Generate professional income, expense, and profit/loss reports
- **Charts & Visualizations**: Line charts showing financial trends using fl_chart
- **Date Range Filtering**: Filter transactions and reports by custom date ranges

### 🔐 User Management
- **Local Authentication**: Secure login and registration with password hashing
- **Profile Management**: Update user information
- **Password Change**: Secure password update functionality

## 🛠️ Tech Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Riverpod 2.4+
- **Local Database**: sqflite
- **Charts**: fl_chart
- **PDF Generation**: pdf & printing packages
- **UI Design**: Material Design 3

## 📁 Project Structure

```
lib/
├── database/
│   └── database_helper.dart         # SQLite database initialization
├── models/
│   ├── user_model.dart              # User data model
│   ├── income_model.dart            # Income entry model
│   ├── expense_model.dart           # Expense entry model
│   ├── inventory_model.dart         # Inventory item model
│   ├── budget_model.dart            # Budget model
│   ├── category_model.dart          # Category model
│   └── gst_calculation_model.dart   # GST calculation model
├── services/
│   ├── auth_service.dart            # Authentication logic
│   ├── income_service.dart          # Income CRUD operations
│   ├── expense_service.dart         # Expense CRUD operations
│   ├── inventory_service.dart       # Inventory management
│   ├── budget_service.dart          # Budget tracking
│   ├── gst_service.dart             # GST calculations
│   ├── category_service.dart        # Category management
│   ├── pdf_service.dart             # PDF report generation
│   └── notification_service.dart    # Local notifications
├── providers/
│   ├── auth_provider.dart           # Auth state management
│   ├── income_provider.dart         # Income state
│   ├── expense_provider.dart        # Expense state
│   ├── category_provider.dart       # Category state
│   └── summary_provider.dart        # Dashboard calculations
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart       # App splash screen
│   │   ├── login_screen.dart        # Login UI
│   │   └── signup_screen.dart       # Registration UI
│   ├── home/
│   │   ├── home_screen.dart         # Bottom navigation
│   │   └── dashboard_screen.dart    # Main dashboard
│   ├── income/
│   │   └── income_screen.dart       # Income management
│   ├── expense/
│   │   └── expense_screen.dart      # Expense management
│   ├── profit/
│   │   └── profit_screen.dart       # Profit charts
│   ├── gst/
│   │   └── gst_calculator_screen.dart # GST calculator
│   ├── inventory/
│   │   └── inventory_screen.dart    # Inventory tracking
│   ├── budget/
│   │   └── budget_screen.dart       # Budget management
│   ├── reports/
│   │   └── reports_screen.dart      # PDF report generation
│   └── settings/
│       ├── settings_screen.dart     # App settings
│       └── category_management_screen.dart # Category editor
├── widgets/
│   ├── custom_button.dart           # Reusable button
│   ├── custom_text_field.dart       # Styled text input
│   ├── summary_card.dart            # Dashboard metric cards
│   └── transaction_list_item.dart   # Transaction list tile
├── utils/
│   ├── constants.dart               # App constants & colors
│   └── helpers.dart                 # Utility functions
└── main.dart                        # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Android Emulator or iOS Simulator

### Installation

1. **Clone or navigate to the project directory**:
   ```bash
   cd /Users/devarajanma/expense_tracker
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For Web (if needed)
   flutter run -d chrome
   ```

### First Time Setup

1. Launch the app
2. Click "Sign Up" on the login screen
3. Create an account with:
   - Username
   - Email
   - Password (minimum 6 characters)
4. Default income and expense categories will be created automatically
5. Start adding your transactions!

## 📱 Usage Guide

### Adding Income/Expenses
1. Navigate to Dashboard
2. Tap "Add Income" or "Add Expense" quick action
3. Select category, enter amount, add notes
4. Choose the date and save

### Viewing Profit Analysis
1. Tap "Profit" on the dashboard
2. View monthly summary and 6-month trend chart
3. See breakdown of income vs expenses

### Using GST Calculator
1. Navigate to GST Calculator from dashboard
2. Enter base amount and GST percentage
3. View CGST/SGST breakdown
4. Save calculation for records

### Managing Inventory
1. Go to Inventory from dashboard
2. Add items with name, quantity, and low-stock threshold
3. Update quantities as needed
4. Receive alerts for low stock items

### Setting Budgets
1. Open Budget Management
2. Enter monthly budget amount
3. View spending progress and alerts

### Generating Reports
1. Go to Reports tab
2. Select report type (Income/Expense/Profit)
3. Choose date range
4. Generate PDF report
5. Print or share the PDF

### Managing Categories
1. Go to Settings → Manage Categories
2. Switch between Income/Expense tabs
3. Add custom categories as needed

## 🎨 Default Categories

### Income Categories
- Sales
- Services
- Investment
- Other Income

### Expense Categories
- Rent
- Utilities
- Salaries
- Raw Materials
- Marketing
- Transportation
- Maintenance
- Other Expenses

## 🔄 State Management

The app uses **Riverpod** for state management with the following providers:
- `authNotifierProvider`: User authentication state
- `incomeNotifierProvider`: Income list and operations
- `expenseNotifierProvider`: Expense list and operations
- `dailySummaryProvider`: Real-time daily calculations
- `monthlyProfitDataProvider`: Chart data for trends

## 💾 Database Schema

The app uses SQLite with the following tables:
- `users`: User accounts
- `income`: Income transactions
- `expenses`: Expense transactions
- `inventory`: Stock items
- `budgets`: Monthly budgets
- `categories`: Custom categories
- `gst_calculations`: Saved GST calculations

## 🔐 Security

- Passwords are hashed using SHA-256
- Local-only authentication (no internet required)
- Data stored securely in device's local database

## 🐛 Troubleshooting

### App crashes on startup
- Run `flutter clean` then `flutter pub get`
- Restart your emulator/device

### Database errors
- Uninstall and reinstall the app (development only)
- This will reset the database

### Charts not displaying
- Ensure you have transaction data in the selected period
- Try selecting a different date range

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  fl_chart: ^0.65.0
  pdf: ^3.10.7
  printing: ^5.11.1
  intl: ^0.18.1
  crypto: ^3.0.3
  file_picker: ^6.1.1
  image_picker: ^1.0.5
  flutter_local_notifications: ^16.3.0
```

## 📄 License

This project is created for educational and business use.

## 🤝 Contributing

This is a standalone business application. For modifications or custom features, update the codebase as needed.

## 📧 Support

For issues or questions about the application, refer to the code documentation or Flutter documentation at https://flutter.dev

---

**Version**: 1.0.0  
**Last Updated**: December 2025  
**Built with**: Flutter & ❤️
