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
    var width: CGFloat
    var lineLimit: Int
    @Binding var isLineLimit: Bool

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
                label.textAlignment = NSTextAlignment(rawValue: textAlignmentStyle.rawValue)!
        label.preferredMaxLayoutWidth = width
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.widthAnchor.constraint(equalToConstant: width).isActive = true
//        if let superview = label.superview {
//            label.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 10).isActive = true
//            label.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 10).isActive = true
//        }
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

