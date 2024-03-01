//
//  DictionaryView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/26/24.
//

import SwiftUI

struct DictionaryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var dictionaryViewModel: DictionaryViewModel
    @EnvironmentObject private var router: Router
    
    @State private var searchText: String = ""
    @State private var emptyResultText: String = "단어를 검색해보세요."
    @State private var isLoading: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    private let route: Route = .dictionaryRoute
    
    var body: some View {
        NavigationStack(path: $router.dictionaryRoutes) {
            GeometryReader { geometry in
                VStack {
                    ScrollViewReader { proxy in
                        searchBar
                            .padding(.top)
                            .frame(width: geometry.size.width * 0.9)
                            .onSubmit {
                                proxy.scrollTo(1, anchor: .top)
                            }
                        
                        Divider()
                            .id(1)
                        
                        makeDictionaryListView(geometry)
                            .frame(width: geometry.size.width)
                    }
                }
                .frame(width: geometry.size.width)
                .background(colorScheme == .light ? .white : Color.backgroundBlue)
                .navigationDestination(for: DictionaryRoute.self) { route in
                    switch route {
                    case .dictionaryDetail(let item):
                        DictionaryDetailView(item: item, route: .dictionaryRoute)
                    }
                }
            }
        }
        .tint(colorScheme == .light ? .black : .white)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private var searchBar: some View {
        VStack {
            RMTextField(
                text: $searchText,
                isWrongText: false,
                isTextfieldDisabled: false,
                isTextFieldFocused: _isTextFieldFocused,
                placeholderText: "단어를 검색해보세요",
                isSearchBar: true
            )
            .onSubmit {
                Task {
                    isLoading = true
                    await dictionaryViewModel.searchDictionary(searchText)
                    isLoading = false
                }
            }
        }
    }
    
    private func makeDictionaryListView(_ geometry: GeometryProxy) -> some View {
        ScrollView {
            if !isLoading {
                if dictionaryViewModel.isApiConnected {
                    if !dictionaryViewModel.dictionaryList.isEmpty {
                        LazyVStack {
                            ForEach(dictionaryViewModel.dictionaryList, id: \.self) { item in
                                Button {
                                    router.dictionaryRoutes.append(.dictionaryDetail(item))
                                } label: {
                                    DictionaryCell(item: item)
                                        .frame(height: geometry.size.width * 0.25)
                                        .padding(.horizontal, geometry.size.width * 0.05)
                                }
                            }
                        }
                    } else {
                        Text(emptyResultText)
                            .padding(.vertical)
                    }
                } else {
                    Text("검색에 실패했습니다. 다시 검색해주세요.")
                        .padding(.vertical)
                }
            } else {
                ProgressView()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

#Preview {
    DictionaryView()
}
