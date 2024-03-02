//
//  AllMemoryView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/22/24.
//

import RealmSwift
import SwiftUI

struct AllMemoryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var router: Router
    
    @ObservedResults(Sentence.self) private var sentences
    @ObservedResults(Word.self) private var words
    @ObservedResults(Thought.self) private var thoughts
    
    @Namespace private var animation
    
    @State private var selectedSegment: MemoryCategory = .sentence
    @State private var offset: CGSize = CGSize()
    @State private var searchText: String = ""
    
    @State private var isEditing: Bool = false
    @State private var selectedMemories: [Memory] = []
    @State private var isShwoingDeleteAlert: Bool = false
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    private var searchedSentences: [Sentence] {
        if searchText.isEmpty {
            return Array(sentences)
        } else {
            return sentences.filter { $0.sentence.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private var searchedWords: [Word] {
        if searchText.isEmpty {
            return Array(words)
        } else {
            return words.filter { $0.word.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private var searchedThoughts: [Thought] {
        if searchText.isEmpty {
            return Array(thoughts)
        } else {
            return thoughts.filter { $0.thought.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $router.memoryRoutes) {
                VStack {
                    headerFilterView
                    ScrollView {
                        searchBar(geometry)
                        Divider()
                        editButtons(geometry)
                        Divider()
                        memoryCardView(geometry)
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
                .background(colorScheme == .light ? .white : Color.backgroundBlue)
                .navigationDestination(for: MemoryRoute.self) { route in
                    switch route {
                    case .memoryDetail(let memory, let memoryCategory):
                        MemoryDetailView(anyMemory: memory, category: memoryCategory)
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
            .tint(colorScheme == .light ? .black : .white)
            .scrollDismissesKeyboard(.immediately)
        }
    }
    
    private func searchBar(_ geometry: GeometryProxy) -> some View {
        RMTextField(
            text: $searchText,
            isWrongText: false,
            isTextfieldDisabled: false,
            placeholderText: "기억을 검색해보세요.",
            isSearchBar: true
        )
        .frame(width: geometry.size.width * 0.9)
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
        .padding(.top)
    }
    
    private func editButtons(_ geometry: GeometryProxy) -> some View {
        HStack {
            if !isEditing {
                Button {
                    isEditing = true
                } label: {
                    Text("편집")
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.06)
                        .foregroundStyle(colorScheme == .light ? .white : .black)
                        .background(colorScheme == .light ? Color.cellBackgroud : .white)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }

            } else {
                Button {
                    isEditing = false
                    selectedMemories.removeAll()
                } label: {
                    Text("취소")
                        .frame(width: geometry.size.width * 0.44, height: geometry.size.height * 0.06)
                        .foregroundStyle(colorScheme == .light ? .white : .black)
                        .background(colorScheme == .light ? Color.cellBackgroud : .white)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                
                Button {
                    if !selectedMemories.isEmpty {
                        isShwoingDeleteAlert = true
                    }
                } label: {
                    Text("삭제")
                        .frame(width: geometry.size.width * 0.44, height: geometry.size.height * 0.06)
                        .foregroundStyle(.white)
                        .background(.red)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }

            }
        }
    }
    
    private func memoryCardView(_ geometry: GeometryProxy) -> some View {
            LazyVGrid(columns: columns) {
                switch selectedSegment {
                case .sentence:
                    let sortedSentences = searchedSentences.sorted { (s1, s2) -> Bool in
                        if s1.liked != s2.liked {
                            return s1.liked
                        }
                        return s1.editDate > s2.editDate
                    }
                    ForEach(sortedSentences, id: \.id) { sentence in
                        Button {
                            router.memoryRoutes.append(.memoryDetail(sentence, .sentence))
                        } label: {
                            MemoryCell(anyMemory: sentence, category: .sentence, route: .memoryRoute, geometrySize: geometry.size)
                                .padding(.vertical, 5)
                        }
                        .disabled(isEditing)
                        .overlay {
                            editButton(sentence, geometry)
                        }
                    }
                case .word:
                    let sortedWords = searchedWords.sorted { (s1, s2) -> Bool in
                        if s1.liked != s2.liked {
                            return s1.liked
                        }
                        return s1.editDate > s2.editDate
                    }
                    ForEach(sortedWords, id: \.id) { word in
                        Button {
                            router.memoryRoutes.append(.memoryDetail(word, .word))
                        } label: {
                            MemoryCell(anyMemory: word, category: .word, route: .memoryRoute, geometrySize: geometry.size)
                                .padding(.vertical, 5)
                        }
                        .disabled(isEditing)
                        .overlay {
                            editButton(word, geometry)
                        }
                    }
                case .thought:
                    let sortedThoughts = searchedThoughts.sorted { (s1, s2) -> Bool in
                        if s1.liked != s2.liked {
                            return s1.liked
                        }
                        return s1.editDate > s2.editDate
                    }
                    ForEach(sortedThoughts, id: \.id) { thought in
                        Button {
                            router.memoryRoutes.append(.memoryDetail(thought, .thought))
                        } label: {
                            MemoryCell(anyMemory: thought, category: .thought, route: .memoryRoute, geometrySize: geometry.size)
                                .padding(.vertical, 5)
                        }
                        .disabled(isEditing)
                        .overlay {
                            editButton(thought, geometry)
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    private func editButton(_ memory: Memory, _ geometry: GeometryProxy) -> some View {
        if isEditing {
            if selectedMemories.contains(where: { $0.id == memory.id }) {
                Image(systemName: "checkmark.circle")
                    .frame(width: geometry.size.width * 0.43, height: geometry.size.width * 0.45)
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
                    .frame(width: geometry.size.width * 0.43, height: geometry.size.width * 0.45)
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
    AllMemoryView()
        .environmentObject(Router())
}
