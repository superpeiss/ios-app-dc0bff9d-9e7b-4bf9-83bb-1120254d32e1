# Cloud File Browser

A unified iOS file browser app that integrates with multiple cloud storage providers.

## Features

- 🔐 Secure authentication with multiple cloud services
- 📁 Browse files and folders across all connected accounts
- 👁️ Preview images and PDFs
- ✏️ File operations: rename, move, copy, delete
- 🔍 Search across all files
- 📱 Clean, native iOS interface using SwiftUI
- 🏗️ MVVM architecture for clean separation of concerns

## Supported Cloud Services

- Dropbox
- Google Drive
- OneDrive
- iCloud Drive

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

### Local Development

1. Clone the repository:
```bash
git clone https://github.com/superpeiss/ios-app-dc0bff9d-9e7b-4bf9-83bb-1120254d32e1.git
cd ios-app-dc0bff9d-9e7b-4bf9-83bb-1120254d32e1
```

2. Run the setup script to generate the Xcode project:
```bash
./setup.sh
```

3. Open the generated project:
```bash
open CloudFileBrowser.xcodeproj
```

4. Build and run in Xcode (⌘R)

### Manual Setup

If you prefer to set up manually:

1. Install XcodeGen:
```bash
brew install xcodegen
```

2. Generate the Xcode project:
```bash
xcodegen generate
```

## Project Structure

```
CloudFileBrowser/
├── Sources/
│   ├── Models/           # Data models
│   ├── ViewModels/       # MVVM view models
│   ├── Views/            # SwiftUI views
│   ├── Services/         # Cloud service integrations
│   └── Utilities/        # Helper utilities
├── Resources/            # Assets and resources
└── CloudFileBrowserApp.swift  # App entry point
```

## Architecture

The app follows the MVVM (Model-View-ViewModel) pattern:

- **Models**: Pure data structures representing files, accounts, and cloud services
- **ViewModels**: Business logic and state management using `@Published` properties
- **Views**: SwiftUI views that observe ViewModels and render UI
- **Services**: Protocol-based cloud service abstraction for easy extensibility

## Testing

Run tests in Xcode (⌘U) or via command line:

```bash
xcodebuild test -scheme CloudFileBrowser -destination 'platform=iOS Simulator,name=iPhone 15'
```

## CI/CD

The project includes GitHub Actions workflows for automated building and testing.

## Adding New Cloud Services

To add a new cloud service:

1. Add the service type to `CloudServiceType` enum
2. Create a new service class implementing `CloudServiceProtocol`
3. Register the service in `CloudServiceManager`

## License

This project is provided as-is for demonstration purposes.

## Configuration

For production use, you'll need to:

1. Register apps with each cloud provider
2. Configure OAuth credentials
3. Update `Info.plist` with your app's URL scheme
4. Replace mock services with real implementations

### Dropbox Configuration

1. Create an app at https://www.dropbox.com/developers/apps
2. Get your App Key
3. Update `Info.plist`:
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>db-YOUR_APP_KEY</string>
</array>
```

## Notes

- Currently uses mock implementations for demonstration
- File operations are fully functional in the UI layer
- To integrate real cloud APIs, replace `MockCloudService` with actual implementations
- OAuth flow is simplified for demo purposes
