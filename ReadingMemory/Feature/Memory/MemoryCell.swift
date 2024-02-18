//
//  MemoryCell.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/12/24.
//

import RealmSwift
import SwiftUI

struct MemoryCell: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let anyMemory: Object
    let category: MemoryCategory
    
    var body: some View {
        VStack(alignment: .leading) {
            switch category {
            case .sentence:
                let sentence = anyMemory as? Sentence
                if let sentence {
                    Group {
                        Text("문장")
                        Text(sentence.sentence)
                            .lineLimit(2)
                        Divider()
                            .background(colorScheme == .light ? Color(hexCode: "50586C") : Color(hexCode: "DCE2F0"))
                        Text("내 생각")
                        Text(sentence.idea)
                            .lineLimit(2)
                    }
                    .font(.callout)
                }
            case .word:
                let word = anyMemory as? Word
                if let word {
                    Text("단어: \(word.word)")
                }
            case .thought:
                let idea = anyMemory as? Thought
                if let idea {
                    Text("내 생각: \(idea.thought)")
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color(hexCode: "50586C"))
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .foregroundStyle(colorScheme == .light ? Color(hexCode: "50586C") : Color(hexCode: "DCE2F0"))
    }
}

#Preview {
    MemoryCell(anyMemory: Sentence(value: [
        "sentence": "Hello Sentence",
        "idea": "My Idea",
        "addDate": Date(),
        "editDate": Date()
    ]), category: .sentence)
}
