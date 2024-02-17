//
//  MainLibraryView.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/4/24.
//

import Kingfisher
import RealmSwift
import SwiftUI

struct LibraryView: View {
    
    @ObservedResults(Book.self) var savedBooks
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var libraryViewModel: LibraryViewModel
    
    @State private var imageHeight: CGFloat = 0
    
    var body: some View {
        // 하위뷰에도 탭바를 계속 보이도록 하기 위해서 NavigationStack을 여기 쓴다.
        NavigationStack(path: $router.libraryRoutes) {
            ScrollView {
                makeCarouselView("읽고 있는 중", savedBooks.filter("reading == true").sorted(byKeyPath: "addDate", ascending: false), .reading)
                    .padding(.bottom, 15)
                makeCarouselView("읽고 싶은 책", savedBooks.filter("liked == true").sorted(byKeyPath: "addDate", ascending: false), .like)
                    .padding(.bottom, 15)
                makeCarouselView("읽은 책", savedBooks.filter("finished == true").sorted(byKeyPath: "addDate", ascending: false), .finished)
                    .padding(.bottom, 15)
                makeCarouselView("전체 저장한 책", savedBooks.sorted(byKeyPath: "addDate", ascending: false), .all)
                    .padding(.bottom, 15)
            }
            .padding()
            .background(colorScheme == .light ? .white : Color.BackgroundBlue) // 101820, 1a1d1a
            .foregroundColor(colorScheme == .light ? .black : .white)
            .scrollIndicators(.hidden)
            .navigationDestination(for: LibraryRoute.self) { route in
                switch route {
                case .bookList(let title, let category):
                    BookListView(title: title, category: category)
                case .savedBookDetail(let book):
                    SavedBookDetailView(book: book)
                case .allSavedBookList:
                    AllSavedBookListView()
                case .memory(let book):
                    MemoryView(book: book)
                }
            }
        }
        .accentColor(colorScheme == .light ? .black : .white)
    }
    
    private func makeCarouselView(_ title: String, _ books: Results<Book>, _ category: EditList) -> some View {
        VStack {
            HStack {
                Button {
                    if category != .all {
                        router.libraryRoutes.append(.bookList(title, category))
                    } else {
                        router.libraryRoutes.append(.allSavedBookList)
                    }
                } label: {
                    HStack {
                        Text(title)
                            .bold()
                            .padding(.horizontal, 2)
                        Image(systemName: "chevron.right")
                            .resizable()
                            .frame(width: 10, height: 15)
                    }
                    .font(.title2)
                }
                Spacer()
            }
            
            if #available(iOS 17.0, *) {
                if category == .reading {
                    makeReadingScrollView(books)
                        .scrollTargetLayout()
                        .scrollTargetBehavior(.viewAligned)
                        .scrollIndicators(.hidden)
                } else {
                    makeBookScrollView(books)
                        .scrollTargetLayout()
                        .scrollTargetBehavior(.viewAligned)
                        .scrollIndicators(.hidden)
                }
            } else {
                makeBookScrollView(books)
                    .scrollIndicators(.hidden)
            }
        }
    }
    
    private func makeReadingScrollView(_ books: Results<Book>) -> some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(books, id: \.self) { book in
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 250)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(Color(hexCode: "22333B")) // 22333B, 262730, 1A1B25, 2A2D34
                        .overlay {
                            VStack {
                                HStack {
                                    Button {
                                        router.libraryRoutes.append(.savedBookDetail(book))
                                    } label: {
                                        HStack {
                                            if let url = URL(string: book.thumbnail) {
                                                KFImage(url)
                                                    .placeholder({ _ in
                                                        ProgressView()
                                                            .frame(width: UIScreen.main.bounds.width * 0.3)
                                                    })
                                                    .resizable()
                                                    .frame(width: UIScreen.main.bounds.width * 0.28, height: UIScreen.main.bounds.width * 0.3 * 1.35)
                                                    .aspectRatio(contentMode: .fill)
                                                    .clipped()
                                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                            } else {
                                                Rectangle()
                                                    .frame(width: UIScreen.main.bounds.width * 0.28, height: UIScreen.main.bounds.width * 0.3 * 1.35)
                                                    .clipped()
                                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                            }
                                        }
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(book.title)
                                            .lineLimit(3)
                                            .font(.body)
                                            .bold()
                                            .padding(.top, 15)
                                        
                                        Spacer()
                                        
                                        Group {
                                            Text("최초 기억 날짜")
                                            Text(libraryViewModel.fetchFirstAndLatestInputDates(sentences: book.sentences, words: book.words, thoughts: book.thoughts).0)
                                                .padding(.bottom, 5)
                                            Text("최근 기억 날짜")
                                            Text(libraryViewModel.fetchFirstAndLatestInputDates(sentences: book.sentences, words: book.words, thoughts: book.thoughts).1)
                                                .padding(.bottom, 15)
                                        }
                                        .font(.caption)
                                    }
                                    .frame(height: UIScreen.main.bounds.width * 0.3 * 1.45)
                                    .padding(.leading, 5)
                                    
                                    Spacer()
                                    
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.7)
                                
                                Button {
                                    router.libraryRoutes.append(.memory(book))
                                } label: {
                                    Rectangle()
                                        .frame(width: UIScreen.main.bounds.width * 0.7, height: 40)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .overlay {
                                            Text("기억하러 가기")
                                                .foregroundColor(.black)
                                                .font(.subheadline)
                                        }
                                }
                                .padding(.bottom, 5)
                                
                                
//                                Button {
//                                    router.libraryRoutes.append(.savedBookDetail(book))
//                                } label: {
//                                    Rectangle()
//                                        .frame(width: UIScreen.main.bounds.width * 0.7, height: 40)
//                                        .clipped()
//                                        .clipShape(RoundedRectangle(cornerRadius: 5))
//                                        .overlay {
//                                            Text("상세정보 보기")
//                                                .foregroundColor(.black)
//                                                .font(.subheadline)
//                                        }
//                                }
//                                .padding(.bottom, 5)
                            }
                        }
                }
            }
        }
    }
    
    private func makeBookScrollView(_ books: Results<Book>) -> some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(0..<books.count, id: \.self) { index in
                    Button {
                        router.libraryRoutes.append(.savedBookDetail(books[index]))
                    } label: {
                        VStack {
                            if let url = URL(string: books[index].thumbnail) {
                                KFImage(url)
                                    .placeholder({ _ in
                                        ProgressView()
                                            .frame(width: UIScreen.main.bounds.width / 3)
                                    })
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: UIScreen.main.bounds.width / 3)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(.horizontal, 3)
                                    .padding(.bottom, 3)
//                                TextAlignment(
//                                    text: books[index].title,
//                                    textAlignmentStyle: .justified,
//                                    font: .systemFont(ofSize: 15),
//                                    width:  UIScreen.main.bounds.width / 3,
//                                    lineLimit: 1,
//                                    isLineLimit: .constant(true)
//                                )
                                Text(books[index].title)
                                    .lineLimit(1)
                                    .font(.body)
                                    .frame(width: UIScreen.main.bounds.width / 3)
                            }
                        }
                    }
                }
            }
//            .frame(height: 235)
        }
    }
}

#Preview {
    NavigationStack {
        LibraryView()
            .environmentObject(Router())
            .environmentObject(LibraryViewModel())
    }
}
