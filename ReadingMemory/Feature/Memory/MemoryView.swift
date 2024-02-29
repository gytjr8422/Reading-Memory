//
//  MemoryView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/9/24.
//

import RealmSwift
import SwiftUI

struct MemoryView: View {
    @ObservedResults(Book.self) private var savedBooks
    
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var animation
    @EnvironmentObject private var router: Router
    
    @State private var selectedSegment: MemoryCategory = .sentence
    @State private var offset: CGSize = CGSize()
    
    @State private var isShowingEditSheet: Bool = false
    @State private var isMemoryListEditing: Bool = false
    
    @State private var editorMode: EditorMode = .add
    @State private var memoryId: ObjectId?
    
    @State private var selectedMemories: [Memory] = []
    @State private var isShwoingDeleteAlert: Bool = false
    
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    let book: Book
    
    var body: some View {
        ZStack {
            VStack {
                headerFilterView
                memoryCardView
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
        .background(colorScheme == .light ? .white : Color.backgroundBlue)
        .fullScreenCover(isPresented: $isShowingEditSheet, content: {
            MemoryEditorView(
                firstText: "",
                secondText: "",
                isShowingEditSheet: $isShowingEditSheet,
                book: book,
                editCategory: selectedSegment,
                editorMode: .add,
                memoryId: memoryId
            )
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        isMemoryListEditing.toggle()
                        selectedMemories.removeAll()
                    } label: {
                        isMemoryListEditing ? Text("취소") : Text("편집")
                    }
                    
                    if isMemoryListEditing {
                        Button {
                            if !selectedMemories.isEmpty {
                                isShwoingDeleteAlert = true
                            }
                        } label: {
                            Text("삭제")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .alert("\(selectedMemories.count)개의 기억을 삭제하시겠습니까?", isPresented: $isShwoingDeleteAlert, actions: {
            Button("삭제", role: .destructive) {
                Book.deleteMemories(selectedMemories)
            }
            Button("취소", role: .cancel) { }
        }, message: {
            Text("기억 삭제 시 복구할 수 없습니다.")
        })
    }

    private var headerFilterView: some View {
        HStack(spacing: 0) {
            ForEach(MemoryCategory.allCases, id: \.self) { segment in
                VStack {
                    Text(segment.title)
                        .foregroundColor(selectedSegment == segment ? colorScheme == .light ? Color.backgroundBlue : .white : colorScheme == .light ? .black : .white)
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
    
    private var memoryCardView: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                switch selectedSegment {
                case .sentence:
                    if let sentences = savedBooks.filter("isbn == %@", book.isbn).first?.sentences.sorted(by: [
                        SortDescriptor(keyPath: "liked", ascending: false), // liked 속성이 true인 것이 먼저 오도록 내림차순 정렬
                        SortDescriptor(keyPath: "editDate", ascending: false) // addDate를 기준으로 최신순으로 내림차순 정렬
                    ]) {
                        ForEach(sentences, id: \.self) { sentence in
                            Button {
                                router.libraryRoutes.append(.memoryDetail(sentence, .sentence))
                            } label: {
                                MemoryCell(anyMemory: sentence, category: .sentence, route: .libraryRoute)
                                    .padding(.vertical, 5)
                            }
                            .disabled(isMemoryListEditing)
                            .overlay {
                                editButton(sentence)
                            }
                        }
                    }
                    
                case .word:
                    if let words = savedBooks.filter("isbn == %@", book.isbn).first?.words.sorted(by: [
                        SortDescriptor(keyPath: "liked", ascending: false),
                        SortDescriptor(keyPath: "editDate", ascending: false)
                    ]) {
                        ForEach(words, id: \.self) { word in
                            Button {
                                router.libraryRoutes.append(.memoryDetail(word, .word))
                            } label: {
                                MemoryCell(anyMemory: word, category: .word, route: .libraryRoute)
                                    .padding(.vertical, 5)
                            }
                            .disabled(isMemoryListEditing)
                            .overlay {
                                editButton(word)
                            }
                        }
                    }
                case .thought:
                    if let thoughts = savedBooks.filter("isbn == %@", book.isbn).first?.thoughts.sorted(by: [
                        SortDescriptor(keyPath: "liked", ascending: false),
                        SortDescriptor(keyPath: "editDate", ascending: false)
                    ]) {
                        ForEach(thoughts, id: \.self) { thought in
                            Button {
                                router.libraryRoutes.append(.memoryDetail(thought, .thought))
                            } label: {
                                MemoryCell(anyMemory: thought, category: .thought, route: .libraryRoute)
                                    .padding(.vertical, 5)
                            }
                            .disabled(isMemoryListEditing)
                            .overlay {
                                editButton(thought)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
        }
    }
    
    private var addButton: some View {
        Button {
            editorMode = .add
            memoryId = nil
            isShowingEditSheet = true
        } label: {
            Image(systemName: "plus.circle.fill")
            .foregroundColor(colorScheme == .light ? Color.backgroundBlue : Color(hexCode: "DCE2F0"))
            .font(.system(size: UIScreen.main.bounds.width * 0.13))
        }
        .offset(x: UIScreen.main.bounds.width * 0.35, y: UIScreen.main.bounds.height * 0.34)
    }
    
    @ViewBuilder
    private func editButton(_ memory: Memory) -> some View {
        if isMemoryListEditing {
            if selectedMemories.contains(where: { $0.id == memory.id }) {
                Image(systemName: "checkmark.circle")
                    .frame(width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.width * 0.45)
                    .background(Color.gray.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .font(.title)
                    .onTapGesture {
                        if let index = selectedMemories.firstIndex(where: { $0.id == memory.id }) {
                            selectedMemories.remove(at: index)
                        }
                    }
            } else {
                Image(systemName: "circle")
                    .frame(width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.width * 0.45)
                    .background(Color.gray.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .font(.title)
                    .onTapGesture {
                        selectedMemories.append(memory)
                    }
            }
        }
    }
}



#Preview {
    NavigationStack {
        MemoryView(book: Book.dummyBook)
            .navigationBarTitleDisplayMode(.inline)
    }
}
