//
//  PrecisableInput.swift
//  RodosUIToolset
//
//  Created by Rodolfo Castillo Vidrio on 26/01/26.
//

import SwiftUI

/// Unidades disponibles para el componente PrecisableInput
public enum PrecisableUnit: String, CaseIterable, Identifiable {
    case kilograms = "kg"
    case pounds = "lbs"
    case newtons = "N"
    case inches = "in"
    case millimeters = "mm"
    case liters = "L"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .kilograms: return "Kilograms"
        case .pounds: return "Pounds"
        case .newtons: return "Newtons"
        case .inches: return "Inches"
        case .millimeters: return "Millimeters"
        case .liters: return "Liters"
        }
    }
}

/// Componente especial para input de valores con unidades
/// Soporta múltiples formas de input: label con gestos, quick pills, horizontal scroll picker, y teclado numérico
public struct PrecisableInput: View {
    // MARK: - Properties
    @Binding private var value: Double
    private let availableUnits: [PrecisableUnit]
    @Binding private var selectedUnit: PrecisableUnit
    private let quickPills: [Double]?
    
    // Callbacks para interacción con sub-inputs
    private let onValueAdded: ((Double) -> Void)?
    private let onValueSubtracted: ((Double) -> Void)?
    private let onValueSet: ((Double) -> Void)?
    
    // Configuración del picker horizontal
    private let pickerRange: ClosedRange<Double>
    private let pickerStep: Double
    
    // MARK: - State
    @State private var showingHorizontalPicker = false
    @State private var showingNumericKeyboard = false
    @State private var keyboardInputValue: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var pickerDismissTimer: Timer?
    @State private var isLongPressing = false
    @State private var longPressTimer: Timer?
    @State private var dragStartValue: Double = 0.0
    @State private var dragStartLocation: CGPoint = .zero
    
    // MARK: - Initializers
    public init(
        value: Binding<Double>,
        availableUnits: [PrecisableUnit],
        selectedUnit: Binding<PrecisableUnit>,
        quickPills: [Double]? = nil,
        pickerRange: ClosedRange<Double> = 0.0...200.0,
        pickerStep: Double = 0.5,
        onValueAdded: ((Double) -> Void)? = nil,
        onValueSubtracted: ((Double) -> Void)? = nil,
        onValueSet: ((Double) -> Void)? = nil
    ) {
        self._value = value
        self.availableUnits = availableUnits
        self._selectedUnit = selectedUnit
        self.quickPills = quickPills
        self.pickerRange = pickerRange
        self.pickerStep = pickerStep
        self.onValueAdded = onValueAdded
        self.onValueSubtracted = onValueSubtracted
        self.onValueSet = onValueSet
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(spacing: 12) {
            // Container with label and overlays
            ZStack(alignment: .top) {
                // Main label with value and unit
                labelView
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        if !showingHorizontalPicker {
                            showNumericKeyboard()
                        }
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { dragValue in
                                if !isLongPressing && !showingHorizontalPicker {
                                    // Iniciar long press
                                    isLongPressing = true
                                    dragStartValue = value
                                    dragStartLocation = dragValue.startLocation
                                    longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                        // Después de 0.5s, mostrar el picker
                                        showHorizontalPicker()
                                    }
                                } else if showingHorizontalPicker {
                                    // Si el picker está visible, actualizar el valor basado en el drag
                                    updateValueFromDrag(dragValue: dragValue)
                                }
                            }
                            .onEnded { _ in
                                if !showingHorizontalPicker {
                                    // Si el picker no apareció, cancelar
                                    cancelLongPress()
                                } else {
                                    // Si el picker está visible, cerrar después de un breve delay
                                    isLongPressing = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        dismissHorizontalPicker()
                                    }
                                }
                                dragStartLocation = .zero
                            }
                    )
                    .opacity(showingHorizontalPicker || showingNumericKeyboard ? 0.3 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: showingHorizontalPicker)
                    .animation(.easeInOut(duration: 0.2), value: showingNumericKeyboard)
                    .allowsHitTesting(!showingHorizontalPicker) // Deshabilitar cuando el picker está visible
                
                // Horizontal scroll picker (appears on long press, above label)
                // Siempre presente pero invisible para recibir toques desde el inicio
                if showingHorizontalPicker {
                    horizontalPickerView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(1)
                } else {
                    // Mantener una instancia invisible para que el scroll se inicialice
                    horizontalPickerView
                        .opacity(0.0)
                        .allowsHitTesting(false)
                        .zIndex(0)
                }
                
                // Numeric keyboard overlay (appears on double tap, above label)
                if showingNumericKeyboard {
                    numericKeyboardOverlay
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(2)
                }
            }
            
            // Quick pills sub-input (if provided)
            if let quickPills = quickPills {
                quickPillsView(values: quickPills)
            }
        }
    }
    
    // MARK: - Label View
    private var labelView: some View {
        HStack(spacing: 4) {
            Text(formatValue(value))
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(selectedUnit.rawValue)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Quick Pills View
    private func quickPillsView(values: [Double]) -> some View {
        VStack(spacing: 8) {
            // Primera fila: Botones positivos (+)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(values, id: \.self) { pillValue in
                        Button {
                            addValue(pillValue)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.caption)
                                Text(formatValue(pillValue))
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Segunda fila: Botones negativos (-)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(values, id: \.self) { pillValue in
                        Button {
                            subtractValue(pillValue)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "minus")
                                    .font(.caption)
                                Text(formatValue(pillValue))
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Horizontal Picker View
    private var horizontalPickerView: some View {
        VStack(spacing: 12) {
            // Dismiss button
            Button {
                dismissHorizontalPicker()
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
            
            // FMSetter picker - debe recibir todos los toques directamente
            // Usar id solo cuando aparece para forzar inicialización correcta del scroll
            FMSetter(
                range: pickerRange,
                step: pickerStep,
                selectedValue: Binding(
                    get: { value },
                    set: { newValue in
                        value = newValue
                    }
                ),
                formatter: { String(format: "%.1f", $0) }
            )
            .id(showingHorizontalPicker ? "fmsetter-visible" : "fmsetter-hidden")
            .padding(.horizontal)
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        // Al soltar después de interactuar, cerrar el picker
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismissHorizontalPicker()
                        }
                    }
            )
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10)
        )
        .padding(.horizontal)
        .offset(y: -80) // Aparece encima del label
    }
    
    // MARK: - Numeric Keyboard Overlay
    private var numericKeyboardOverlay: some View {
        VStack(spacing: 16) {
            // Text field for input
            TextField("Enter value", text: $keyboardInputValue)
                .keyboardType(.decimalPad)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 5)
                )
                .focused($isTextFieldFocused)
                .onAppear {
                    keyboardInputValue = formatValue(value)
                    // Hacer que el TextField sea first responder
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isTextFieldFocused = true
                    }
                }
            
            // Action buttons
            HStack(spacing: 12) {
                Button {
                    dismissNumericKeyboard()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                        )
                }
                
                Button {
                    setValueFromKeyboard()
                } label: {
                    Text("Set")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10)
        )
        .offset(y: -100) // Aparece encima del label
    }
    
    // MARK: - Helper Methods
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    private func addValue(_ amount: Double) {
        value = max(0, value + amount)
        onValueAdded?(amount)
    }
    
    private func subtractValue(_ amount: Double) {
        value = max(0, value - amount)
        onValueSubtracted?(amount)
    }
    
    private func showNumericKeyboard() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showingNumericKeyboard = true
        }
    }
    
    private func dismissNumericKeyboard() {
        isTextFieldFocused = false
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showingNumericKeyboard = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            keyboardInputValue = ""
        }
    }
    
    private func setValueFromKeyboard() {
        if let newValue = Double(keyboardInputValue) {
            value = max(0, newValue)
            onValueSet?(value)
        }
        dismissNumericKeyboard()
    }
    
    private func cancelLongPress() {
        isLongPressing = false
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
    
    private func showHorizontalPicker() {
        isLongPressing = false
        longPressTimer?.invalidate()
        longPressTimer = nil
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showingHorizontalPicker = true
        }
    }
    
    private func updateValueFromDrag(dragValue: DragGesture.Value) {
        // Calcular el cambio basado en el drag horizontal
        // Usar el ancho de la pantalla como referencia para normalizar
        let screenWidth = UIScreen.main.bounds.width
        let dragDelta = Double(dragValue.translation.width)
        
        // Calcular el nuevo valor basado en el rango del picker
        let range = pickerRange.upperBound - pickerRange.lowerBound
        // Normalizar: arrastrar todo el ancho de la pantalla = todo el rango
        let normalizedDelta = dragDelta / Double(screenWidth)
        let valueDelta = normalizedDelta * range
        
        // Aplicar el cambio al valor inicial del drag
        let newValue = dragStartValue + valueDelta
        
        // Clampear al rango
        let clampedValue = max(pickerRange.lowerBound, min(pickerRange.upperBound, newValue))
        
        // Redondear al step más cercano
        let steppedValue = round(clampedValue / pickerStep) * pickerStep
        
        // Actualizar el valor - el FMSetter se actualizará automáticamente porque comparte el binding
        value = steppedValue
    }
    
    private func dismissHorizontalPicker() {
        pickerDismissTimer?.invalidate()
        pickerDismissTimer = nil
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showingHorizontalPicker = false
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var weight: Double = 20.0
        @State private var unit: PrecisableUnit = .kilograms
        
        var body: some View {
            VStack(spacing: 40) {
                PrecisableInput(
                    value: $weight,
                    availableUnits: [.kilograms, .pounds],
                    selectedUnit: $unit,
                    quickPills: [1, 2, 5, 7, 10, 15, 20]
                )
                
                Text("Value: \(weight) \(unit.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}

