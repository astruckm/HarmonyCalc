//
//  ChordSymbolFormatter.swift
//  HarmonyCalc
//
//  Created by ASM on 10/3/26.
//  Copyright © 2026 ASM. All rights reserved.
//

import Foundation

/// A notational convention for chord symbols. Raw values are stable so the choice can be persisted.
enum ChordSymbolStyle: String, CaseIterable {
    /// Spelled-out qualities, e.g. `Cmaj7`, `Cm7`, `CmMaj7`.
    case standard
    /// Jazz shorthand, e.g. `CΔ7`, `C−7`, `C−Δ7`.
    case symbolic
}

/// The single place chord-symbol text is built. Every chord symbol shown to the user goes through `symbol(for:style:)`.
enum ChordSymbolFormatter {

    static func symbol(for candidate: ChordCandidate, style: ChordSymbolStyle = .standard) -> String {
        return candidate.rootSpelling + quality(candidate.quality, style: style)
    }

    /// Rewrites a standard-style quality (as produced by `HarmonyModel`) into `style`.
    static func quality(_ standardQuality: String, style: ChordSymbolStyle) -> String {
        switch style {
        case .standard:
            return standardQuality
        case .symbolic:
            var quality = standardQuality
                .replacingOccurrences(of: "Maj", with: "Δ")
                .replacingOccurrences(of: "maj", with: "Δ")
            // Any remaining leading "m" is the minor third.
            if quality.hasPrefix("m") {
                quality = "−" + quality.dropFirst()
            }
            return quality
        }
    }
}
