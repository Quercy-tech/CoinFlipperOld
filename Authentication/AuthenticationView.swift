//
//  AuthenticationView.swift
//  CoinFlipper
//
//  Created by Quercy on 09.05.2024.
//
import LocalAuthentication
import SwiftUI

struct AuthenticationView: View {
    
    @State private var username = ""
    @State private var password = ""
    @State private var isAdmin = false
    @State private var isUser = false
    @State private var showAlert = false
    @State private var showAdminAlert = false
    @State private var showGuestAlert = false
    @State private var attempts = 2
    
    @StateObject private var CurrencyList = Currencies()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea(.all)
                
                VStack {
                    Text("Login")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    TextField("Username", text: $username)
                        .padding()
                        .frame(width: 300,height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300,height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    Button("Face ID Unlock", action: biometricsAuthenticate)
                        .padding()
                        .foregroundStyle(.white)
                        .frame(width: 300,height: 50)
                        .background(Color.blue.opacity(0.4))
                        .cornerRadius(10)
                    Button("Login") {
                        authenticateUser(username: username, password: password)
                    }
                    .alert("Incorrect password - you're not admin", isPresented: $showAlert) {
                        Button("Ok, boomer") {
                            showAlert.toggle()
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(width: 300,height: 50)
                    .background(Color.blue.opacity(0.4))
                    .cornerRadius(10)
                    .contentShape(.rect)
                    
                    NavigationLink(destination: ContentView(CurrencyList: CurrencyList), isActive: $isAdmin) {
                    }
                    NavigationLink(destination: UserView(CurrencyList: CurrencyList), isActive: $isUser) {
                    }
                    
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    func authenticateUser(username: String, password: String) {
        if password.lowercased() == "admin" && username.lowercased() == "admin" {
            showAdminAlert.toggle()
            isAdmin = true
        } else {
            if attempts <= 0 {
                showGuestAlert.toggle()
                isUser = true
            } else {
                showAlert.toggle()
                attempts -= 1
            }
        }
    }
    
    func biometricsAuthenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your places"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                if success {
                    self.isAdmin = true
                } else {
                    // no biometrics
                }
            }
        }
    }
}

#Preview {
    AuthenticationView()
}

