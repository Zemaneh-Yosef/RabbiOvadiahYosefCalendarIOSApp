//
//  ZmanimLanguageView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/8/25.
//

import SwiftUI

struct ZmanimLanguageView: View {
    static let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    @AppStorage("isZmanimInHebrew", store: defaults) private var isZmanimInHebrew: Bool = false
    @AppStorage("isZmanimEnglishTranslated", store: defaults) private var isZmanimEnglishTranslated: Bool = false
    @AppStorage("isSetup", store: defaults) private var isSetup: Bool = false
    @AppStorage("hasShownTipScreen", store: defaults) private var hasShownTipScreen: Bool = false

    @Environment(\.dismiss) var dismiss
    @State private var imageName: String = ""
    @State var showNextView = false
    @State var nextView = NextSetupView.tipScreen

    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()

            VStack(alignment: .leading, spacing: 20) {
                languageButton(label: "Hebrew", systemImage: isZmanimInHebrew ? "largecircle.fill.circle" : "circle") {
                    isZmanimInHebrew = true
                    isZmanimEnglishTranslated = false
                    updateImage()
                }

                languageButton(label: "English", systemImage: !isZmanimInHebrew ? "largecircle.fill.circle" : "circle") {
                    isZmanimInHebrew = false
                    isZmanimEnglishTranslated = false
                    updateImage()
                }

                languageButton(label: "Translated", systemImage: isZmanimEnglishTranslated ? "checkmark.square.fill" : "square", disabled: isZmanimInHebrew) {
                    isZmanimInHebrew = false
                    isZmanimEnglishTranslated.toggle()
                    updateImage()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading) // ← align VStack to leading

            Button {
                confirmSelection()
            } label: {
                Text("Confirm")
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(Color.white)
            }
        }
        .padding()
        .navigationTitle("Zemanim Language")
        .onAppear {
            isZmanimInHebrew = ZmanimLanguageView.defaults.bool(forKey: "isZmanimInHebrew")
            isZmanimEnglishTranslated = ZmanimLanguageView.defaults.bool(forKey: "isZmanimEnglishTranslated")
            updateImage()
        }
        .background {
            NavigationLink("", isActive: $showNextView) {
                switch nextView {
                case .tipScreen:
                    TipScreenView().applyToolbarHidden()
                default:
                    EmptyView()
                }
            }.hidden()
        }
    }

    private func languageButton(label: String, systemImage: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: systemImage)
        }
        .disabled(disabled)
    }

    private func updateImage() {
        if isZmanimInHebrew {
            imageName = "hebrew"
        } else if isZmanimEnglishTranslated {
            imageName = "translated"
        } else {
            imageName = "english"
        }
    }

    private func confirmSelection() {
        isSetup = true
        if !hasShownTipScreen {
            hasShownTipScreen = true
            nextView = .tipScreen
            showNextView = true
        } else {
            goBackToRootView()
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
    ZmanimLanguageView()
}
