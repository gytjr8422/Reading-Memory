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
    var widthRatio: CGFloat
    var lineLimit: Int
    @Binding var isLineLimit: Bool

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.textAlignment = NSTextAlignment(rawValue: textAlignmentStyle.rawValue)!
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * widthRatio).isActive = true
        label.layoutIfNeeded()
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
        uiView.numberOfLines = isLineLimit ? lineLimit : 0
        uiView.font = font
        uiView.setLineSpacing(lineSpacing: 5)
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.layoutIfNeeded()
    }
    
}

enum TextAlignmentStyle : Int {
    case left = 0, center = 1, right = 2, justified = 3, natural = 4
}

