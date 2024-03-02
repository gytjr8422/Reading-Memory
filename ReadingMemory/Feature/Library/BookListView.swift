//
//  BookDetailView.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/11/24.
//

import Kingfisher
import RealmSwift
import SwiftUI

struct BookListView: View {
    @EnvironmentObject private var router: Router
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedResults(Book.self) var savedBooks
    
    @State private var isBookListEditing: Bool = false
    @State private var selectedBooks: [Book] = []
    @State private var isShwoingDeleteAlert: Bool = false
    
    let title: String
    let category: EditList
    
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    private var books: Results<Book> {
        switch category {
        case .like:
            return savedBooks.filter("liked == true").sorted(byKeyPath: "addDate", ascending: false)
        case .reading:
            return savedBooks.filter("reading == true").sorted(byKeyPath: "addDate", ascending: false)
        case .finished:
            return savedBooks.filter("finished == true").sorted(byKeyPath: "addDate", ascending: false)
        default:
            return savedBooks
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(books, id: \.self) { book in
                        Button {
                            router.libraryRoutes.append(.savedBookDetail(book))
                        } label: {
                            if let url = URL(string: book.thumbnail) {
                                KFImage(url)
                                    .placeholder({ _ in
                                        ProgressView()
                                    })
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(.horizontal, 3)
                            } else {
                                Rectangle()
                                    .overlay(content: {
                                        Text(book.title)
                                            .lineLimit(2)
                                            .font(.subheadline)
                                            .foregroundColor(colorScheme == .light ? .white : .black)
                                            .padding(.horizontal, 2)
                                    })
                                    .background(Color.secondary)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(.horizontal, 3)
                            }
                        }
                        .disabled(isBookListEditing)
                        .overlay {
                            if isBookListEditing {
                                Color.gray.opacity(0.5)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .overlay {
                                        editButton(book)
                                    }
                                    .onTapGesture {
                                        if selectedBooks.contains(book) {
                                            if let index = selectedBooks.firstIndex(where: { $0.isbn == book.isbn }) {
                                                selectedBooks.remove(at: index)
                                            }
                                        } else {
                                            selectedBooks.append(book)
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.bottom)
                })
                .padding()
            }
            .navigationTitle(title)
            .background(colorScheme == .light ? .white : Color(hexCode: "101820"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            isBookListEditing.toggle()
                            selectedBooks.removeAll()
                        } label: {
                            isBookListEditing ? Text("취소") : Text("편집")
                        }
                        
                        if isBookListEditing {
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
            .alert("\(selectedBooks.count)개의 책을 삭제하시겠습니까?", isPresented: $isShwoingDeleteAlert, actions: {
                Button("삭제", role: .destructive) {
                    Book.deleteBooks(selectedBooks)
                }
                Button("취소", role: .cancel) { }
            }, message: {
                Text("책 삭제 시 모든 기억은 복구할 수 없습니다.")
            })
        }
    }
    
    @ViewBuilder
    private func editButton(_ book: Book) -> some View {
        if selectedBooks.contains(book) {
            Image(systemName: "checkmark.circle")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.title)
        } else {
            Image(systemName: "circle")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.title)
        }
    }
}

#Preview {
    NavigationStack {
        BookListView(title: "읽고 있는 중", category: .reading)
    }
}
