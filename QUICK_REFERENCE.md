# Smart Nutrition App - Quick Reference Guide

## 🎯 Current Features

### Bottom Navigation (6 Tabs)
1. **Home** - Main dashboard with food categories
2. **Scanner** - Food recognition via camera
3. **Meals** - Track and manage meals
4. **Tips** - Daily nutrition & fitness tips (auto-notifications every 30 seconds)
5. **Notifications** - View notification history with filters
6. **Settings** - App preferences and theme

### Key Features

#### 📱 Notifications System
- **Automatic Meal Notifications**: When you add a meal, you get a notification with:
  - Meal name
  - Calories
  - Protein content
- **Auto-Tips**: Tips screen sends a new tip notification every 30 seconds
- **Notification History**: All notifications are saved and can be viewed in the Notifications tab
- **Filtering**: Filter notifications by type (All, Meals, Tips)
- **Swipe to Delete**: Swipe left on any notification to delete it

#### 💡 Tips Screen
- Beautiful gradient background
- Large centered tip card with icon
- Three action buttons:
  - **New Tip**: Get a random tip
  - **Nutrition**: Get a nutrition-specific tip
  - **Fitness**: Get a fitness-specific tip
- Auto-notification every 30 seconds
- Info box explaining automatic notifications

#### 📊 Notification History
- View all notifications in one place
- Filter by type (All, Meals, Tips)
- See time elapsed (now, X minutes ago, X hours ago, etc.)
- View meal details (name, calories, protein)
- Delete individual notifications
- Clear all notifications at once

## 🔧 Technical Stack

### Frontend
- **Framework**: Flutter
- **State Management**: BLoC/Cubit
- **Local Storage**: Hive
- **Notifications**: flutter_local_notifications
- **UI**: Material Design 3

### Backend Integration
- **API**: Dio HTTP client
- **Authentication**: Token-based (stored locally)
- **Food Recognition**: Google Vision API

### Database
- **Local**: Hive (for notifications, meals, settings)
- **Remote**: REST API

## 📋 File Structure

```
lib/
├── data/
│   ├── services/
│   │   ├── notification_service.dart
│   │   ├── notification_history_service.dart
│   │   ├── tips_service.dart
│   │   └── ...
│   └── models/
├── logic/
│   └── cubits/
│       ├── notification_history_cubit.dart
│       ├── tips_cubit.dart
│       └── ...
├── presentation/
│   └── screens/
│       ├── main_navigation_screen.dart
│       ├── notifications_screen.dart
│       ├── tips_screen.dart
│       └── ...
└── main.dart
```

## 🚀 How to Run

### Prerequisites
- Flutter SDK (latest)
- Android SDK / iOS SDK
- Dart SDK

### Build & Run
```bash
# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 🐛 Troubleshooting

### Notifications Not Showing
1. Check if notifications permission is granted
2. Verify `NotificationService` is initialized in `main.dart`
3. Check Android notification channels are created

### Tips Not Auto-Updating
1. Verify timer is running (check `_startAutoTips()` in `tips_screen.dart`)
2. Check `TipsCubit` is properly emitting state
3. Verify `NotificationService` is initialized

### Notification History Empty
1. Check `NotificationHistoryService` is initialized
2. Verify Hive box is opened correctly
3. Check JSON serialization in `_notificationToJson()`

## 📝 Recent Changes

### Latest Updates
- ✅ Fixed all deprecation warnings (withOpacity → withValues)
- ✅ Fixed notification history type safety (Box<String> with JSON)
- ✅ Implemented auto-notification timer with proper cleanup
- ✅ Added notification badge to bottom navigation
- ✅ Redesigned tips screen with modern UI

### Code Quality
- All files pass Flutter diagnostics
- No errors or warnings
- Proper error handling throughout
- RTL support for Arabic text

## 🎨 UI/UX Features

### Tips Screen
- Green gradient background
- Smooth animations
- Icon-based tip categories
- Color-coded by type (Orange for nutrition, Purple for fitness)
- Responsive design

### Notifications Screen
- Clean card-based layout
- Color-coded by notification type
- Time-based sorting (newest first)
- Swipe-to-delete with confirmation
- Empty state with helpful message

### Bottom Navigation
- Floating snake navigation bar
- Real-time notification badge
- Smooth page transitions
- Dark mode support

## 🔐 Security

- Token-based authentication
- Secure local storage with Hive
- FileProvider for safe file access
- Proper permission handling

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review the implementation status document
3. Check Flutter/Dart documentation
4. Review the code comments in relevant files
