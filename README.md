# 📱 AshishDemo - Holdings iOS Application

A production-ready iOS application built with **UIKit**, **Clean Architecture**, and **MVVM** pattern for displaying financial holdings data with offline support.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Testing](#testing)
- [Technologies](#technologies)
- [Screenshots](#screenshots)
- [Contributing](#contributing)

## ✨ Features

- 📊 **Holdings Display**: View your financial holdings with detailed information
- 💰 **P&L Calculation**: Real-time profit and loss calculations
- 🔄 **Offline Support**: Core Data integration for offline data access
- 🎨 **Modern UI**: Clean, intuitive interface with collapsible summary view
- 🔄 **Pull to Refresh**: Refresh holdings data with pull-to-refresh gesture
- ⚡ **Performance**: Optimized with DiffableDataSource and pre-calculated values
- 🌐 **Network Layer**: Robust error handling and retry mechanisms
- 🎯 **State Management**: Comprehensive loading, error, and empty states

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────┐
│     Presentation Layer              │
│  (ViewControllers, ViewModels, Views)│
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        Domain Layer                  │
│  (Entities, UseCases, Protocols)     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Data Layer                   │
│  (Network, Persistence, Mappers)    │
└─────────────────────────────────────┘
```

### Key Principles

- **Separation of Concerns**: Each layer has a single, well-defined responsibility
- **Dependency Inversion**: Dependencies point inward toward the domain layer
- **Protocol-Oriented**: Extensive use of protocols for abstraction and testability
- **MVVM Pattern**: ViewModels manage UI state and business logic
- **Dependency Injection**: Centralized DI container for managing dependencies

## 📱 Requirements

- **iOS**: 15.0+
- **Xcode**: 14.0+
- **Swift**: 5.10+
- **Device**: iPhone (optimized for iPhone)

## 🚀 Installation

### Prerequisites

1. Install [Xcode](https://developer.apple.com/xcode/) from the App Store
2. Ensure you have an active Apple Developer account (for running on device)

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Ashish_Demo/AshishDemo
   ```

2. **Open the project**
   ```bash
   open AshishDemo.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` or click the Run button
   - The app will build and launch automatically

### Configuration

The app is configured to fetch data from:
```
https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/
```

No additional configuration is required for basic usage.

## 📁 Project Structure

```
AshishDemo/
├── AshishDemo/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   │
│   ├── Common/
│   │   ├── Constants/
│   │   │   └── AppConstants.swift      # App-wide constants
│   │   ├── Theme/
│   │   │   ├── AppColors.swift         # Color definitions
│   │   │   └── AppFonts.swift          # Font definitions
│   │   ├── Protocols/
│   │   │   └── CurrencyFormatterProtocol.swift
│   │   └── Utilities/
│   │       └── CurrencyFormatter.swift # Currency formatting
│   │
│   ├── Domain/
│   │   ├── Entities/
│   │   │   └── Holding.swift         # Domain model
│   │   ├── Repositories/
│   │   │   └── HoldingsRepository.swift # Repository protocol
│   │   └── UseCases/
│   │       └── FetchHoldingsUseCase.swift # Business logic
│   │
│   ├── Data/
│   │   ├── Models/
│   │   │   └── HoldingsDTO.swift       # Data Transfer Objects
│   │   ├── Network/
│   │   │   ├── NetworkClient.swift     # Network abstraction
│   │   │   ├── NetworkError.swift      # Network error types
│   │   │   └── HoldingsAPI.swift       # API service
│   │   ├── Persistence/
│   │   │   ├── CoreDataManager.swift   # Core Data manager
│   │   │   └── HoldingsCoreDataService.swift # Core Data service
│   │   ├── Mappers/
│   │   │   └── HoldingsMapper.swift    # DTO to Domain mapping
│   │   └── HoldingsRepositoryImpl.swift # Repository implementation
│   │
│   ├── Presentation/
│   │   ├── HoldingsViewController.swift # Main view controller
│   │   ├── HoldingTableViewCell.swift   # Table view cell
│   │   ├── ViewModels/
│   │   │   └── HoldingsViewModel.swift  # View model
│   │   └── Views/
│   │       ├── CollapsibleSummaryView.swift # Collapsible footer
│   │       ├── EmptyStateView.swift    # Empty state view
│   │       ├── ErrorStateView.swift    # Error state view
│   │       └── HoldingsSummaryView.swift
│   │
│   ├── DI/
│   │   └── DependencyContainer.swift   # Dependency injection
│   │
│   └── AshishDemo.xcdatamodeld/        # Core Data model
│
├── AshishDemoTests/                     # Unit tests
│   ├── Domain/
│   ├── Data/
│   ├── Presentation/
│   └── Common/
│
└── AshishDemoUITests/                   # UI tests
```

## Usage

### Basic Flow

1. **Launch the app** - The holdings screen loads automatically
2. **View holdings** - Scroll through your holdings list
3. **View summary** - Tap the collapsible footer to see detailed summary
4. **Refresh data** - Pull down to refresh holdings
5. **Offline mode** - App works offline using cached Core Data

### Key Components

#### Holdings List
- Displays symbol, quantity, LTP, and P&L
- Color-coded P&L (green for profit, red for loss)
- Indian currency formatting (₹)

#### Collapsible Summary
- **Collapsed**: Shows total P&L with percentage
- **Expanded**: Shows detailed breakdown:
  - Current value
  - Total investment
  - Today's P&L
  - Total P&L

## Testing

The project includes comprehensive unit tests covering all layers.

### Running Tests

**In Xcode:**
1. Press `Cmd + U` to run all tests
2. Or use the Test Navigator (⌘6) to run specific tests

**Via Command Line:**
```bash
xcodebuild test -scheme AshishDemo -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Test Coverage

- ✅ **Domain Layer**: Entities, Use Cases, Errors
- ✅ **Data Layer**: Repository, Mappers, Network
- ✅ **Presentation Layer**: ViewModel, State Management
- ✅ **Common**: Utilities, Formatters

### Test Structure

```
AshishDemoTests/
├── Domain/
│   ├── HoldingTests.swift
│   ├── DomainErrorTests.swift
│   └── FetchHoldingsUseCaseTests.swift
├── Data/
│   ├── HoldingsRepositoryImplTests.swift
│   ├── HoldingsMapperTests.swift
│   └── NetworkClientTests.swift
├── Presentation/
│   └── HoldingsViewModelTests.swift
└── Common/
    └── CurrencyFormatterTests.swift
```

## Technologies

### Core Technologies
- **Swift 5.10+**: Modern Swift with async/await
- **UIKit**: Programmatic UI (no storyboards)
- **Core Data**: Offline data persistence
- **Combine**: Reactive state management

### Architecture Patterns
- **Clean Architecture**: Layered architecture
- **MVVM**: Model-View-ViewModel pattern
- **Repository Pattern**: Data abstraction
- **Dependency Injection**: Protocol-based DI

### Key Features
- **Async/Await**: Modern concurrency
- **DiffableDataSource**: Efficient table updates
- **Protocol-Oriented**: Testable, maintainable code
- **Error Handling**: Comprehensive error types

## 📸 Screenshots

### Holdings List
- Clean table view with holdings data
- Color-coded P&L indicators
- Pull-to-refresh support

### Collapsible Summary
- **Collapsed State**: Shows total P&L
- **Expanded State**: Detailed breakdown with all metrics

## 🎯 Key Features Implementation

### 1. Clean Architecture
- **Domain Layer**: Pure business logic, no dependencies
- **Data Layer**: Handles API and persistence
- **Presentation Layer**: UI and user interactions

### 2. Error Handling
- Custom error types (`NetworkError`, `DomainError`)
- User-friendly error messages
- Retry mechanisms
- Offline fallback

### 3. Performance
- Pre-calculated P&L values
- DiffableDataSource for efficient updates
- Background Core Data operations
- Cell reuse optimization

### 4. Offline Support
- Core Data integration
- Cache-first strategy
- Automatic fallback to cached data

## 📝 Code Quality

- ✅ No force unwraps
- ✅ No singletons (except convenience shared)
- ✅ Proper access control
- ✅ Comprehensive error handling
- ✅ Protocol-oriented design
- ✅ Dependency injection
- ✅ Unit test coverage

## State Management

The app uses a robust state management system:

```swift
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error, retryAction: () -> Void)
}
```

## API Integration

The app fetches data from a mock API endpoint. The network layer includes:
- Request/response handling
- Error mapping
- Timeout handling
- Cancellation support

## Data Persistence

Core Data is used for offline storage:
- Automatic caching of API responses
- Background context for heavy operations
- Batch operations for performance
- Proper merge policies

## 📄 License

This project is for demonstration purposes.

## 👤 Author

**Ashish Singh**

---