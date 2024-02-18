//
//  MemoryDetailView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/18/24.
//

import RealmSwift
import SwiftUI

struct MemoryDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedResults(Sentence.self) private var savedSentences
    
    let anyMemory: Object
    let category: MemoryCategory
    
    var body: some View {
        ScrollView {
            memoryView
        }
        .background(colorScheme == .light ? .white : Color.BackgroundBlue)
    }
    
    private var memoryView: some View {
        HStack {
            VStack {
                switch category {
                case .sentence:
                    let sentence = anyMemory as? Sentence
                    HStack {
                        Text("문장")
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    if let sentence {
                        let memory = savedSentences.filter("id == %@", sentence.id)[0]
                        if memory.sentence.count > 0 {
                            makeTextView(memory.sentence)
                        }
                    }
                    
                    HStack {
                        Text("내 생각")
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    if let sentence {
                        let memory = savedSentences.filter("id == %@", sentence.id)[0]
                        if memory.idea.count > 0 {
                            makeTextView(memory.idea)
                        }
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
        }
//        .frame(width: UIScreen.main.bounds.width)
    }
    
    private func makeTextView(_ text: String) -> some View {
        VStack {
            HStack {
                TextAlignment(text: text, textAlignmentStyle: .justified, font: .systemFont(ofSize: 15), width: UIScreen.main.bounds.width * 0.8, lineLimit: 0, isLineLimit: .constant(false))
                .padding(20)
                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(hexCode: "50586C"))
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .foregroundStyle(colorScheme == .light ? Color(hexCode: "50586C") : Color(hexCode: "DCE2F0"))
        .padding(.bottom, 10)
    }
}

#Preview {
    MemoryDetailView(anyMemory: Book.dummyBook.sentences[0], category: .sentence)
}
