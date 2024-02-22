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
    @ObservedResults(Book.self) private var savedBooks
    @ObservedResults(Sentence.self) private var sentences
    @ObservedResults(Word.self) private var words
    @ObservedResults(Thought.self) private var thoughts
    
    @State private var isShowingEditorSheet: Bool = false
    @State private var memoryId: ObjectId = ObjectId()
    @State private var bookTitle: String = ""
    
    let anyMemory: T
    let category: MemoryCategory
    
    var body: some View {
        ScrollView {
            memoryView
        }
        .background(colorScheme == .light ? .white : Color.BackgroundBlue)
        .navigationTitle(bookTitle)
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
                if let sentence = anyMemory as? Sentence {
                    memoryId = sentence.id
                    if let title = savedBooks.filter("isbn == %@", sentence.isbn).first?.title {
                        bookTitle = title
                    }
                }
            case .word:
                if let word = anyMemory as? Word {
                    memoryId = word.id
                    if let title = savedBooks.filter("isbn == %@", word.isbn).first?.title {
                        bookTitle = title
                    }
                }
            case .thought:
                if let thought = anyMemory as? Thought {
                    memoryId = thought.id
                    if let title = savedBooks.filter("isbn == %@", thought.isbn).first?.title {
                        bookTitle = title
                    }
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
                    if let memory = anyMemory as? Sentence, let sentence = sentences.filter("id == %@", memory.id).first {
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
                        
                        if sentence.sentence.count > 0 {
                            makeTextView(sentence.sentence)
                        }
                        
                        HStack {
                            Text("내 생각")
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        
                        if sentence.idea.count > 0 {
                            makeTextView(sentence.idea)
                        } else {
                            Text("문장에 대한 생각을 적어보세요.")
                                .font(.subheadline)
                        }
                    }
                    
                case .word:
                    if let memory = anyMemory as? Word, let word = words.filter("id == %@", memory.id).first {
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
                    if let memory = anyMemory as? Thought, let thought = thoughts.filter("id == %@", memory.id).first {
                        HStack {
                            Text("내 생각")
                                .font(.title3)
                                .bold()
                            
                            if thought.page.count > 0 {
                                Text("p.\(thought.page)")
                            }
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        
                        makeTextView(thought.thought)
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
                .overlay {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(lineWidth: 1)
                }
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
