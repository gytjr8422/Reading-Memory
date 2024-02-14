//
//  Color+Extensions.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/12/24.
//

import SwiftUI

// MARK: - Convenience Initializers
extension Color {
    public init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0
        )
    }
    
    public init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF
        )
    }
    
    init(hexCode: String) {
        var formattedHex = hexCode.trimmingCharacters(in: .whitespacesAndNewlines)
        formattedHex = formattedHex.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: formattedHex).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

public extension Color {
    
    var uiColor: UIColor {
        UIColor(self)
    }
    
    static var BackgroundBlue: Color {
        return .init(hexCode: "101820")
    }
    
    static var FontBackgroundDark: Color {
        return .init(hexCode: "8AB0AB")
    }
    
    static var FontBackgroundLight: Color {
        return .init(hexCode: "3E505B")
    }
    
    static var Main: Color {
        return .init(hexCode: "#25C578")
    }
    
    static var Sub: Color {
        return .init(hexCode: "#FF7E00")
    }
    
    
    
    static var LightGray1: Color {
        return .init(hexCode: "#ECECEC")
    }
    
    static var LightGray2: Color {
        return .init(hexCode: "#D4D4D4")
    }
    
    static var DarkGray1: Color {
        return .init(hexCode: "#666666")
    }
    
    static var DarkGray2: Color {
        return .init(hexCode: "#404040")
    }
    
    static var Black: Color {
        return .init(hexCode: "#1C1C1C")
    }
    
    
    
    static var Error: Color {
        return .init(hexCode: "#F05650")
    }
}
