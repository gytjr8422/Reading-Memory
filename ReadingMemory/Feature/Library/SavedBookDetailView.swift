//
//  BookDetailView.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/13/24.
//

import Kingfisher
import SwiftUI
import RealmSwift

struct SavedBookDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var router: Router
    
    @ObservedResults(Book.self) var savedBooks
    
    @State private var headerColor: UIColor = .gray
    @State private var isShowingSafari: Bool = false
    @State private var isLineLimit: Bool = true
    
    var book: Book
    
    private var savedBook: Results<Book> {
        savedBooks.filter("isbn == %@", book.isbn)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView {
                    headerView(geometry)
                    saveButtons(geometry)
                    Divider()
                    if let book = savedBook.first, book.reading || book.finished {
                        memoryButton(geometry)
                        Divider()
                    }
                    detailView(geometry)
                }
                .background(colorScheme == .light ? .white : Color(hexCode: "101820")) // 101820, 1a1d1a
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("상세정보")
                        .bold()
                        .foregroundColor(colorScheme == .light ? .black : .white)
                        .lineLimit(1)
                }
            }
            .frame(width: geometry.size.width)
        }
    }
    
    @ViewBuilder
    private func headerView(_ geo: GeometryProxy) -> some View {
        let headerHeight = geo.size.height / 2.5
        ZStack {
            GeometryReader { geometry in
                Color.secondary
                    .opacity(0.3)
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: headerHeight + geometry.frame(in: .global).minY > 0 ? headerHeight + geometry.frame(in: .global).minY : 0
                    )
                    .clipped()
                    .offset(y: -geometry.frame(in: .global).minY)
            }
            .frame(height: headerHeight)
            
            VStack {
                if let url = URL(string: book.thumbnail) {
                    KFImage(url)
                        .placeholder({ _ in
                            ProgressView()
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width / 3)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.vertical)
                } else {
                    Rectangle()
                        .frame(width: geo.size.width / 3, height: 200)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.horizontal, 3)
                        .padding(.vertical)
                }
                
                Text(book.title)
                    .font(.title3)
                    .lineLimit(2)
                .foregroundColor(colorScheme == .light ? .black : .white)
                .frame(width: geo.size.width * 0.85)
                .padding(.bottom)
                
            }
            .offset(x: 0, y: -headerHeight / 30)
        }
    }
    
    private func saveButtons(_ geo: GeometryProxy) -> some View {
        HStack {
            Button {
                Book.editBook(book, editCategory: .like)
            } label: {
                VStack {
                    if savedBook.count > 0, savedBook[0].liked {
                        Image(systemName: "heart.fill")
                            .padding(.bottom, 2)
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "heart")
                            .padding(.bottom, 2)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                    Text("읽고 싶은 책")
                }
                .frame(width: geo.size.width / 3.5)
            }
            
            Divider()
            
            Button {
                Book.editBook(book, editCategory: .reading)
            } label: {
                VStack {
                    if savedBook.count > 0, savedBook[0].reading {
                        Image(systemName: "eye.fill")
                            .padding(.bottom, 2)
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "eye")
                            .padding(.bottom, 2)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                    Text("읽는 중")
                }
                .frame(width: geo.size.width / 3.5)
            }
            
            Divider()
            
            Button {
                Book.editBook(book, editCategory: .finished)
            } label: {
                VStack {
                    if savedBook.count > 0, savedBook[0].finished {
                        Image(systemName: "checkmark.square.fill")
                            .padding(.bottom, 2)
                            .foregroundColor(.cyan)
                    } else {
                        Image(systemName: "square")
                            .padding(.bottom, 2)
                            .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                    Text("읽은 책")
                }
                .frame(width: geo.size.width / 3.5)
            }
        }
        .foregroundColor(colorScheme == .light ? .black : .white)
        .padding(.vertical)
        .padding(.horizontal, 30)
    }
    
    private func memoryButton(_ geo: GeometryProxy) -> some View {
        Button {
            router.libraryRoutes.append(.memory(book))
        } label: {
            Rectangle()
                .frame(width: geo.size.width * 0.8, height: 40)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay {
                    Text("기억하러 가기")
                        .foregroundColor(.black)
                        .font(.subheadline)
                }
        }
        .padding(.vertical, 5)
    }
    
    @ViewBuilder
    private func detailView(_ geo: GeometryProxy) -> some View {
        VStack {
            VStack(alignment: .leading) {
                if book.authors.count > 0 {
                    Text("저자")
                        .font(.headline)
                        .bold()
                        .padding(.vertical, 5)
                    Text(book.authors.joined(separator: ", "))
                        .font(.subheadline)
                        .padding(.bottom, 5)
                }
                
                if book.translators.count > 0 {
                    Text("역자")
                        .font(.headline)
                        .bold()
                        .padding(.vertical, 5)
                    Text(book.translators.joined(separator: ", "))
                        .font(.subheadline)
                        .padding(.bottom, 5)
                }
                
                if book.publisher.count > 0 {
                    Text("출판사")
                        .font(.headline)
                        .bold()
                        .padding(.vertical, 5)
                    Text(book.publisher)
                        .font(.subheadline)
                        .padding(.bottom, 5)
                }
            }
            .frame(width: geo.size.width * 0.85, alignment: .leading)
            
            Divider()
            
            if book.contents.count > 0 {
                TextAlignment(
                    text: book.contents,
                    textAlignmentStyle: .justified,
                    font: .systemFont(ofSize: 15), widthRatio: 0.85,
                    lineLimit: 8,
                    isLineLimit: $isLineLimit
                )
                .padding(.vertical)
                
                Divider()
                
                Button {
                    isLineLimit.toggle()
                } label: {
                    Text(isLineLimit ? "더 보기" : "간략히 보기")
                        .foregroundColor(colorScheme == .light ? Color.FontBackgroundLight : Color.fontBackgroundDark)
                        .frame(width: geo.size.width * 0.85)
                }
                .padding(.vertical, 10)
            }
            
            Divider()
            
            if let url = URL(string: book.url) {
                Button {
                    isShowingSafari = true
                } label: {
                    Text("책 상세정보 보러가기")
                        .foregroundColor(colorScheme == .light ? Color.FontBackgroundLight : Color.fontBackgroundDark)
                        .frame(width: geo.size.width * 0.85)
                }
                .padding(.vertical, 10)
                .fullScreenCover(isPresented: $isShowingSafari) {
                    SafariView(url: url)
                }
            }
            
            Divider()
        }
    }
}



#Preview {
    NavigationStack {
        SavedBookDetailView(book: Book.dummyBook)
    }
    .environmentObject(SearchViewModel())
}
