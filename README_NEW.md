# God Tier Music Player

An elite, aesthetic music player built with Flutter featuring "God-like" animations and a "Liquid-Glass" UI design philosophy.

## 🎨 Features

### Divine Animations
- **Liquid Morphing Icons**: Play/Pause button morphs like melting liquid mercury
- **Breathing Artwork**: Album art pulses with simulated BPM and 3D parallax tilt
- **Dynamic Aura Background**: Liquid metaballs extracted from artwork colors
- **Particle Shift Transitions**: 1000 glowing particles during track changes
- **Elastic Scrubber**: Rubber string physics with waggle effect

### Core Functionality
- **Offline Engine**: Local storage scanning with high-res thumbnails
- **Global Search**: YouTube integration for any modern track
- **Haptic Symphony**: Micro-interaction feedback on every touch
- **iOS Integration**: Lockscreen/Control Center support
- **Glass-Morphic UI**: True black OLED with blur effects

## 🏗️ Architecture

### Tech Stack
- **Flutter**: Cross-platform framework
- **just_audio**: Audio playback engine
- **youtube_explode_dart**: Global search and streaming
- **flutter_riverpod**: State management
- **canvas**: Custom shaders and animations
- **sensors_plus**: 3D parallax effects
- **palette_generator**: Dynamic color extraction

### Project Structure
```
lib/
├── services/
│   ├── audio_service.dart          # Audio playback singleton
│   └── youtube_search_service.dart # Global search integration
├── widgets/
│   ├── liquid_aura.dart            # Dynamic background
│   ├── morphing_play_button.dart   # Liquid mercury animation
│   ├── elastic_scrubber.dart       # Rubber string physics
│   ├── breathing_artwork.dart      # 3D parallax + BPM sync
│   └── particle_shift_transition.dart # Track transitions
├── screens/
│   ├── home_screen.dart            # Library view
│   ├── search_screen.dart          # Global search
│   └── now_playing_screen.dart     # Full player
├── models/
│   └── track.dart                  # Track data model
└── main.dart                       # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.19.0+
- Xcode 15.2+ (for iOS)
- Android Studio (for Android)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/god-tier-music-player.git
cd god-tier-music-player
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### iOS Setup

1. Navigate to the iOS directory:
```bash
cd ios
```

2. Install CocoaPods:
```bash
pod install
```

3. Open `Runner.xcworkspace` in Xcode

4. Configure your signing certificates and provisioning profiles

## 🔧 Configuration

### GitHub Secrets for CI/CD

Set up these secrets in your GitHub repository:

- `PROVISIONING_PROFILE_BASE64`: Base64 encoded .mobileprovision file
- `CERTIFICATE_BASE64`: Base64 encoded .p12 certificate
- `CERTIFICATE_PASSWORD`: Certificate password
- `APPLE_ID`: Apple ID for TestFlight
- `APPLE_APP_SPECIFIC_PASSWORD`: App-specific password
- `APPLE_TEAM_ID`: Your Apple Developer Team ID

### Export Options

Update `ios/ExportOptions.plist` with your team ID and provisioning profile name.

## 📱 Build & Deploy

### Local Development

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release

# Android
flutter build apk --release
flutter build appbundle --release
```

### CI/CD Pipeline

The GitHub Actions workflow automatically:

1. **Analyzes** code quality and runs tests
2. **Builds** iOS IPA with proper signing
3. **Builds** Android APK/AAB
4. **Uploads** artifacts to GitHub
5. **Deploys** to TestFlight (on tagged releases)

Trigger builds by:
- Pushing to `main`/`develop` branches
- Creating a tag (`v1.0.0`)
- Opening pull requests

## 🎯 Design Philosophy

### The "Crying" Factor
Every interaction has weight, inertia, and elastic spring physics. No standard Material/Cupertino transitions.

### Liquid-Glass Aesthetic
- True black OLED backgrounds
- Blur and transparency effects
- Dynamic color extraction
- Organic, flowing animations

### Performance Optimizations
- Custom painters for smooth 60fps
- Efficient particle systems
- Optimized audio streaming
- Memory-conscious animations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- just_audio for robust audio playback
- youtube_explode_dart for YouTube integration
- The open-source community for inspiration

---

**Built with ❤️ and a lot of liquid mercury**
