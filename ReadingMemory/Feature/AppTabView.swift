//
//  ContentView.swift
//  ReadingMemory
//
//  Created by 김효석 on 1/2/24.
//

import SwiftUI


struct AppTabView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var router: Router
    
    /// User Log Status
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    var body: some View {
        if logStatus {
            TabView(selection: $router.selectedTab) {
                ForEach(AppScreen.allCases) { screen in
                    screen.destination
                        .tag(screen)
                        .tabItem { screen.label }
                }
            }
        } else {
            LoginView()
        }
    }
}

#Preview {
    AppTabView()
        .environmentObject(Router())
        .environmentObject(SearchViewModel())
}
