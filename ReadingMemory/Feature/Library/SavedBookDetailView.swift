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
    
    private let headerHeight: CGFloat = UIScreen.main.bounds.height / 3
    
    private var savedBook: Results<Book> {
        savedBooks.filter("isbn == %@", book.isbn)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                headerView
                saveButtons
                Divider()
                if let book = savedBook.first, book.reading || book.finished {
                    memoryButton
                    Divider()
                }
                detailView
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
    }
    
    private var headerView: some View {
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
                                .frame(width: UIScreen.main.bounds.width / 3, height: 200)
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width / 3)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.bottom)
                } else {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width / 3, height: 200)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.horizontal, 3)
                        .padding(.bottom)
                }
                
                Text(book.title)
                    .font(.title3)
                    .lineLimit(2)
                .foregroundColor(colorScheme == .light ? .black : .white)
                .frame(width: UIScreen.main.bounds.width - 40)
                
            }
            .offset(x: 0, y: -headerHeight / 30)
        }
    }
    
    private var saveButtons: some View {
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
                .frame(width: UIScreen.main.bounds.width / 3.5)
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
                .frame(width: UIScreen.main.bounds.width / 3.5)
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
                .frame(width: UIScreen.main.bounds.width / 3.5)
            }
        }
        .foregroundColor(colorScheme == .light ? .black : .white)
        .padding(.vertical)
        .padding(.horizontal, 30)
    }
    
    private var memoryButton: some View {
        Button {
            router.libraryRoutes.append(.memory(book))
        } label: {
            Rectangle()
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 40)
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
    
    private var detailView: some View {
        VStack {
            if book.contents.count > 0 {
                TextAlignment(
                    text: book.contents,
                    textAlignmentStyle: .justified,
                    font: .systemFont(ofSize: 15),
                    width: UIScreen.main.bounds.width - 30,
                    lineLimit: 8,
                    isLineLimit: $isLineLimit
                )
                
                Button {
                    isLineLimit.toggle()
                } label: {
                    Text(isLineLimit ? "더 보기" : "간락히 보기")
                        .foregroundColor(colorScheme == .light ? Color.FontBackgroundLight : Color.FontBackgroundDark)
                }
                .padding()
            }
            
            if let url = URL(string: book.url) {
                Button {
                    isShowingSafari = true
                } label: {
                    Text("책 상세정보 보러가기")
                        .foregroundColor(colorScheme == .light ? Color.FontBackgroundLight : Color.FontBackgroundDark)
                }
                .fullScreenCover(isPresented: $isShowingSafari) {
                    SafariView(url: url)
                }
            }
        }
        .padding()
    }
}



#Preview {
    NavigationStack {
        SavedBookDetailView(book: Book.dummyBook)
    }
    .environmentObject(SearchViewModel())
}
