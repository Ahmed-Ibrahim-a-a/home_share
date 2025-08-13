# GroupGroceries+ 🏠💰

A comprehensive Flutter app designed for managing shared expenses and bill splitting among roommates, friends, or group members. Perfect for tracking groceries, utilities, rent, and other shared costs with ease.

## 📱 Screenshots

<table>
  <tr>
    <td align="center">
      <img src="screenshots/Simulator Screenshot - iPhone 16 - 2025-08-13 at 10.02.20.png" width="200"/>
      <br/>
      <em>Home Screen - Expenses Overview</em>
    </td>
    <td align="center">
      <img src="screenshots/Simulator Screenshot - iPhone 16 - 2025-08-13 at 10.03.03.png" width="200"/>
      <br/>
      <em>Monthly Summary View</em>
    </td>
    <td align="center">
      <img src="screenshots/Simulator Screenshot - iPhone 16 - 2025-08-13 at 10.03.06.png" width="200"/>
      <br/>
      <em>New Receipt Creation</em>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/Simulator Screenshot - iPhone 16 - 2025-08-13 at 10.03.10.png" width="200"/>
      <br/>
      <em>Adding Grocery Items</em>
    </td>
    <td align="center">
      <img src="screenshots/Simulator Screenshot - iPhone 16 - 2025-08-13 at 10.03.14.png" width="200"/>
      <br/>
      <em>Receipt Details View</em>
    </td>
    <td align="center">
      <img src="screenshots/Simulator Screenshot - iPhone 16 - 2025-08-13 at 10.03.17.png" width="200"/>
      <br/>
      <em>Bill Splitting Interface</em>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="screenshots/Simulator Screenshot - iPhone 16 - 2025-08-13 at 10.03.19.png" width="200"/>
      <br/>
      <em>Member Management</em>
    </td>
    <td align="center">
      <img src="screenshots/Simulator Screenshot - iPhone 16 - 2025-08-13 at 10.03.24.png" width="200"/>
      <br/>
      <em>Debt Tracking Overview</em>
    </td>
    <td align="center">
      <img src="screenshots/Simulator Screenshot - iPhone 16 - 2025-08-13 at 10.03.38.png" width="200"/>
      <br/>
      <em>Reports & Analytics</em>
    </td>
  </tr>
</table>

## ✨ Features

### 🧾 Expense Management

- **Receipt Tracking**: Create and manage detailed receipts for groceries, utilities, rent, and other shared expenses
- **Item-by-Item Breakdown**: Add individual grocery items with quantities, prices, and notes
- **Multiple Expense Categories**: Organize expenses by type (Groceries, Utilities, Rent, Other)
- **Monthly Overview**: View and filter expenses by month with comprehensive summaries
- **Duplicate Receipts**: Easily recreate previous receipts for recurring purchases

### 💸 Bill Splitting

- **Equal Split**: Automatically divide expenses equally among selected group members
- **Custom Split**: Set custom amounts for each person when equal splitting isn't appropriate
- **Flexible Member Selection**: Choose which members participated in each expense
- **Real-time Calculations**: Instant cost-per-person calculations with discount support

### 👥 Member & Debt Management

- **Member Profiles**: Add and manage group members with contact information
- **Debt Tracking**: Automatically track who owes money to whom
- **Payment Status**: Mark debts as paid when settled
- **Debt History**: View complete history of all financial transactions

### 📊 Reports & Analytics

- **Monthly Reports**: Comprehensive spending analysis by month
- **Category Breakdown**: Visualize spending patterns by expense type
- **Member Spending**: Track individual contribution patterns
- **Export Options**: Share reports and data with group members

### 💾 Data Management

- **Local Storage**: Secure local data storage using Hive database
- **Import/Export**: Backup and restore data via JSON and CSV formats
- **Data Sharing**: Export data to share with accountants or for record-keeping
- **Offline Support**: Full functionality without internet connection

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.2.3+
- **State Management**: GetX
- **Local Database**: Hive
- **UI/UX**: Material Design 3
- **File Operations**: CSV export/import, file picker
- **Date/Time**: Intl package for localization

## 📋 Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  get: ^4.6.6              # State management
  hive: ^2.2.3             # Local database
  hive_flutter: ^1.1.0     # Flutter integration for Hive
  uuid: ^4.3.3             # Unique ID generation
  intl: ^0.19.0            # Internationalization
  share_plus: ^11.0.0      # Sharing functionality
  csv: ^5.1.1              # CSV file handling
  file_picker: ^10.2.0     # File selection
  path_provider: ^2.1.2    # File system paths

dev_dependencies:
  build_runner: ^2.4.15    # Code generation
  hive_generator: ^2.0.1   # Hive model generation
  flutter_lints: ^2.0.0    # Linting rules
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.2.3 or higher
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/home_share.git
   cd home_share
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**

   ```bash
   flutter run
   ```

## 📱 Platform Support

- ✅ **iOS**: iPhone and iPad
- ✅ **Android**: Phones and tablets
- 🔄 **Web**: Under development
- 🔄 **Desktop**: Planned for future releases

## 🏗️ Project Structure

```
lib/
├── data/
│   └── repositories/          # Hive database implementations
├── domain/
│   ├── models/               # Data models (Receipt, Member, Debt, etc.)
│   ├── repositories/         # Repository interfaces
│   └── services/            # Business logic services
└── presentation/
    ├── controllers/         # GetX controllers for state management
    ├── pages/              # App screens/pages
    ├── widgets/            # Reusable UI components
    └── theme/              # App theming
```

## 🎯 Usage

### Creating a New Receipt

1. Tap the **+** button on the home screen
2. Select expense category (Groceries, Utilities, etc.)
3. Add items with quantities and prices
4. Choose the number of people splitting the bill
5. Select who paid for the expense
6. Save the receipt

### Splitting Bills

1. Navigate to the **Split Bill** tab
2. Enter the total amount
3. Choose between equal or custom split
4. Select participating members
5. Calculate and save the split

### Managing Debts

1. Go to the **Debts** tab
2. View outstanding balances between members
3. Mark debts as paid when settled
4. Export debt summaries for record-keeping

### Viewing Reports

1. Access the **Reports** tab
2. Filter by month or category
3. View spending patterns and trends
4. Export reports for external use

## 🔧 Configuration

### Adding Custom Categories

Modify `lib/domain/models/group_type.dart` to add new expense categories:

```dart
enum GroupType {
  groceries,
  utilities,
  rent,
  entertainment,  // Add new category
  other;
}
```

### Customizing Currency

Update the currency symbol in relevant files or add localization support for different currencies.

## 📖 API Documentation

### Key Models

- **Receipt**: Represents a purchase with items, costs, and splitting information
- **GroceryItem**: Individual items within a receipt
- **Member**: Group members who participate in shared expenses
- **Debt**: Financial obligations between members

### Repository Pattern

The app uses the repository pattern for data access, with Hive implementations for local storage.

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow the existing code style and architecture
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/home_share/issues) page
2. Create a new issue with detailed information
3. Include screenshots and device information for bug reports

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX for simple state management
- Hive for efficient local storage
- All contributors and testers

## 🔮 Roadmap

- [ ] Web platform support
- [ ] Desktop applications (Windows, macOS, Linux)
- [ ] Cloud synchronization
- [ ] Multi-currency support
- [ ] Receipt photo scanning with OCR
- [ ] Push notifications for payment reminders
- [ ] Integration with banking apps
- [ ] Advanced analytics and insights

---

**Made with ❤️ for better group expense management**
