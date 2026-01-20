//
//  FMSetter.swift
//  RodosUIToolset
//
//  Created by Rodolfo Castillo Vidrio on 12/01/26.
//

import SwiftUI

/// Horizontal scroll picker component with a magnifying glass effect.
public struct FMSetter<Value: Hashable & Numeric>: View {
    let values: [Value]
    @Binding var selectedValue: Value
    let formatter: (Value) -> String
    let onValueChanged: ((Value) -> Void)?
    
    private let itemWidth: CGFloat = 60
    private let itemHeight: CGFloat = 50
    private let spacing: CGFloat = 8
    
    public init(
        values: [Value],
        selectedValue: Binding<Value>,
        formatter: @escaping (Value) -> String = { "\($0)" },
        onValueChanged: ((Value) -> Void)? = nil
    ) {
        self.values = values
        self._selectedValue = selectedValue
        self.formatter = formatter
        self.onValueChanged = onValueChanged
    }
    
    @State private var scrollPosition: Value?
    
    public var body: some View {
        GeometryReader { geometry in
            contentView(geometry: geometry)
        }
        .frame(height: itemHeight + 50)
    }
    
    // MARK: - Private Helpers
    
    @ViewBuilder
    private func contentView(geometry: GeometryProxy) -> some View {
        let geometryWidth = geometry.size.width
        let loupeMinWidth = itemWidth + 20
        let loupeIdealWidth = itemWidth + 40
        let loupeMaxWidth = itemWidth + 60
        let loupeHeight = itemHeight + 20
        let contentMargin = (geometryWidth - itemWidth) / 2
        
        ZStack(alignment: .center) {
                // Background track
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.15))
                    .frame(height: itemHeight + 20)
                
                // Scrollable items (The Graduation Scale) - PLACED BELOW LOUPE
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(values, id: \.self) { value in
                            VStack(spacing: 4) {
                                // Periodic labels on the scale
                                Text(formatter(value))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.3))
                                    .opacity(selectedValue == value ? 0 : 1)
                                
                                // Graduation marks
                                HStack(spacing: (itemWidth + spacing) / 10) {
                                    ForEach(0..<5) { tick in
                                        Rectangle()
                                            .fill(Color.white.opacity(tick == 0 ? 0.6 : 0.3))
                                            .frame(width: 1.5, height: tick == 0 ? 15 : 8)
                                    }
                                }
                                .frame(width: itemWidth)
                            }
                            .frame(width: itemWidth, height: itemHeight + 20)
                            .id(value)
                            .visualEffect { content, proxy in
                                let frame = proxy.frame(in: .global)
                                let screenCenter = UIScreen.main.bounds.width / 2
                                let frameMidX = frame.midX
                                let distance = abs(frameMidX - screenCenter)
                                
                                // Magnification logic: the closer to center, the larger and sharper
                                let distanceDivisor: CGFloat = 120
                                let distanceRatio = distance / distanceDivisor
                                let scaleValue = 1.4 - distanceRatio
                                let scale = max(1.0, scaleValue)
                                
                                let blurDistance = distance - 40
                                let blurDivisor: CGFloat = 40
                                let blurRatio = blurDistance / blurDivisor
                                let blur = max(0, blurRatio)
                                
                                let scaleDiff = scale - 1.0
                                let scaleOffset = scaleDiff * -8
                                
                                let scaledContent = content.scaleEffect(scale)
                                let offsetContent = scaledContent.offset(y: scaleOffset)
                                let blurredContent = offsetContent.blur(radius: blur)
                                
                                return blurredContent
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.horizontal, contentMargin, for: .scrollContent)
                .scrollPosition(id: $scrollPosition, anchor: .center)
                .scrollTargetBehavior(.viewAligned) // Se alinea a valores pero permite inercia
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(.hidden)
                // La inercia natural del ScrollView ya está presente
                // El swipe rápido moverá más lejos, el lento será más preciso
                .onAppear {
                    if scrollPosition == nil {
                        scrollPosition = selectedValue
                    }
                }
                
                // Loupe (Lupa) Indicator - Fixed in center, ABOVE the scroll
                loupeView(
                    minWidth: loupeMinWidth,
                    idealWidth: loupeIdealWidth,
                    maxWidth: loupeMaxWidth,
                    height: loupeHeight
                )
            }
            .onAppear {
                scrollPosition = selectedValue
            }
            .onChange(of: scrollPosition) { _, newValue in
                if let newValue, selectedValue != newValue {
                    // Haptic feedback
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    
                    selectedValue = newValue
                    onValueChanged?(newValue)
                }
            }
            .onChange(of: selectedValue) { _, newValue in
                if scrollPosition != newValue {
                    // Animar el scroll cuando el valor cambia desde fuera (ej: drag del PrecisableInput)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        scrollPosition = newValue
                    }
                }
            }
    }
    
    // MARK: - Private Helpers
    
    @ViewBuilder
    private func loupeView(minWidth: CGFloat, idealWidth: CGFloat, maxWidth: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Glass Texture with Material
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(loupeBorder)
            
            // Main Blue Border with Glow
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.blue, lineWidth: 3)
                .shadow(color: .blue.opacity(0.4), radius: 8)
        }
        .frame(minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth)
        .overlay(loupeLabel)
        .allowsHitTesting(false)
        .zIndex(2)
    }
    
    private var loupeBorder: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(
                LinearGradient(
                    colors: [.white.opacity(0.6), .white.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
    }
    
    private var loupeLabel: some View {
        Text(formatter(selectedValue))
            .font(.system(size: 30, weight: .black))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.5), radius: 2)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 4)
    }
}

// MARK: - Convenience Initializers

extension FMSetter where Value == Int {
    public init(
        range: ClosedRange<Int>,
        selectedValue: Binding<Int>,
        onValueChanged: ((Int) -> Void)? = nil
    ) {
        self.values = Array(range)
        self._selectedValue = selectedValue
        self.formatter = { "\($0)" }
        self.onValueChanged = onValueChanged
    }
}

extension FMSetter where Value == Double {
    public init(
        range: ClosedRange<Double>,
        step: Double,
        selectedValue: Binding<Double>,
        formatter: @escaping (Double) -> String = { String(format: "%.1f", $0) },
        onValueChanged: ((Double) -> Void)? = nil
    ) {
        var values: [Double] = []
        var current = range.lowerBound
        while current <= range.upperBound {
            values.append(current)
            current += step
        }
        self.values = values
        self._selectedValue = selectedValue
        self.formatter = formatter
        self.onValueChanged = onValueChanged
    }
}

