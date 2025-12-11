//
//  InIsraelView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 4/7/25.
//

import SwiftUI

struct InIsraelView: View {
    let defaults = UserDefaults.getMyUserDefaults()
    @State private var inIsrael: Bool? = nil
    @State var showNextView = false
    @Environment(\.dismiss) private var dismiss
    @State var nextView = NextSetupView.zmanimLanguage
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Are you currently in Israel?")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 40) {
                Button(action: {
                    inIsrael = true
                    presentNextView()
                }) {
                    Text("Yes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(alignment: .center) {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        }
                }

                Button(action: {
                    inIsrael = false
                    presentNextView()
                }) {
                    Text("No")
                        .font(.headline)
                        .foregroundStyle(Color.black)
                        .frame(width: 100, height: 100) // square shape
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow.opacity(0.85), Color.yellow]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(alignment: .center) {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        }
                }
            }
        }
        .padding()
        NavigationLink("", isActive: $showNextView) {
            switch nextView {
            case .zmanimLanguage:
                ZmanimLanguageView().applyToolbarHidden()
            case .tipScreen:
                TipScreenView().applyToolbarHidden()
            default:
                EmptyView()
            }
        }.hidden()
    }
    
    func presentNextView() {
        defaults.set(inIsrael.unsafelyUnwrapped, forKey: "inIsrael")
        defaults.set(!inIsrael.unsafelyUnwrapped, forKey: "LuachAmudeiHoraah")
        defaults.set(inIsrael.unsafelyUnwrapped, forKey: "useElevation")
        
        if Locale.isHebrewLocale() {
            defaults.set(true, forKey: "isZmanimInHebrew")
            defaults.set(false, forKey: "isZmanimEnglishTranslated")
            defaults.set(true, forKey: "isSetup")
            if !defaults.bool(forKey: "hasShownTipScreen") {
                nextView = .tipScreen
                showNextView = true
                defaults.set(true, forKey: "hasShownTipScreen")
            } else {
                goBackToRootView()
            }
        } else {
            nextView = .zmanimLanguage
            showNextView = true
        }
    }
    
    private func goBackToRootView() {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
          return
        }
        guard let firstWindow = firstScene.windows.first else {
          return
        }
        firstWindow.rootViewController = UIHostingController(rootView: ContentView())
        firstWindow.makeKeyAndVisible()
    }
}


#Preview {
    InIsraelView()
}
