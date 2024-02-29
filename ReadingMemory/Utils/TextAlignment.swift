//
//  TextAlignment.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/23/24.
//

import SwiftUI

struct TextAlignment: UIViewRepresentable {
    var text: String
    var textAlignmentStyle: TextAlignmentStyle
    var font: UIFont
//    var width: CGFloat
    var lineLimit: Int
    @Binding var isLineLimit: Bool

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.textAlignment = NSTextAlignment(rawValue: textAlignmentStyle.rawValue)!
        label.preferredMaxLayoutWidth = UIScreen.main.bounds.width * 0.85
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
        uiView.numberOfLines = isLineLimit ? lineLimit : 0
        uiView.font = font
        uiView.setLineSpacing(lineSpacing: 5)
    }
    
}

enum TextAlignmentStyle : Int {
    case left = 0, center = 1, right = 2, justified = 3, natural = 4
}

