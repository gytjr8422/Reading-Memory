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
        ScrollView {
            HStack {
                Text("단어")
                    .font(.title3)
                    .bold()
                
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            
            makeTextView(item.word)
            
            HStack {
                Text("뜻")
                    .font(.title3)
                    .bold()
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            
            if let sense = item.sense.first {
                makeTextView(sense.definition)
            }
        }
        .background(colorScheme == .light ? .white : Color.BackgroundBlue)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingSelectBookSheet = true
                } label: {
                    Text("저장")
                }

            }
        }
        .fullScreenCover(isPresented: $isShowingEditorSheet) {
            if let sense = item.sense.first {
                MemoryEditorView(firstText: item.word, secondText: sense.definition, isShowingEditSheet: $isShowingEditorSheet, book: selectedBook, editCategory: .word, editorMode: .add, memoryId: nil)
            } else {
                Text("정보를 가져올 수 없습니다.")
            }
        }
        .sheet(isPresented: $isShowingSelectBookSheet) {
            SelectBookView(selectedBook: $selectedBook, isShowingEditorSheet: $isShowingEditorSheet)
                .presentationDragIndicator(.visible)
        }
    }
    
    private func makeTextView(_ text: String) -> some View {
        VStack {
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
            .frame(maxWidth: UIScreen.main.bounds.width * 0.9, alignment: .leading)
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(lineWidth: 1)
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
    DictionaryDetailView(item: WordItem.dummyItems, route: .dictionaryRoute)
}
