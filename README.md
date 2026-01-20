# RodosUIToolset 🎨

A beautiful, reusable UI component library for iOS apps built with SwiftUI.

## ✨ Components

### PrecisableInput
A special input component for precise value selection with units. Supports multiple input methods: quick pills (additive values), horizontal scroll picker (FMSetter), and numeric keyboard.

**Features:**
- Label display with value and unit (configurable units: kg, lbs, newtons, inches, mm, liters)
- Quick pills sub-input (optional) - Additive/subtractive buttons with pre-established values (perfect for weight selection like loading plates)
- Tap hold (0.5s) - Shows horizontal scroll picker (FMSetter) that animates scroll in real-time
- Double tap - Opens numeric keyboard as first responder for precise input
- Smooth transitions and animations
- Configurable picker range and step
- Callback support for value changes

### FMSetter
Horizontal scroll picker component with a magnifying glass effect and smooth animations.

**Features:**
- Horizontal scrolling picker with magnifying glass effect
- Smooth animations when value changes externally
- Natural inertia (fast swipe = more distance, slow swipe = precise)
- Text auto-scales to fit without truncation
- Generic numeric type support (Int, Double, etc.)
- Custom formatters for value display

## 📦 Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/King5upah/RodosUIToolset.git", from: "1.0.0")
]
```

Or add it via Xcode:
1. File → Add Package Dependencies...
2. Enter: `https://github.com/King5upah/RodosUIToolset.git`
3. Select version

## 🚀 Usage

### Basic Import

```swift
import RodosUIToolset
```

Once imported, all components are available directly:

```swift
// Use PrecisableInput
PrecisableInput(...)

// Use FMSetter
FMSetter(...)

// Use PrecisableUnit
PrecisableUnit.kilograms
```

### Example: PrecisableInput

```swift
import SwiftUI
import RodosUIToolset

struct ContentView: View {
    @State private var weight: Double = 20.0
    @State private var unit: PrecisableUnit = .kilograms
    
    var body: some View {
        PrecisableInput(
            value: $weight,
            availableUnits: [.kilograms, .pounds],
            selectedUnit: $unit,
            quickPills: [1, 2, 5, 7, 10, 15, 20],
            pickerRange: 0.0...200.0,
            pickerStep: 0.5,
            onValueAdded: { amount in
                print("Added \(amount)")
            }
        )
    }
}
```

### Example: FMSetter

```swift
import SwiftUI
import RodosUIToolset

struct ContentView: View {
    @State private var selectedValue: Int = 10
    
    var body: some View {
        FMSetter(
            values: Array(0...100),
            selectedValue: $selectedValue,
            formatter: { "\($0) kg" }
        )
    }
}
```

## 📋 Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## 📄 License

MIT License - see LICENSE file for details

## 👤 Author

Rodolfo Castillo Vidrio
