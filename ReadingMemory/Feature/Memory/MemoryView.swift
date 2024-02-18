//
//  MemoryView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/9/24.
//

import RealmSwift
import SwiftUI

enum MemoryCategory: Int, CaseIterable, Identifiable {
    case sentence
    case word
    case thought
    
    var title: String {
        switch self {
        case .sentence: return "문장"
        case .word: return "단어"
        case .thought: return "생각"
        }
    }
    
    var id: Int { return self.rawValue }
}

struct MemoryView: View {
    @ObservedResults(Book.self) private var savedBooks
    
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var animation
    @EnvironmentObject private var router: Router
    
    @State private var selectedSegment: MemoryCategory = .sentence
    @State private var editButtonFilter: MemoryCategory = .sentence
    @State private var offset: CGSize = CGSize()
    @State private var isShowingEditSheet: Bool = false
    @State private var editorMode: EditorMode = .add
    @State private var memoryId: ObjectId?
    
    let book: Book
    
    var body: some View {
        ZStack {
            VStack {
                headerFilterView
                ScrollView {
                    LazyVStack {
                        switch selectedSegment {
                        case .sentence:
                            ForEach(savedBooks.filter("isbn == %@", book.isbn)[0].sentences, id: \.self) { sentence in
                                Button {
                                    router.libraryRoutes.append(.memoryDetail(sentence, .sentence))
                                } label: {
                                    MemoryCell(anyMemory: sentence, category: .sentence)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 5)
                                }
                            }
                        case .word: 
                            ForEach(savedBooks.filter("isbn == %@", book.isbn)[0].words, id: \.self) { word in
                                MemoryCell(anyMemory: word, category: .word)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 5)
                            }
                        case .thought:
                            ForEach(savedBooks.filter("isbn == %@", book.isbn)[0].thoughts, id: \.self) { thought in
                                MemoryCell(anyMemory: thought, category: .thought)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.offset = gesture.translation
                        }
                        .onEnded { gesture in
                            withAnimation(.interactiveSpring(response: 0.5)) {
                                if gesture.translation.width < -100 {
                                    switch selectedSegment {
                                    case .sentence:
                                        selectedSegment = .word
                                    case .word:
                                        selectedSegment = .thought
                                    case .thought:
                                        break
                                    }
                                } else if gesture.translation.width > 100 {
                                    switch selectedSegment {
                                    case .sentence:
                                        break
                                    case .word:
                                        selectedSegment = .sentence
                                    case .thought:
                                        selectedSegment = .word
                                    }
                                }
                            }
                            self.offset = CGSize()
                        }
                )
            }
            
            addButton
            
        }
        .navigationTitle(book.title)
        .background(colorScheme == .light ? .white : Color.BackgroundBlue)
        .fullScreenCover(isPresented: $isShowingEditSheet, content: {
            MemoryEditorView(
                isShowingEditSheet: $isShowingEditSheet,
                book: book,
                editCategory: editButtonFilter,
                editorMode: .add,
                memoryId: memoryId
            )
        })
    }

    private var headerFilterView: some View {
        HStack(spacing: 0) {
            ForEach(MemoryCategory.allCases, id: \.self) { segment in
                VStack {
                    Text(segment.title)
                        .foregroundColor(selectedSegment == segment ? colorScheme == .light ? Color.BackgroundBlue : .white : colorScheme == .light ? .black : .white)
                    ZStack {
                        Divider()
                        Capsule()
                            .fill(Color.clear)
                            .frame(height: 4)
                        if selectedSegment == segment {
                            Capsule()
                                .fill(Color(hexCode: "234E70"))
                                .frame(height: 4)
                                .matchedGeometryEffect(id: "item", in: animation)
                        }
                    }
                }
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.5)) {
                        selectedSegment = segment
                    }
                }
            }
        }
    }
    
    private var addButton: some View {
        Menu("\(Image(systemName: "plus.circle.fill"))") {
            Button("생각", action: {
                editButtonFilter = .thought
                editorMode = .add
                memoryId = nil
                isShowingEditSheet = true
            })
            Button("단어", action: {
                editButtonFilter = .word
                editorMode = .add
                memoryId = nil
                isShowingEditSheet = true
            })
            Button("문장", action: {
                editButtonFilter = .sentence
                editorMode = .add
                memoryId = nil
                isShowingEditSheet = true
            })
        }
        .foregroundColor(colorScheme == .light ? Color.BackgroundBlue : Color(hexCode: "DCE2F0"))
        .font(.system(size: UIScreen.main.bounds.width * 0.13))
        .offset(x: UIScreen.main.bounds.width * 0.35, y: UIScreen.main.bounds.height * 0.3)
    }
}



#Preview {
    NavigationStack {
        MemoryView(book: Book.dummyBook)
            .navigationBarTitleDisplayMode(.inline)
    }
}
