# Changelog

All notable changes to RodosUIToolset will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-26

### Added
- **PrecisableInput**: Special input component for precise value selection with units
  - Label display with value and unit (configurable units: kg, lbs, newtons, inches, mm, liters)
  - Quick pills sub-input (optional) - Additive/subtractive buttons with pre-established values
  - Tap hold (0.5s) - Shows horizontal scroll picker (FMSetter) that animates scroll in real-time
  - Double tap - Opens numeric keyboard as first responder for precise input
  - Smooth transitions and animations
  - Configurable picker range and step
  - Callback support for value changes

- **FMSetter**: Horizontal scroll picker component with magnifying glass effect
  - Horizontal scrolling picker with magnifying glass effect
  - Smooth animations when value changes externally
  - Natural inertia (fast swipe = more distance, slow swipe = precise)
  - Text auto-scales to fit without truncation
  - Generic numeric type support (Int, Double, etc.)
  - Custom formatters for value display
  - Convenience initializers for Int and Double ranges

- **PrecisableUnit**: Enum for available units
  - Kilograms (kg)
  - Pounds (lbs)
  - Newtons (N)
  - Inches (in)
  - Millimeters (mm)
  - Liters (L)

### Documentation
- Complete README with usage examples
- MIT License
- Swift Package Manager setup
- Usage guide for remote importing

### Infrastructure
- Swift Package Manager support
- iOS 17.0+ requirement
- Swift 5.9+ requirement

[1.0.0]: https://github.com/King5upah/RodosUIToolset/releases/tag/1.0.0

