# Euromillions Mobile Apps

Native iOS and Android mobile applications for the Euromillions API.

## Features

- **View Generated Grids**: Browse lottery grids with optimized numbers based on statistical frequency
- **Generate New Grids**: Create 4 new grids for the next draw with a single tap
- **Fetch History**: Download the latest Euromillions draw results
- **Beautiful UI**: Modern, native design with Material Design 3 (Android) and SwiftUI (iOS)
- **Pull to Refresh**: Easy data synchronization

## Architecture

Both apps follow modern mobile development best practices:

- **iOS**: SwiftUI + async/await + URLSession
- **Android**: Jetpack Compose + Kotlin Coroutines + Retrofit

## iOS App Setup

### Prerequisites

- macOS with Xcode 15.0 or later
- iOS 16.0+ deployment target

### Installation

1. Navigate to the iOS project:
   ```bash
   cd mobile/ios/EuromillionsApp
   ```

2. Open the project in Xcode:
   ```bash
   open EuromillionsApp.xcodeproj
   ```

3. Configure the API URL:
   - Open `EuromillionsApp/APIClient.swift`
   - Update the `baseURL` constant:
     ```swift
     // For local testing
     private let baseURL = "http://localhost:8080"
     
     // For production (replace with your API URL)
     private let baseURL = "https://your-api.render.com"
     ```

4. Select a simulator (e.g., iPhone 15 Pro)

5. Build and run (⌘R)

### iOS Project Structure

```
EuromillionsApp/
├── EuromillionsApp/
│   ├── Models.swift              # Data models (Draw, Grid, NewGrid)
│   ├── APIClient.swift           # API service layer
│   ├── EuromillionsAppApp.swift # App entry point
│   ├── Views/
│   │   ├── GridsListView.swift   # Main grids list
│   │   ├── GridDetailView.swift  # Grid detail screen
│   │   └── HistoryView.swift     # History fetch screen
│   └── Assets.xcassets/          # App assets
└── EuromillionsApp.xcodeproj/    # Xcode project
```

## Android App Setup

### Prerequisites

- Android Studio Hedgehog (2023.1.1) or later
- Android SDK 24+ (minimum)
- Android SDK 34+ (target)

### Installation

1. Open Android Studio

2. Select "Open an Existing Project"

3. Navigate to `mobile/android/EuromillionsApp` and click "Open"

4. Wait for Gradle sync to complete

5. Configure the API URL:
   - Open `app/src/main/java/com/euromillions/app/data/ApiClient.kt`
   - Update the `BASE_URL` constant:
     ```kotlin
     // For local testing with Android emulator
     private const val BASE_URL = "http://10.0.2.2:8080/"
     
     // For local testing with physical device (use your computer's IP)
     private const val BASE_URL = "http://192.168.1.X:8080/"
     
     // For production (replace with your API URL)
     private const val BASE_URL = "https://your-api.render.com/"
     ```

6. Start an emulator or connect a physical device

7. Build and run (Shift+F10 or click the green play button)

### Android Project Structure

```
EuromillionsApp/
├── app/
│   ├── build.gradle.kts          # App-level build configuration
│   ├── src/main/
│   │   ├── AndroidManifest.xml   # App manifest
│   │   ├── java/com/euromillions/app/
│   │   │   ├── MainActivity.kt   # Main activity with navigation
│   │   │   ├── data/
│   │   │   │   ├── Models.kt     # Data models with serializers
│   │   │   │   ├── ApiService.kt # Retrofit API interface
│   │   │   │   └── ApiClient.kt  # Retrofit client setup
│   │   │   └── ui/
│   │   │       ├── GridsScreen.kt       # Main grids list
│   │   │       ├── GridDetailScreen.kt  # Grid detail view
│   │   │       ├── HistoryScreen.kt     # History fetch view
│   │   │       └── theme/
│   │   │           └── Theme.kt         # Material3 theme
│   │   └── res/                  # Resources
│   └── proguard-rules.pro        # ProGuard rules
├── build.gradle.kts              # Project-level build config
└── settings.gradle.kts           # Gradle settings
```

## API Configuration

### Local Development

**iOS**: Use `http://localhost:8080` (runs on simulator)

**Android**: 
- Emulator: Use `http://10.0.2.2:8080` (special IP that routes to host)
- Physical device: Use your computer's local IP (e.g., `http://192.168.1.5:8080`)

To find your computer's IP:
```bash
# macOS/Linux
ifconfig | grep "inet "

# Windows
ipconfig
```

### Production

Update the base URL to your deployed API (e.g., Render.com URL).

## App Features

### Grids List Screen
- Displays up to 20 most recent generated grids
- Shows numbers (1-50) and stars (1-12) in colored balls
- Pull-to-refresh to reload data
- Tap to view grid details
- Generate button to create new grids

### Grid Detail Screen
- Large display of all 5 numbers
- Large display of 2 lucky stars
- Draw date information
- Generation timestamp
- Beautiful gradient design

### History Screen
- Fetch button to download latest draws
- Loading indicator during fetch
- Success/error message display
- Background data synchronization

## Dependencies

### iOS
- SwiftUI (UI framework)
- Foundation (networking, JSON)
- Combine (async operations)

### Android
- Jetpack Compose (UI framework)
- Material 3 (design system)
- Retrofit (HTTP client)
- kotlinx.serialization (JSON parsing)
- Navigation Compose (navigation)
- Accompanist SwipeRefresh (pull-to-refresh)

## Troubleshooting

### iOS

**"Cannot connect to API"**
- Ensure the backend is running
- Check the API URL in `APIClient.swift`
- For localhost, run backend on the same machine as the simulator

**Build errors**
- Clean build folder: Product → Clean Build Folder (Shift+⌘K)
- Reset package cache if needed

### Android

**"Failed to connect"**
- Check API URL in `ApiClient.kt`
- Ensure `usesCleartextTraffic="true"` in `AndroidManifest.xml` for HTTP
- For emulator, use `10.0.2.2` instead of `localhost`
- Check internet permissions in manifest

**Gradle sync failed**
- File → Invalidate Caches → Invalidate and Restart
- Check internet connection
- Verify Gradle version compatibility

**Serialization errors**
- Ensure date formats match the API response
- Check `LocalDateSerializer` and `LocalDateTimeSerializer` in `Models.kt`

## Testing

### Manual Testing Checklist

- [ ] App launches without crashes
- [ ] Grids list loads with data
- [ ] Can generate new grids
- [ ] Pull-to-refresh works
- [ ] Can navigate to grid detail
- [ ] Grid detail shows correct numbers and stars
- [ ] Can fetch history
- [ ] Error messages display correctly
- [ ] Navigation works smoothly

## License

Part of the Euromillions Bot project.
