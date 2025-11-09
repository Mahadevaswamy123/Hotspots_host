# Hotspot Host Onboarding – Flutter Assignment

This project is built as part of the Flutter internship assignment.  
It implements a 2-step onboarding flow where users can apply to become Hotspot hosts.

---

##  Features

### 🔹 Screen 1 – Experience Selection
- Fetches experiences via **Dio API**
- Horizontal stamp-style selector
- Glassmorphism UI with grayscale unselected / glow on selected
- 250-char input field
- Next button enabled only when user selects at least 1 item or enters note
- State managed with **Riverpod**
- Fully responsive

### 🔹 Screen 2 – Audio, Video & Text Input
- 600-char written answer
- Audio recording with waveform + cancel + delete + playback
- Video recording with camera preview + playback + delete
- Button fades in/out based on state
- Submit logs state and navigates to success screen
- State managed with **Riverpod**

### 🔹 Final Screen
- Thank-you screen with “Back to Start” button

---

##  Tech Stack

| Area | Package |
|-------|---------|
| State management | `flutter_riverpod` |
| Networking | `dio` |
| Audio recording | `flutter_sound` |
| Video recording | `camera` |
| Video playback | `video_player` |
| File handling | `path_provider` |
| Permissions | `permission_handler` |
| Image caching | `cached_network_image` |

---

##  Project Structure

```
lib/
  models/
  theme/
  providers/
  widgets/
  screens/
  core/
  utils/
```

 Clean architecture, reusable UI components, no business logic inside widgets.

---

##  Running the App

```
flutter pub get
flutter run
```

 **Important:** Audio & video recording will not work on emulator.  
Test on a real Android/iOS device.

---

##  Required Permissions

### Android
`android/app/src/main/AndroidManifest.xml`  
✅ Camera  
✅ Microphone  
✅ Storage (Android 10 and below)

### iOS
`ios/Runner/Info.plist`  
✅ NSCameraUsageDescription  
✅ NSMicrophoneUsageDescription  
✅ NSPhotoLibraryAddUsageDescription

---

##  Submission Notes

- ✅ UI uses modern dark glass theme, inspired by Figma but cleaned & improved
- ✅ All interactions are smooth & state-safe
- ✅ README + folder structure + comments included
- ✅ Ready for code review + demo video

---

##  Developer

```
Name: Mahadevaswamy H S

```

