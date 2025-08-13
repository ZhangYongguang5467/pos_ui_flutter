# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based Point of Sale (POS) self-checkout application designed for retail environments. The app provides a complete self-service shopping experience including item scanning, payment processing, and receipt printing.

## Development Commands

### Basic Flutter Commands
- **Build for development**: `flutter run`
- **Hot reload**: `r` (in the Flutter development console)
- **Hot restart**: `R` (in the Flutter development console)
- **Build APK**: `flutter build apk`
- **Build for iOS**: `flutter build ios`
- **Analyze code**: `flutter analyze`
- **Run tests**: `flutter test`

### Platform-Specific Development
- **Run on macOS**: `flutter run -d macos`
- **Run on Web**: `flutter run -d chrome`
- **Run on Windows**: `flutter run -d windows`
- **List available devices**: `flutter devices`

### Package Management
- **Install dependencies**: `flutter pub get`
- **Upgrade dependencies**: `flutter pub upgrade`
- **Check for outdated packages**: `flutter pub outdated`

## Architecture

### Core Structure
- **`lib/main.dart`**: Application entry point that initializes the POSApp
- **`lib/pages/`**: UI screens for the self-checkout flow
- **`lib/services/`**: Business logic and external service integrations

### Page Flow
The application follows a sequential self-checkout process:
1. **SelfCheckoutPage**: Main entry/welcome screen
2. **CardScanPage**: Membership card scanning
3. **ShoppingPage**: Item scanning and cart management
4. **BagSelectionPage**: Customer selects bags
5. **PaymentMethodPage**: Payment type selection
6. **PinInputPage**: PIN entry for card payments
7. **PrepaidPaymentPage**: Prepaid card payment handling
8. **PaymentCompletionPage**: Transaction completion
9. **NoBarCodeProductsPage**: Manual item entry for non-barcoded items

### Service Layer
- **ApiService**: Handles all REST API communication with the POS backend
  - Cart management (create, add items, calculate subtotal)
  - Payment processing
  - Configuration loading from `config.json`
  - All endpoints use terminal_id parameter and X-API-Key authentication
- **PrinterService**: Manages Epson ePOS printer integration
  - SOAP XML-based communication
  - Receipt printing with text and barcodes

## Configuration

### Environment Setup
The app uses a `config.json` file for configuration:
- Copy `config.example.json` to `config.json`
- Update API endpoints, keys, and printer settings
- The file is loaded from local filesystem first, then falls back to Flutter assets
- Configuration includes:
  - API base URL, API key, and terminal ID
  - Printer service URL, device ID, and timeout settings

### Platform Configuration
- **Windows deployment**: Use `deploy_windows.bat` script
- **Config reset**: Use `reset_config_windows.bat` on Windows

## Key Dependencies
- **flutter**: Framework (SDK ^3.8.1)
- **http**: REST API communication (^1.1.0)
- **cupertino_icons**: iOS-style icons (^1.0.8)
- **flutter_lints**: Code analysis and linting (^5.0.0)

## Development Notes

### State Management
The app uses Flutter's built-in StatefulWidget for state management. Each page manages its own state and communicates with services directly.

### API Integration
All API calls go through ApiService which:
- Automatically loads configuration
- Handles authentication headers
- Provides detailed logging for debugging
- Implements proper error handling and timeouts
- Masks sensitive information (API keys) in logs

### Printer Integration
The app supports Epson ePOS printers via SOAP XML requests. The PrinterService:
- Builds SOAP envelopes with text and barcode content
- Handles XML escaping for special characters
- Supports configurable feed and cut operations

### Localization
The app appears to support Japanese text (セルフレジ = Self Register) and includes Japanese language settings in printer operations.

### Testing
- Standard Flutter test structure in `test/` directory
- Use `flutter test` to run unit and widget tests
- Main test file: `test/widget_test.dart`