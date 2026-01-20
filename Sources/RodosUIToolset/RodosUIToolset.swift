//
//  RodosUIToolset.swift
//  RodosUIToolset
//
//  Created by Rodolfo Castillo Vidrio on 26/01/26.
//

import SwiftUI

/// RodosUIToolset - A beautiful UI component library for iOS
///
/// Import this module to access all components:
/// ```swift
/// import RodosUIToolset
/// ```
///
/// ## Available Components
///
/// - **PrecisableInput**: Special input component for precise value selection with units
/// - **FMSetter**: Horizontal scroll picker with magnifying glass effect
/// - **PrecisableUnit**: Enum for available units (kg, lbs, newtons, inches, mm, liters)
///
/// ## Usage Example
///
/// ```swift
/// import RodosUIToolset
///
/// PrecisableInput(
///     value: $weight,
///     availableUnits: [.kilograms, .pounds],
///     selectedUnit: $unit,
///     quickPills: [1, 2, 5, 7, 10, 15, 20]
/// )
/// ```
///
/// All components are public and can be used directly after importing the module.

// This file serves as the main entry point for the RodosUIToolset module
// All public types from other files in this module are automatically available

