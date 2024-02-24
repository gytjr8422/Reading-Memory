//
//  Router.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/12/24.
//

import Foundation
import RealmSwift

enum Route {
    case libraryRoute
    case dictionaryRoute
    case memoryRoute
    case searchRoute
    case settingRoute
}

enum LibraryRoute: Hashable {
    case savedBookDetail(Book)
    case bookList(String, EditList)
    case allSavedBookList
    case memory(Book)
    case memoryDetail(RealmSwift.Object, MemoryCategory)
}

enum DictionaryRoute: Hashable {
    case home
    case detail
}

enum MemoryRoute: Hashable {
    case memoryDetail(RealmSwift.Object, MemoryCategory)
}

enum SearchRoute: Hashable {
    case searchedBookDetail(book: BookDocument)
}


final class Router: ObservableObject {
    @Published var selectedTab: AppScreen = .library
    @Published var libraryRoutes: [LibraryRoute] = []
    @Published var dictionaryRoutes: [DictionaryRoute] = []
    @Published var memoryRoutes: [MemoryRoute] = []
    @Published var searchRoutes: [SearchRoute] = []
    
    func reset(screen: AppScreen) {
        switch screen {
        case .library:
            libraryRoutes.removeAll()
        case .dictionary:
            dictionaryRoutes.removeAll()
        case .memories:
            memoryRoutes.removeAll()
        case .search:
            searchRoutes.removeAll()
        case .setting:
            print("Setting")
        }
    }
}
