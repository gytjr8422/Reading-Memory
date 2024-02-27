//
//  SelectBookView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/28/24.
//

import RealmSwift
import SwiftUI
import Kingfisher

struct SelectBookView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedResults(Book.self) private var savedBooks
    
    @Binding var selectedBook: Book?
    @Binding var isShowingEditorSheet: Bool
    
    var books: [Book] {
        savedBooks.filter("reading == true OR finished == true").sorted { book1, book2 in
            return book1.addDate > book2.addDate
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                makeBookListView(geometry)
                    .frame(width: geometry.size.width)
                    .background(colorScheme == .light ? .white : Color.BackgroundBlue)
                    .navigationTitle("단어 저장 책 선택")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("취소") {
                                dismiss()
                            }
                        }
                    }
            }
        }
    }
    
    private func makeBookListView(_ geometry: GeometryProxy) -> some View {
        VStack {
            ScrollView {
                ForEach(books, id:\.self) { book in
                    Button {
                        selectedBook = book
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isShowingEditorSheet = true
                        }
                        dismiss()
                    } label: {
                        HStack {
                            let _ = print("\(geometry.size.height), \(geometry.size.width)")
                            if let url = URL(string: book.thumbnail) {
                                KFImage(url)
                                    .placeholder({ _ in
                                        ProgressView()
                                            .frame(width: geometry.size.width / 7, height: geometry.size.width * 0.2)
                                    })
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width / 7)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(.horizontal, 3)
                            } else {
                                Rectangle()
                                    .frame(width: geometry.size.width / 7, height: geometry.size.width * 0.2)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(.horizontal, 3)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .lineLimit(1)
                                let authors = book.authors.joined(separator: ", ")
                                Group {
                                    Text(authors)
                                        .lineLimit(1)
                                    Text(book.publisher)
                                        .lineLimit(1)
                                }
                                .font(.caption)
                            }
                            .padding(.leading, 5)
                            Spacer()
                        }
                        .frame(width: geometry.size.width * 0.9)
                        .padding(.vertical, 5)
                    }
                }
            }
        }
    }
}

#Preview {
    SelectBookView(selectedBook: .constant(Book.dummyBook), isShowingEditorSheet: .constant(true))
}
