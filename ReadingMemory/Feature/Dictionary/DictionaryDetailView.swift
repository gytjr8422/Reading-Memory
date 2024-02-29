//
//  DictionaryDetailView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/26/24.
//

import SwiftUI

struct DictionaryDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isShowingSelectBookSheet: Bool = false
    @State private var isShowingEditorSheet: Bool = false
    
    @State private var selectedBook: Book?
    
    let item: WordItem
    let route: Route
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                HStack {
                    Text("단어")
                        .font(.title3)
                        .bold()
                    
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                
                makeTextView(item.word, geometry)
                
                HStack {
                    Text("뜻")
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                
                if let sense = item.sense.first {
                    makeTextView(sense.definition, geometry)
                }
            }
            .background(colorScheme == .light ? .white : Color.backgroundBlue)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSelectBookSheet = true
                    } label: {
                        Text("저장")
                    }
                    
                }
            }
            .sheet(isPresented: $isShowingSelectBookSheet) {
                SelectBookView(selectedBook: $selectedBook, isShowingEditorSheet: $isShowingEditorSheet)
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: selectedBook, { oldValue, newValue in
                selectedBook = newValue
            })
            .fullScreenCover(isPresented: $isShowingEditorSheet) {
                if let sense = item.sense.first {
                    MemoryEditorView(firstText: item.word, secondText: sense.definition, isShowingEditSheet: $isShowingEditorSheet, book: selectedBook, editCategory: .word, editorMode: .add, memoryId: nil)
                } else {
                    Text("정보를 가져올 수 없습니다.")
                }
            }
        }
    }
    
    private func makeTextView(_ text: String, _ geometry: GeometryProxy) -> some View {
        VStack {
            TextAlignment(
                text: text,
                textAlignmentStyle: .justified,
                font: .systemFont(ofSize: 15),
                lineLimit: 0,
                isLineLimit: .constant(false)
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .frame(maxWidth: geometry.size.width * 0.9, alignment: .leading)
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(lineWidth: 1)
            }
        }
        .frame(width: geometry.size.width * 0.9)
        .background(Color.cellBackgroud)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .foregroundStyle(colorScheme == .light ? Color.cellBackgroud : Color(hexCode: "DCE2F0"))
        .padding(.bottom, 10)
    }
    
}

#Preview {
    DictionaryDetailView(item: WordItem.dummyItems, route: .dictionaryRoute)
}
