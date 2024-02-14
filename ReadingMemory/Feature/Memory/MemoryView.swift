//
//  MemoryView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/9/24.
//

import SwiftUI

enum MemoryFilter: Int, CaseIterable, Identifiable {
    case sentence
    case word
    case idea
    
    var title: String {
        switch self {
        case .sentence: return "문장"
        case .word: return "단어"
        case .idea: return "생각"
        }
    }
    
    var id: Int { return self.rawValue }
}

struct MemoryView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var animation
    
    @State private var selectedSegment: MemoryFilter = .sentence
    @State private var editButtonFilter: MemoryFilter = .sentence
    @State private var offset: CGSize = CGSize()
    @State private var isShowingEditSheet: Bool = false
    
    let book: Book
    
    var body: some View {
        ZStack {
            VStack {
                headerFilterView
                ScrollView {
                    LazyVStack {
                        switch selectedSegment {
                        case .sentence:
                            Text("문장")
                        case .word:
                            Text("단어")
                        case .idea:
                            Text("생각")
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
                                        selectedSegment = .idea
                                    case .idea:
                                        break
                                    }
                                } else if gesture.translation.width > 100 {
                                    switch selectedSegment {
                                    case .sentence:
                                        break
                                    case .word:
                                        selectedSegment = .sentence
                                    case .idea:
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
            MemoryEditorView()
        })
    }

    private var headerFilterView: some View {
        HStack(spacing: 0) {
            ForEach(MemoryFilter.allCases, id: \.self) { segment in
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
                isShowingEditSheet = true
            })
            Button("단어", action: {
                isShowingEditSheet = true
            })
            Button("문장", action: {
                isShowingEditSheet = true
                editButtonFilter = .sentence
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
