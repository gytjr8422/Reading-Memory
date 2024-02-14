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
    @State private var searchViewModel = SearchViewModel()
    
    let migrator = Migrator()
    
    var body: some Scene {
        WindowGroup {
            let _ = UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            let _ = print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
            AppTabView()
                .environmentObject(router)
                .environmentObject(searchViewModel)
        }
    }
}
