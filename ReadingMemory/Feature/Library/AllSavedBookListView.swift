//
//  AllSavedBookListView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/8/24.
//

import Kingfisher
import RealmSwift
import SwiftUI

struct AllSavedBookListView: View {
    
    @EnvironmentObject private var router: Router
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedResults(Book.self) private var savedBooks
    
    @State private var isEditing: Bool = false
    @State private var selectedBooks: [Book] = []
    @State private var isShwoingDeleteAlert: Bool = false
    
    private var books: Results<Book> {
        savedBooks.sorted(byKeyPath: "addDate", ascending: false)
    }
    
    var body: some View {
        ScrollView {
            bookList
                .padding()
        }
        .background(colorScheme == .light ? .white : Color(hexCode: "101820"))
        .navigationTitle("저장한 책")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        isEditing.toggle()
                        selectedBooks.removeAll()
                    } label: {
                        isEditing ? Text("취소") : Text("편집")
                    }
                    
                    if isEditing {
                        Button {
                            if !selectedBooks.isEmpty {
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
        .alert("삭제하시겠습니까?", isPresented: $isShwoingDeleteAlert, actions: {
            Button("삭제", role: .destructive) {
                Book.deleteBooks(selectedBooks)
            }
        }, message: {
            Text("저장된 도서 삭제시 저장한 메모, 단어 등 모든 기억이 함께 삭제됩니다.")
        })
    }
    
    private var bookList: some View {
        LazyVStack(alignment: .leading) {
            ForEach(books, id: \.self) { book in
                HStack {
                    if isEditing {
                        if selectedBooks.contains(book) {
                            Image(systemName: "checkmark.circle")
                                .font(.title3)
                                .padding(.trailing, 10)
                                .padding(.vertical, 5)
                                .onTapGesture {
                                    if let index = selectedBooks.firstIndex(where: { $0.isbn == book.isbn }) {
                                        selectedBooks.remove(at: index)
                                    }
                                }
                        } else {
                            Image(systemName: "circle")
                                .font(.title3)
                                .padding(.trailing, 10)
                                .padding(.vertical, 5)
                                .onTapGesture {
                                    selectedBooks.append(book)
                                }
                        }
                    }
                    
                    Button {
                        if isEditing {
                            if selectedBooks.contains(book) {
                                if let index = selectedBooks.firstIndex(where: { $0.isbn == book.isbn }) {
                                    selectedBooks.remove(at: index)
                                }
                            } else {
                                selectedBooks.append(book)
                            }
                        } else {
                            router.libraryRoutes.append(.savedBookDetail(book))
                        }
                    } label: {
                        HStack {
                            if let url = URL(string: book.thumbnail) {
                                KFImage(url)
                                    .placeholder({ _ in
                                        ProgressView()
                                            .frame(width: UIScreen.main.bounds.width / 7, height: 80)
                                    })
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width / 7)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(.horizontal, 3)
                            } else {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width / 7, height: 80)
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
                        .frame(width: UIScreen.main.bounds.width - 20)
                        .padding(.vertical, 5)
                        .background(colorScheme == .light ? .white : Color(hexCode: "101820"))
                    }
                }
            }
            .foregroundColor(colorScheme == .light ? .black : .white)
        }
    }
}

#Preview {
    NavigationStack {
        AllSavedBookListView()
            .environmentObject(Router())
    }
}
