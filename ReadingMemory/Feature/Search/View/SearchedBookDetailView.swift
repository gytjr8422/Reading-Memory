//
//  SearchedBookDetailView.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/19/24.
//

import SwiftUI
import RealmSwift

struct SearchedBookDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var searchViewModel: SearchViewModel
    
    @ObservedResults(Book.self) var savedBooks
    
    @State private var headerColor: UIColor = .gray
    @State private var isShowingSafari: Bool = false
    @State private var bookDescription: String = ""
    @State private var isLoading: Bool = true
    @State private var isLineLimit: Bool = true

    var book: BookDocument
    
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
                detailView
            }
            .background(colorScheme == .light ? .white : Color(hexCode: "101820")) // 101820, 1a1d1a
        }
        .onAppear {
            Task {
//                headerColor = await searchViewModel.getAverageColor(book.thumbnail)
//
//                var brightness: CGFloat = 0
//                headerColor.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
//                accentColor = brightness > 0.5 ? UIColor.black : UIColor.white
                
                let isbnArray = book.isbn.split(separator: " ")
                bookDescription = try await searchViewModel.searchIsbn(String(isbnArray.count > 1 ? isbnArray[1] : isbnArray[0]))
                isLoading = false
            }
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
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width / 3)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    } placeholder: {
                        ProgressView()
                            .frame(width: UIScreen.main.bounds.width / 5, height: 110)
                    }
                    .padding(.bottom)
                } else {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width / 3, height: 200)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.horizontal, 3)
                        .padding(.bottom)
                }

                TextAlignment(
                    text: book.title,
                    textAlignmentStyle: .justified,
                    font: .systemFont(ofSize: 20),
                    width: UIScreen.main.bounds.width - 120,
                    lineLimit: 2,
                    isLineLimit: $isLineLimit
                )
                .foregroundColor(colorScheme == .light ? .black : .white)
                .frame(width: UIScreen.main.bounds.width - 20)
            }
            .offset(x: 0, y: -headerHeight / 30)
        }
    }
    
    // 책의 isbn이 중복되지 않는다면, primaryKey로 활용해도
    private var saveButtons: some View {
        HStack {
            Button {
                if savedBook.count > 0 {
                    Book.editBook(savedBook[0], editCategory: .like)
                } else {
                    Book.addBook(book, bookDescription, editCategory: .like)
                }
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
                if savedBook.count > 0 {
                    Book.editBook(savedBook[0], editCategory: .reading)
                } else {
                    Book.addBook(book, bookDescription, editCategory: .reading)
                }
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
                if savedBook.count > 0 {
                    Book.editBook(savedBook[0], editCategory: .finished)
                } else {
                    Book.addBook(book, bookDescription, editCategory: .finished)
                }
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
    
    private var detailView: some View {
        VStack {
            if !isLoading {
                if bookDescription.count > 0 {
                    TextAlignment(
                        text: bookDescription.count > 0 ? bookDescription : book.contents,
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
            } else {
                ProgressView()
                    .frame(width: 50, height: 50)
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
    SearchedBookDetailView(book: BookDocument.dummyDocument)
}
