# SalesQuote ArNexa — Flutter Mobile App

A modern, premium Flutter mobile application converted from the ASP.NET `SalesQuoteArNexa_Prg` web application. Built for **Arena** and **Nexa** (Maruti Suzuki) dealership sales consultants.

---

## 📱 App Overview

### Original .NET Application
The source was an ASP.NET WebForms application (`SalesQuoteArNexa_Prg`) with:
- `SignIn.aspx` — Authentication
- `Default.aspx` — Dashboard  
- `Customer_Quote.aspx` — Quote creation
- `ArenaChk_Print.aspx` / `NexaChk_Print.aspx` — PDF print pages
- `App_Code/DB.cs` — Database layer (SQL Server)
- `App_Code/WhatsApp.cs` — WhatsApp integration
- iTextSharp / IronPdf — PDF generation
- Bootstrap 4 + jQuery — UI framework

### Flutter Conversion
Full feature-parity conversion with significant UI/UX enhancements:

| Feature | .NET | Flutter |
|---------|------|---------|
| Authentication | Basic login form | Animated dual-showroom login |
| Dashboard | Static grid | Live KPIs + animated charts |
| Quote creation | Single-page form | 3-step guided wizard |
| PDF generation | Server-side iTextSharp | Client-side `pdf` package |
| WhatsApp sharing | Server WhatsApp API | `share_plus` + deep link |
| UI Framework | Bootstrap 4 | Material 3 + Custom Design System |
| Offline support | None | SQLite via `sqflite` |
| Navigation | Multi-page ASP.NET | Bottom nav shell |

---

## 🎨 Design System

### Arena Theme (Blue)
- Primary: `#2563EB` (Bright Blue)
- Background: `#0A1628` (Deep Navy)
- Accent: `#E8B84B` (Gold)

### Nexa Theme (Dark + Red)  
- Primary: `#E63946` (Nexa Red)
- Background: `#1A1A2E` (Charcoal)
- Accent: `#FF6B6B` (Coral)

The app **dynamically switches themes** based on showroom selection at login.

---

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart           # Colors, typography, Material theme
├── models/
│   └── models.dart              # Data models + sample data
└── screens/
    ├── login_screen.dart        # Animated dual-showroom login
    ├── main_shell.dart          # Bottom navigation shell
    ├── dashboard_screen.dart    # KPI cards, charts, recent quotes
    ├── quotes_screen.dart       # Tabbed quote list with search
    ├── quote_detail_screen.dart # Full quote detail + actions
    ├── new_quote_screen.dart    # 3-step quote creation wizard
    ├── customers_screen.dart    # Customer directory
    └── profile_screen.dart      # User profile + settings
```

---

## 📦 Dependencies

```yaml
# UI & Animation
google_fonts: ^6.1.0        # Montserrat + Poppins
flutter_animate: ^4.3.0     # Page animations
fl_chart: ^0.66.2           # Revenue bar charts
shimmer: ^3.0.0             # Loading states
percent_indicator: ^4.2.3   # Progress indicators

# Functionality  
intl: ^0.19.0               # Currency formatting (₹)
pdf: ^3.10.8                # Client-side PDF generation
printing: ^5.11.1           # Print + share PDF
share_plus: ^7.2.2          # WhatsApp/share integration
url_launcher: ^6.2.4        # Deep links
sqflite: ^2.3.2             # Local SQLite database
image_picker: ^1.0.7        # Vehicle image upload
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`
- Android Studio / VS Code
- Connected device or emulator

### Installation

```bash
# Clone / extract project
cd sales_quote_flutter

# Get dependencies
flutter pub get

# Run on device
flutter run

# Build release APK
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## 🔌 Backend Integration

The app is architected for easy REST API integration. Replace `SampleData` calls in `models.dart` with HTTP calls:

```dart
// Example: Fetch quotes from your .NET API
class ApiService {
  static const baseUrl = 'https://your-api.premotors.com';
  
  static Future<List<SalesQuote>> getQuotes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/quotes'));
    // Parse and return
  }
  
  static Future<SalesQuote> createQuote(SalesQuote quote) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/quotes'),
      body: jsonEncode(quote.toMap()),
    );
    // Return created quote
  }
}
```

### Database Schema (matches existing .NET DB)
The models map to the existing SQL Server schema from `DB.cs`:
- `Customer` → `tbl_Customer`
- `VehicleModel` → `tbl_Vehicle`
- `SalesQuote` → `tbl_Quote` / `tbl_QuoteItems`

---

## 📋 Screen-by-Screen Feature Map

### Login Screen (`login_screen.dart`)
- Animated gradient background
- Toggle between Arena / Nexa showroom
- Smooth form animations
- Forgot password flow

### Dashboard (`dashboard_screen.dart`)
- Greeting with date + today's enquiries
- 4 KPI cards: Quotes, Converted, Pending, Revenue
- Monthly target progress bar
- 6-month revenue bar chart (fl_chart)
- Recent quotes list

### Quotes List (`quotes_screen.dart`)
- Search bar (customer name, quote number, vehicle)
- 5-tab filter: All / Pending / Approved / Converted / Draft
- Quote cards with on-road price, status badge
- PDF, WhatsApp, share quick actions

### Quote Detail (`quote_detail_screen.dart`)
- Full customer details
- Vehicle specification
- Itemized price breakdown with deductions highlighted
- Total on-road price with savings callout
- PDF generation, WhatsApp share, print

### New Quote Wizard (`new_quote_screen.dart`)
- **Step 1**: Customer info (name, mobile, email, city, state, PAN)
- **Step 2**: Vehicle selection with spec cards
- **Step 3**: Pricing (RTO, insurance, FASTag, accessories, discounts)
- Live total on-road price calculation
- Animated step indicator

### Customers (`customers_screen.dart`)
- Search by name or mobile
- Quick actions: WhatsApp, View Quotes
- Add new customer FAB

### Profile (`profile_screen.dart`)
- Performance stats (quotes, conversion rate)
- Account settings
- Showroom details
- Sign out with navigation to login

---

## 🖨️ PDF Quote Generation

The app generates professional PDF quotations using the `pdf` package:

```dart
// Quote PDF structure matches the original ArenaChk_Print.aspx / NexaChk_Print.aspx
// - Company header with Arena/Nexa branding
// - Customer details block
// - Vehicle specifications table
// - Price breakdown table
// - Total on-road price (highlighted)
// - Terms & conditions footer
// - QR code for digital verification
```

---

## 📲 WhatsApp Integration

```dart
// Send quote via WhatsApp (replaces WhatsApp.cs)
final message = Uri.encodeComponent(
  "Dear ${quote.customer.name},\n\n"
  "Your ${quote.vehicle.name} quote is ready!\n"
  "Quote No: ${quote.quoteNumber}\n"
  "On-Road Price: ₹${totalOnRoad}\n\n"
  "PDF attached. Contact: 1800-xxx-xxxx"
);
await launchUrl(Uri.parse("https://wa.me/91${quote.customer.mobile}?text=$message"));
```

---

## 🔄 Migration Notes

| ASP.NET Component | Flutter Equivalent |
|------------------|--------------------|
| `DB.cs` SqlConnection | `sqflite` + REST API |
| `MessageBox.cs` | `showDialog()` |
| `WhatsApp.cs` | `url_launcher` WhatsApp deep link |
| iTextSharp PDF | `pdf` + `printing` packages |
| Bootstrap Grid | Flutter Row/Column/GridView |
| jQuery AJAX | `http` package |
| Session variables | Provider / Riverpod state |
| Master page | Shell widget pattern |

---

## 📞 Support

For integration with the existing Prem Motors SQL Server backend:
1. Set up a REST API wrapper over the existing `DB.cs` queries
2. Replace `SampleData.*` with `ApiService.*` calls
3. Configure authentication tokens (replace session-based auth)

---

*Built for Prem Motors Group — Arena & Nexa Dealerships*
