//
//  SearchView.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/12/24.
//

import SwiftUI

struct SearchView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var searchViewModel: SearchViewModel
    @EnvironmentObject var router: Router
    
    @State private var searchText: String = ""
    
    @State private var isbn: String?
    @State private var isBarcode: Bool = false
    @State private var isEndPage: Bool = false
    
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack(path: $router.searchRoutes) {
                VStack {
                    ScrollViewReader { proxy in
                        searchBar
                            .padding(.top)
                            .padding(.horizontal)
                            .onSubmit {
                                proxy.scrollTo(1, anchor: .top)
                            }
                        
                        ScrollView {
                            barcodeScanButton
                                .padding(.horizontal)
                                .id(1)
                            Divider()
                            searchList(geometry)
                        }
                        .scrollDismissesKeyboard(.immediately)
                    }
                }
                .background(colorScheme == .light ? .white : Color(hexCode: "101820")) // 101820, 1a1d1a
                .navigationDestination(for: SearchRoute.self) { route in
                    switch route {
                    case .searchedBookDetail(let searchedBook):
                        SearchedBookDetailView(book: searchedBook)
                    }
                }
                .navigationDestination(for: LibraryRoute.self) { route in
                    switch route {
                    case .savedBookDetail(let book):
                        SavedBookDetailView(book: book)
                    case .bookList(let title, let editCategory):
                        BookListView(title: title, category: editCategory)
                    case .allSavedBookList:
                        AllSavedBookListView()
                    case .memory(let book):
                        MemoryView(book: book)
                    case .memoryDetail(let memory, let memoryCategory):
                        MemoryDetailView(anyMemory: memory, category: memoryCategory)
                    }
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
            .tint(colorScheme == .light ? .black : .white)
        }
    }
    
    private var searchBar: some View {
        VStack {
            RMTextField(
                text: $searchText,
                isWrongText: false,
                isTextfieldDisabled: false,
                isTextFieldFocused: _isTextFieldFocused,
                placeholderText: "제목, 작가를 검색해보세요",
                isSearchBar: true
            )
            .onSubmit {
                Task {
                    try await searchViewModel.searchTitle(searchText)
                }
            }
        }
    }
    
    @ViewBuilder
    private func searchList(_ geometry: GeometryProxy) -> some View {
        if !searchViewModel.books.isEmpty {
            LazyVStack(alignment: .leading) {
                ForEach(searchViewModel.books, id: \.self) { searchedBook in
                    Button {
                        router.searchRoutes.append(.searchedBookDetail(book: searchedBook))
                    } label: {
                        HStack {
                            if let url = URL(string: searchedBook.thumbnail) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width / 7)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .padding(.horizontal, 3)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: geometry.size.width / 7, height: 80)
                                }
                            } else {
                                Rectangle()
                                    .frame(width: geometry.size.width / 7, height: 80)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(.horizontal, 3)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(searchedBook.title)
                                    .lineLimit(1)
                                let authors = searchedBook.authors.joined(separator: ", ")
                                Group {
                                    Text(authors)
                                        .lineLimit(1)
                                    Text(searchedBook.publisher)
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
                    .padding(.horizontal)
                    .onAppear {
                        guard let index = searchViewModel.books.firstIndex(where: { $0.isbn == searchedBook.isbn }) else { return }
                        if index == searchViewModel.books.count - 1, !isEndPage {
                            Task {
                                self.isEndPage = try await searchViewModel.additionalSearch(searchText)
                            }
                        }
                    }
                    
                }
                .foregroundColor(colorScheme == .light ? .black : .white)
            }
        } else {
            Text("도서를 검색해보세요.")
                .padding(.vertical)
        }
        
    }
    
    private var barcodeScanButton: some View {
        HStack {
            Spacer()
            
            Button {
                isBarcode = true
            } label: {
                Text("\(Image(systemName: "barcode.viewfinder")) 바코드 스캔해서 검색하기")
                    .foregroundColor(Color(hexCode: "8AB0AB"))
            }
            .fullScreenCover(isPresented: $isBarcode, content: {
                BarcodeScannerView(scannedISBN: $isbn, isCameraActive: $isBarcode)
                    .presentationDragIndicator(.visible)
            })
            .onReceive(isbn.publisher, perform: { _ in
                Task {
                    if let isbn {
                        try await searchViewModel.searchTitle(isbn)
                    }
                    isbn = nil
                }
            })
            .padding(.vertical, 3)
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(SearchViewModel())
        .environmentObject(Router())
}
