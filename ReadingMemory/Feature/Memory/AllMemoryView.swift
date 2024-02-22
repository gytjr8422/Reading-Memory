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
    
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        NavigationStack(path: $router.memoryRoutes) {
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
            .background(colorScheme == .light ? .white : Color.BackgroundBlue)
            .navigationDestination(for: MemoryRoute.self) { route in
                switch route {
                case .memoryDetail(let memory, let memoryCategory):
                    MemoryDetailView(anyMemory: memory, category: selectedSegment)
                }
            }
        }
        .accentColor(colorScheme == .light ? .black : .white)
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
    
    private var memoryCardView: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                switch selectedSegment {
                case .sentence:
                    let sortedSentences = sentences.sorted(by: [
                        SortDescriptor(keyPath: "liked", ascending: false),
                        SortDescriptor(keyPath: "editDate", ascending: false)
                    ])
                    ForEach(sortedSentences, id: \.id) { sentence in
                        Button {
                            router.memoryRoutes.append(.memoryDetail(sentence, .sentence))
                        } label: {
                            MemoryCell(anyMemory: sentence, category: .sentence)
                                .padding(.vertical, 5)
                        }
                    }
                case .word:
                    let sortedWords = words.sorted(by: [
                        SortDescriptor(keyPath: "liked", ascending: false),
                        SortDescriptor(keyPath: "editDate", ascending: false)
                    ])
                    ForEach(sortedWords, id: \.id) { word in
                        Button {
                            router.memoryRoutes.append(.memoryDetail(word, .word))
                        } label: {
                            MemoryCell(anyMemory: word, category: .word)
                                .padding(.vertical, 5)
                        }
                    }
                case .thought:
                    let sortedthoughts = thoughts.sorted(by: [
                        SortDescriptor(keyPath: "liked", ascending: false),
                        SortDescriptor(keyPath: "editDate", ascending: false)
                    ])
                    ForEach(sortedthoughts, id: \.id) { thought in
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
}

#Preview {
    AllMemoryView()
        .environmentObject(Router())
}
