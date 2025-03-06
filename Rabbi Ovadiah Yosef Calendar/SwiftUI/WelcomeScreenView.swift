//
//  WelcomeScreenView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 2/23/25.
//

import SwiftUI

@available(iOS 15.0, *)
struct WelcomeScreenView: View {
    @Environment(\.openURL) var openURL
    @State private var showHaskamotAlert = false
    @State private var showAboutUsAlert = false
    
    var body: some View {
        ZStack {
            Image("welcome_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 350, maxHeight: 250)
                
                Text("Worldwide Halachic Times according to our Sepharadic Tradition.")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: 300)
                    .padding()

                HStack(spacing: 80) {
                    Button(action: { showHaskamotAlert = true }) {
                        Text("Haskamot")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color.white)
                    }
                    
                    Button(action: { showAboutUsAlert = true }) {
                        Text("About Us")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color.white)
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: getStarted) {
                    Text("Get Started")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(Color.white)
                }
                .padding()
            }
            .padding(.horizontal, 20) // ✅ Ensures elements don’t exceed screen width
        }
        .alert("Choose a haskama to view", isPresented: $showHaskamotAlert) {
            Button("Rabbi Elbaz (English)", action: { openURL(URL(string: "https://royzmanim.com/assets/Haskamah.pdf")!) })
            Button("Rabbi Dahan (Hebrew)", action: { openURL(URL(string: "https://royzmanim.com/assets/%D7%94%D7%A1%D7%9B%D7%9E%D7%94.pdf")!) })
            Button("Dismiss", role: .cancel, action: {})
        } message: {
            Text("Multiple rabbanim have given their haskama/approval to this app. Choose which one you would like to view.")
        }.textCase(nil)
        .alert("About Us", isPresented: $showAboutUsAlert) {
            Button("Dismiss", role: .cancel, action: {})
        } message: {
            Text("We are the platform to use whenever and wherever you'd need Halachic Times (Zemanim) according to Hakham Ovadia Yosef zt'l, following his practices represented in his Ohr Hachaim calendar from Eretz Yisrael. Outside Israel, our algorithm follows the rules outlined by the Minḥat Kohen (as quoted by R David Yosef, approved by R Yitzḥak Yosef) to comply with the astronomical differences while sticking to seasonal minutes.")
        }.textCase(nil)
    }
    
    func getStarted() {
        // Navigate to the next SwiftUI view
    }
}

#Preview {
    if #available(iOS 15.0, *) {
        WelcomeScreenView()
    } else {
        // Fallback on earlier versions
    }
}
