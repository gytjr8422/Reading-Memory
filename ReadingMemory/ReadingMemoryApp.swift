//
//  ReadingMemoryApp.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/2/24.
//

import SwiftUI

@main
struct ReadingMemoryApp: App {
    @Environment(\.colorScheme) var colorScheme
    @State private var router = Router()
    @State private var libraryViewModel = LibraryViewModel()
    @State private var dictionaryViewModel = DictionaryViewModel()
    @State private var searchViewModel = SearchViewModel()
    
    let migrator = Migrator()
    
    init() {
        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    var body: some Scene {
        WindowGroup {
            let _ = UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            let _ = print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
            AppTabView()
                .environmentObject(router)
                .environmentObject(libraryViewModel)
                .environmentObject(dictionaryViewModel)
                .environmentObject(searchViewModel)
        }
    }
}
