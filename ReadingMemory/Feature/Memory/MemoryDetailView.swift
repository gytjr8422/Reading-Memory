//
//  MemoryDetailView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/18/24.
//

import RealmSwift
import SwiftUI

struct MemoryDetailView<T: Object>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedResults(Sentence.self) private var sentences
    @ObservedResults(Word.self) private var words
    @ObservedResults(Thought.self) private var thoughts
    
    @State private var isShowingEditorSheet: Bool = false
    @State private var memoryId: ObjectId = ObjectId()
    
    let anyMemory: T
    let category: MemoryCategory
    
    var body: some View {
        ScrollView {
            memoryView
        }
        .background(colorScheme == .light ? .white : Color.BackgroundBlue)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingEditorSheet = true
                } label: {
                    Text("수정")
                }

            }
        }
        .onAppear {
            switch category {
            case .sentence:
                let sentence = anyMemory as? Sentence
                if let id = sentence?.id {
                    memoryId = id
                }
            case .word:
                let word = anyMemory as? Word
                if let id = word?.id {
                    memoryId = id
                }
            case .thought:
                let thought = anyMemory as? Thought
                if let id = thought?.id {
                    memoryId = id
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingEditorSheet) {
            MemoryEditorView(isShowingEditSheet: $isShowingEditorSheet, book: nil, editCategory: category, editorMode: .modify, memoryId: memoryId)
        }
    }
    
    private var memoryView: some View {
        HStack {
            VStack {
                switch category {
                case .sentence:
                    let sentence = anyMemory as? Sentence
                    if let sentence {
                        HStack {
                            Text("문장")
                                .font(.title3)
                                .bold()
                            
                            if sentence.page.count > 0 {
                                Text("p.\(sentence.page)")
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        
                        let memory = sentences.filter("id == %@", sentence.id)[0]
                        if memory.sentence.count > 0 {
                            makeTextView(memory.sentence)
                        }
                        
                        HStack {
                            Text("내 생각")
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        
                        if memory.idea.count > 0 {
                            makeTextView(memory.idea)
                        } else {
                            Text("문장에 대한 생각을 적어보세요.")
                                .font(.subheadline)
                        }
                    }
                    
                case .word:
                    let memory = anyMemory as? Word
                    if let memory, let word = words.filter("id == %@", memory.id).first {
                        HStack {
                            Text("단어")
                                .font(.title3)
                                .bold()
                            
                            if word.page.count > 0 {
                                Text("p.\(word.page)")
                            }
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        
//                        let memory = words.filter("id == %@", memory.id)[0]
                        
                        makeTextView(word.word)
                        
                        HStack {
                            Text("뜻")
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        
                        makeTextView(word.meaning)
                        
                        HStack {
                            Text("나온 문장")
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        
                        if word.sentence.count > 0 {
                            makeTextView(word.sentence)
                        } else {
                            Text("단어가 나온 문장을 입력해보세요.")
                        }
                    }
                    
                case .thought:
                    let memory = anyMemory as? Thought
                    if let memory, let  thought = thoughts.filter("id == %@", memory.id).first {
                        Text("내 생각: \(thought.thought)")
                    }
                }
            }
        }
    }
    
    private func makeTextView(_ text: String) -> some View {
        VStack {
//            HStack {
                TextAlignment(
                    text: text,
                    textAlignmentStyle: .justified,
                    font: .systemFont(ofSize: 15),
                    width: UIScreen.main.bounds.width * 0.8,
                    lineLimit: 0,
                    isLineLimit: .constant(false)
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
//            }
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
