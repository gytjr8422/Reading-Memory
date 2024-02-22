//
//  MemoryCell.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/12/24.
//

import RealmSwift
import SwiftUI

struct MemoryCell<T: Memory>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let anyMemory: T
    let category: MemoryCategory
    
    var body: some View {
        VStack {
            switch category {
            case .sentence:
                let sentence = anyMemory as? Sentence
                if let sentence {
                    TextAlignment(text: sentence.sentence, textAlignmentStyle: .justified, font: .systemFont(ofSize: 15), width: UIScreen.main.bounds.width * 0.35, lineLimit: 5, isLineLimit: .constant(true))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    HStack(alignment: .bottom) {
                        Text(DateToString.toString(sentence.editDate))
                            .font(.caption)
                        
                        Spacer()
                        
                        Image(systemName: sentence.liked ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundStyle(.red)
                            .onTapGesture {
                                Book.likeMemory(memoryId: sentence.id, category: .sentence)
                            }
                    }
                }
            case .word:
                let word = anyMemory as? Word
                if let word {
                    VStack {
                        TextAlignment(text: word.word, textAlignmentStyle: .justified, font: .systemFont(ofSize: 15), width: UIScreen.main.bounds.width * 0.35, lineLimit: 5, isLineLimit: .constant(true))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                            .background(colorScheme == .light ? Color(hexCode: "50586C") : Color(hexCode: "DCE2F0"))
                        TextAlignment(text: word.meaning, textAlignmentStyle: .justified, font: .systemFont(ofSize: 15), width: UIScreen.main.bounds.width * 0.35, lineLimit: 5, isLineLimit: .constant(true))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        HStack(alignment: .bottom) {
                            Text(DateToString.toString(word.editDate))
                                .font(.caption)
                            Spacer()
                            Image(systemName: word.liked ? "heart.fill" : "heart")
                                .font(.title3)
                                .foregroundStyle(.red)
                                .onTapGesture {
                                    Book.likeMemory(memoryId: word.id, category: .word)
                                }
                        }
                    }
                }
            case .thought:
                let thought = anyMemory as? Thought
                if let thought {
                    TextAlignment(text: thought.thought, textAlignmentStyle: .justified, font: .systemFont(ofSize: 15), width: UIScreen.main.bounds.width * 0.35, lineLimit: 5, isLineLimit: .constant(true))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    HStack(alignment: .bottom) {
                        VStack {
                            Text(DateToString.toString(thought.editDate))
                                .font(.caption)
                        }
                        Spacer()
                        Image(systemName: thought.liked ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundStyle(.red)
                            .onTapGesture {
                                Book.likeMemory(memoryId: thought.id, category: .thought)
                            }
                    }
                    
                }
            }
        }
        .padding(15)
        .frame(width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.width * 0.45)
        .background(Color(hexCode: "50586C"))
        .clipped()
        .overlay {
            RoundedRectangle(cornerRadius: 7)
                .stroke(lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 7))
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
