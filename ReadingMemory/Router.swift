//
//  Router.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/12/24.
//

import Foundation
import RealmSwift

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

enum SearchRoute: Hashable {
    case searchedBookDetail(book: BookDocument)
}


final class Router: ObservableObject {
    @Published var libraryRoutes: [LibraryRoute] = []
    @Published var dictionaryRoute: [DictionaryRoute] = []
    @Published var searchRoutes: [SearchRoute] = []
    
    func reset(screen: AppScreen) {
        switch screen {
        case .library:
            libraryRoutes.removeAll()
        case .dictionary:
            dictionaryRoute.removeAll()
        case .memories:
            print("memory")
        case .search:
            searchRoutes.removeAll()
        case .setting:
            print("Setting")
        }
    }
}
