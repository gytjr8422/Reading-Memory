//
//  LoginViewModel.swift
//  ReadingMemory
//
//  Created by 김효석 on 4/10/24.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @AppStorage("log_Status") private var logStatus: Bool = false
    @Published var isGuest: Bool = false
    
    
    
}
