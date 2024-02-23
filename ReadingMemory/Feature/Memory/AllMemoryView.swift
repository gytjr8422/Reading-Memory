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
        NavigationStack(path: $router.memoryRoutes) {
            VStack {
                headerFilterView
                ScrollView {
                    searchBar
                    memoryCardView
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
            .background(colorScheme == .light ? .white : Color.BackgroundBlue)
            .navigationDestination(for: MemoryRoute.self) { route in
                switch route {
                case .memoryDetail(let memory, let memoryCategory):
                    MemoryDetailView(anyMemory: memory, category: memoryCategory)
                }
            }
        }
        .accentColor(colorScheme == .light ? .black : .white)
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var searchBar: some View {
        RMTextField(text: $searchText, isWrongText: false, isTextfieldDisabled: false, placeholderText: "기억을 검색해보세요.", isSearchBar: true)
            .frame(width: UIScreen.main.bounds.width * 0.9)
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
        .padding(.top)
    }
    
    private var memoryCardView: some View {
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
                            MemoryCell(anyMemory: sentence, category: .sentence)
                                .padding(.vertical, 5)
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
                            MemoryCell(anyMemory: word, category: .word)
                                .padding(.vertical, 5)
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
                            MemoryCell(anyMemory: thought, category: .thought)
                                .padding(.vertical, 5)
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
    }
}

#Preview {
    AllMemoryView()
        .environmentObject(Router())
}
