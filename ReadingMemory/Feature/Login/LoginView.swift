//
//  LoginView.swift
//  ReadingMemory
//
//  Created by 김효석 on 4/1/24.
//

import AuthenticationServices
import CryptoKit
import Firebase
import SwiftUI

struct LoginView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var loginViewModel: LoginViewModel
    
    @State private var errorMessage: String = ""
    @State private var isShowingAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var nonce: String?
    @State private var isGuest: Bool = false
    
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    var body: some View {
        VStack {
            SignInWithAppleButton(.signIn) { request in
                let nonce = randomNonceString()
                self.nonce = nonce
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    loginWithFirebase(authorization)
                case .failure(let error):
                    showError(error.localizedDescription)
                }
            }
            .frame(height: 45)
            .clipShape(.capsule)
            .overlay {
                ZStack {
                    Capsule()
                    
                    HStack {
                        Image(systemName: "applelogo")
                        
                        Text("Sign in with Apple")
                    }
                    .foregroundStyle(colorScheme == .light ? .white : .black)
                }
                .allowsHitTesting(false)
            }
            
            Button {
                loginViewModel.isGuest = true
            } label: {
                Text("로그인 없이 둘러보기")
                    .foregroundStyle(Color.primary)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .contentShape(.capsule)
                    .background(
                        Capsule()
                            .stroke(Color.primary, lineWidth: 0.5)
                    )
            }

        }
        .alert(errorMessage, isPresented: $isShowingAlert) {  }
        .overlay {
            if isLoading {
                loadingScreen()
            }
        }
    }
    
    @ViewBuilder
    func loadingScreen() -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            
            ProgressView()
                .frame(width: 45, height: 45)
                .background(.background, in: .rect(cornerRadius: 5))
        }
    }
    
    func showError(_ message: String) {
        errorMessage = message
        isShowingAlert.toggle()
        isLoading = false
    }
    
    func loginWithFirebase(_ authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            isLoading = true
            
            guard let nonce else {
//                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                showError("Cannot process your request.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
//                print("Unable to fetch identity token")
                showError("Cannot process your request.")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                showError("Cannot process your request.")
                return
            }
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error {
                    showError(error.localizedDescription)
                }
                logStatus = true
                isLoading = false
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

#Preview {
    LoginView()
}
