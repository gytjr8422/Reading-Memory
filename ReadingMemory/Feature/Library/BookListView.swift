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
                }
                .padding(.bottom)
            })
            .padding()
        }
        .navigationTitle(title)
        .background(colorScheme == .light ? .white : Color(hexCode: "101820"))
    }
}

#Preview {
    NavigationStack {
        BookListView(title: "읽고 있는 중", category: .reading)
    }
}
