//
//  AppScreen.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/12/24.
//

import SwiftUI

enum AppScreen: Hashable, Identifiable, CaseIterable {
    case library
    case dictionary
    case memories
    case search
    case setting
    
    var id: AppScreen { self }
}

extension AppScreen {
    @ViewBuilder
    var label: some View {
        switch self {
        case .library:
            Label("서재", systemImage: "book")
        case .dictionary:
            Label("사전", systemImage: "character.book.closed.fill.ko")
        case .memories:
            Label("기억", systemImage: "brain.head.profile")
        case .search:
            Label("검색", systemImage: "magnifyingglass")
        case .setting:
            Label("설정", systemImage: "gearshape")
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .library:
            LibraryView()
        case .dictionary:
            Text("dictionary")
        case .memories:
            AllMemoryView()
        case .search:
            SearchView()
        case .setting:
            Text("Setting")
        }
    }
}
