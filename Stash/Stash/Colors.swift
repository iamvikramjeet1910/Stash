//
//  Colors.swift
//  Stash
//
//  Created by Vikram Kumar on 09/06/26.
//

import UIKit

enum CrystalColor {

    // MARK: - Transparent

    case clear

    // MARK: - Whites
    case crystalWhite
    case frostWhite
    case silverWhite
    case pearlWhite
    case smokeWhite

    // MARK: - Blacks

    case crystalBlack
    case obsidianBlack
    case graphiteBlack
    case charcoalBlack
    case midnightBlack

    // MARK: - Grays

    case platinumGray
    case titaniumGray
    case slateGray
    case ashGray
    case disabledGray
    case crystalGray
    
    case frostedGlass

    // MARK: - Utility

    case separator
    case overlay
    
    case crystalSilver

    var color: UIColor {

        switch self {

        // MARK: Transparent

        case .clear:
            return .clear

        // MARK: Whites

        case .crystalWhite:
            return UIColor(hex: "#FFFFFF")

        case .frostWhite:
            return UIColor(hex: "#F5F5F7")

        case .silverWhite:
            return UIColor(hex: "#ECECEC")

        case .pearlWhite:
            return UIColor(hex: "#FAFAFA")

        case .smokeWhite:
            return UIColor(hex: "#E5E5EA")

        // MARK: Blacks

        case .crystalBlack:
            return UIColor(hex: "#000000")

        case .obsidianBlack:
            return UIColor(hex: "#121212")

        case .graphiteBlack:
            return UIColor(hex: "#2C2C2E")

        case .charcoalBlack:
            return UIColor(hex: "#1C1C1E")

        case .midnightBlack:
            return UIColor(hex: "#0A0A0A")

        // MARK: Grays

        case .platinumGray:
            return UIColor(hex: "#D1D1D6")

        case .titaniumGray:
            return UIColor(hex: "#C7C7CC")

        case .slateGray:
            return UIColor(hex: "#8E8E93")

        case .ashGray:
            return UIColor(hex: "#636366")

        case .disabledGray:
            return UIColor(hex: "#48484A")
            
        case .crystalGray:
            return UIColor(hex: "#F2F2F7")
            
        case .frostedGlass:
            return UIColor(hex: "#EFEFF4")

        // MARK: Utility

        case .separator:
            return UIColor(hex: "#3A3A3C")

        case .overlay:
            return UIColor.black.withAlphaComponent(0.4)
            
        case .crystalSilver:
            return UIColor(hex: "#DADADC")
        }
    }
}

// MARK: - UIColor + Hex

extension UIColor {

    convenience init(hex: String) {

        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64

        switch hex.count {

        case 6:
            (r, g, b) = (
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )

        default:
            (r, g, b) = (0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
}
