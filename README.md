# ⏱️ LapTimerApp

A sleek **SwiftUI stopwatch app** with start/stop, reset, lap saving, deletion, renaming, and persistence. Designed with a modern gradient UI and basic unit tests.

---

## ✨ Features

- **Start / Stop**
  - Big pill-shaped button toggles between Start and Stop
  - Smooth animation and gradient styling

- **Reset**
  - Small circular button with ⟳ icon
  - Clears the timer without affecting saved laps

- **Lap Times**
  - Save lap times with a tap
  - List of laps shown below controls (newest first)
  - Swipe left to delete
  - Long-press to rename a lap

- **Total Time**
  - Displays sum of all lap times

- **Persistence**
  - Laps + timer state stored in `UserDefaults`
  - Data survives app restarts

- **Formatting**
  - Elapsed time shown in `MM:SS:ms` (hundredths)

- **Unit Tests**
  - Verify formatting, start/stop, lap saving, deletion, and renaming

---
## 🚀 Getting Started

### Requirements
- Xcode 15+
- iOS 17+
- Swift 5.9+

### Installation
1. Clone or download this repository
2. Open `LapTimerApp.xcodeproj` in Xcode
3. Run on simulator or device

---

## 🗂 Project Structure

```
LapTimerApp/
 ├── LapTimerApp.swift        # App entry point
 ├── ContentView.swift        # UI + ViewModel + Model + Subviews
 ├── Assets/                  # App assets
 ├── LapTimerAppTests/        # Unit tests (ClockTests.swift)
 └── LapTimerAppUITests/      # Auto-generated UI test target
```

---

## 🧪 Running Tests

- Open the project in Xcode
- Press **⌘U** or go to `Product > Test`
- Runs all tests in `ClockTests.swift`

---

## 🛠 Technologies

- **SwiftUI** for UI
- **Combine** for timer updates
- **UserDefaults** for persistence
- **XCTest** for unit testing

---
