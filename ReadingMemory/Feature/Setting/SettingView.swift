//
//  SettingView.swift
//  ReadingMemory
//
//  Created by 김효석 on 2/29/24.
//

import Firebase
import SwiftUI

struct SettingView: View {
    
    /// User Log Status
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    try? Auth.auth().signOut()
                    logStatus = false
                } label: {
                    Text("LogOut")
                }

            }
            .navigationTitle("Setting")
        }
    }
}

#Preview {
    SettingView()
}
