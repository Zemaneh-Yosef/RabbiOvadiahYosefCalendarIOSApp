//
//  ZmanimLanguageView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/8/25.
//

import SwiftUI

struct ZmanimLanguageView: View {
    static let defaults = UserDefaults.getMyUserDefaults()
    @AppStorage("isZmanimInHebrew", store: defaults) private var isZmanimInHebrew: Bool = false
    @AppStorage("isZmanimEnglishTranslated", store: defaults) private var isZmanimEnglishTranslated: Bool = false
    @AppStorage("isZmanimAmericanized", store: defaults) private var isZmanimAmericanized: Bool = false
    @AppStorage("isSetup", store: defaults) private var isSetup: Bool = false
    @AppStorage("hasShownTipScreen", store: defaults) private var hasShownTipScreen: Bool = false

    @Environment(\.dismiss) var dismiss
    @State var showNextView = false
    @State var nextView = NextSetupView.tipScreen
    @State var selectedEnglish = "Transliteration (Sepharadic Articulation)"

    var body: some View {
        VStack {
            Spacer()
            Text("What language would you like the zemanim to be in?")
                .bold()
                .multilineTextAlignment(.center)
                .font(.largeTitle)
            Spacer()
            List(ZmanimFactory.getDemoZmanim(isZmanimInHebrew: isZmanimInHebrew, isZmanimEnglishTranslated: isZmanimEnglishTranslated, isZmanimAmericanized: isZmanimAmericanized), id: \.self) { zmanEntry in
                Button {
                    // do nothing
                } label: {
                    HStack {
                        if isZmanimInHebrew {
                            Text("XX:XX")
                                .font(.system(size: 20, weight: .regular))
                            Spacer()
                            Text(zmanEntry.title)
                                .font(.system(size: 20, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        } else {
                            Text(zmanEntry.title)
                                .font(.system(size: 20, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            Spacer()
                            Text("XX:XX")
                                .font(.system(size: 20, weight: .regular))
                        }
                    }
                }
            }
            .listStyle(.plain)
            .frame(maxHeight: 200)
            
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Button {
                    isZmanimInHebrew = true
                    isZmanimEnglishTranslated = false
                    isZmanimAmericanized = false
                } label: {
                    Label("Hebrew", systemImage: isZmanimInHebrew ? "largecircle.fill.circle" : "circle")
                }

                HStack {
                    Button {
                        isZmanimInHebrew = false
                        isZmanimEnglishTranslated = false
                        isZmanimAmericanized = false
                    } label: {
                        Label("English", systemImage: !isZmanimInHebrew ? "largecircle.fill.circle" : "circle")
                    }
                    Menu {
                        Button("Translation") {
                            isZmanimInHebrew = false
                            isZmanimEnglishTranslated = true
                            isZmanimAmericanized = false
                            selectedEnglish = "Translation"
                        }
                        Button("Transliteration (Sepharadic Articulation)") {
                            isZmanimInHebrew = false
                            isZmanimEnglishTranslated = false
                            isZmanimAmericanized = false
                            selectedEnglish = "Transliteration (Sepharadic Articulation)"
                        }
                        Button("Transliteration (American Articulation)") {
                            isZmanimInHebrew = false
                            isZmanimEnglishTranslated = false
                            isZmanimAmericanized = true
                            selectedEnglish = "Transliteration (American Articulation)"
                        }
                    } label: {
                        Text(selectedEnglish)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading) // ← align VStack to leading
            
            Spacer()

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
            isZmanimAmericanized = ZmanimLanguageView.defaults.bool(forKey: "isZmanimAmericanized")
            if isZmanimEnglishTranslated {
                selectedEnglish = "Translation"
            } else if isZmanimAmericanized {
                selectedEnglish = "Transliteration (American Articulation)"
            } else {
                selectedEnglish = "Transliteration (Sepharadic Articulation)"
            }
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
