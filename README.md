# Quiz App

A modern Flutter quiz application with category selection, timed questions, and leaderboard functionality.

## Features

### ✅ **Implemented Features**
- 🎯 **Category Selection**: Choose from Geography, Math, Science, and Literature
- ⏱️ **Timed Questions**: 15-second countdown per question with visual timer
- 🎨 **Smooth Animations**: Beautiful transitions between questions
- 📊 **Leaderboard**: Track and display high scores
- 🧮 **Math Support**: LaTeX rendering for mathematical expressions
- 🌙 **Theme Support**: Dark and light mode compatibility
- 📱 **Responsive Design**: Works on all screen sizes
- 🔄 **Navigation**: Proper back button handling and navigation flow

### 🚧 **Planned Features (Not Yet Implemented)**
- 🧪 **Unit Tests**: Comprehensive test coverage for score calculation and business logic
- 🔄 **CI/CD Pipeline**: GitHub Actions for automated testing and analysis
- 📊 **Analytics**: User behavior tracking and performance metrics
- 🔔 **Notifications**: Reminders and achievement notifications
- 🌐 **Online Leaderboard**: Cloud-based score sharing
- 🎮 **Multiplayer**: Real-time quiz competitions

## Flutter/Dart Version

- **Flutter**: 3.27.x or higher
- **Dart**: 3.0.0 or higher
- **Minimum SDK**: Android API 21, iOS 11.0

## Setup Steps

### Prerequisites
- Flutter SDK installed
- Android Studio / VS Code
- Android Emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_quiz_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform Setup

#### Android
- Ensure `android:usesCleartextTraffic="true"` is set in `AndroidManifest.xml`
- Internet permission is required for LaTeX rendering

#### iOS
- Add required permissions in `Info.plist` for webview functionality
- Ensure `NSAppTransportSecurity` is configured

## Architecture Overview

The app follows **Clean Architecture** principles with **Riverpod** for state management:

### Project Structure
```
lib/
├── data/
│   ├── datasources/          # Data sources (Hive, JSON)
│   └── repositories/         # Repository implementations
├── domain/
│   ├── entities/            # Business entities (Question, Score)
│   ├── repositories/        # Repository interfaces
│   └── usecases/           # Business logic use cases
├── presentation/
│   ├── providers/          # Riverpod providers
│   └── screens/            # UI screens
└── main.dart              # App entry point
```

### Key Components

- **Domain Layer**: Contains business logic and entities
- **Data Layer**: Handles data persistence (Hive for scores, JSON for questions)
- **Presentation Layer**: UI components with Riverpod state management
- **Providers**: Quiz state, questions, and repository providers

### State Management
- **Riverpod**: For reactive state management
- **Provider Families**: For category-based quiz filtering
- **StateNotifier**: For quiz logic and timer management

### Data Flow
1. **Questions**: Loaded from JSON assets
2. **Scores**: Stored locally using Hive database
3. **State**: Managed through Riverpod providers
4. **UI**: Reactive updates based on state changes

## Dependencies

- `flutter_riverpod`: State management
- `flutter_tex`: LaTeX rendering for math questions
- `hive`: Local database for scores
- `flutter_svg`: SVG rendering for math expressions

## Usage

1. **Start Quiz**: Select a category from the home screen
2. **Answer Questions**: Choose answers within the 15-second time limit
3. **View Results**: See your score and save to leaderboard
4. **Check Leaderboard**: View top scores from all players

## Testing & Quality Assurance

### Current Status
- ✅ **Manual Testing**: All features tested manually
- ❌ **Unit Tests**: Not implemented yet
- ❌ **Integration Tests**: Not implemented yet
- ❌ **CI/CD**: Not implemented yet

### Planned Testing Strategy
- **Unit Tests**: Test score calculation, timer logic, and business rules
- **Widget Tests**: Test UI components and user interactions
- **Integration Tests**: Test complete user flows
- **CI/CD Pipeline**: Automated testing on pull requests

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features (when testing framework is implemented)
5. Submit a pull request

## License

This project is licensed under the MIT License.

