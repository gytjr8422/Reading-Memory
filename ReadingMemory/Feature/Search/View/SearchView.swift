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
        NavigationStack(path: $router.searchRoutes) {
            VStack {
                ScrollViewReader { proxy in
                    textField
                        .onSubmit {
                            proxy.scrollTo(1, anchor: .top)
                        }
                    
                    ScrollView {
                        barcodeScanButton
                            .id(1)
                        Divider()
                        searchList
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .padding()
            .background(colorScheme == .light ? .white : Color(hexCode: "101820")) // 101820, 1a1d1a
        }
        .onAppear {
            isTextFieldFocused = true
        }
        .accentColor(colorScheme == .light ? .black : .white)
    }
    
    private var textField: some View {
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
    
    private var searchList: some View {
            
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
                                        .frame(width: UIScreen.main.bounds.width / 7)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .padding(.horizontal, 3)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: UIScreen.main.bounds.width / 7, height: 80)
                                }
                            } else {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width / 7, height: 80)
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
                        .frame(width: UIScreen.main.bounds.width - 20)
                        .padding(.vertical, 5)
                    }
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
        .navigationDestination(for: SearchRoute.self) { route in
            switch route {
            case .searchedBookDetail(let searchedBook):
                SearchedBookDetailView(book: searchedBook)
            }
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
