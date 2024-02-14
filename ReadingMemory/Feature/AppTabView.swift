//
//  ContentView.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/2/24.
//

import SwiftUI


struct AppTabView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selection: AppScreen = .library
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppScreen.allCases) { screen in
                screen.destination
                    .tag(screen)
                    .tabItem { screen.label }
            }
        }
    }
}

#Preview {
    AppTabView()
        .environmentObject(Router())
        .environmentObject(SearchViewModel())
}
