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

// MARK: - StashTheme (adaptive light / dark colors)

enum StashTheme {

    /// App-wide background — obsidian in dark, frost-white in light
    static let appBackground = UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.07, blue: 0.10, alpha: 1)
            : CrystalColor.frostWhite.color
    }

    /// Header / status-bar surface — elevated above the content background
    static let headerBackground = UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.15, alpha: 1)
            : UIColor.white
    }

    /// 1 pt separator at the bottom edge of the header
    static let headerSeparator = UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.separator
    }

    /// Floating card surface
    static let cardSurface = UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.05)
            : UIColor.white
    }

    /// Card outline border
    static let cardBorder = UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.15)
            : UIColor.black.withAlphaComponent(0.08)
    }

    /// Thin separator between image and title inside a card
    static let cardSeparator = UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.12)
            : UIColor.separator
    }

    /// Floating tab bar pill surface
    static let tabBarPill = UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 0.97)
            : UIColor.white
    }

    /// Inline search bar container background
    static let searchBarBackground = UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.12)
            : UIColor.black.withAlphaComponent(0.07)
    }

    /// Tab item selected background
    static let tabSelectedBg = UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? CrystalColor.crystalSilver.color
            : CrystalColor.graphiteBlack.color
    }

    /// Tab item selected icon/label foreground
    static let tabSelectedFg = UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? CrystalColor.crystalBlack.color
            : CrystalColor.crystalWhite.color
    }

    /// Tab item unselected icon/label foreground
    static let tabUnselectedFg = UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? CrystalColor.crystalWhite.color
            : CrystalColor.graphiteBlack.color
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
