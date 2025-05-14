//
//  AdvancedSetupView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/8/25.
//

import SwiftUI
import WebKit
import KosherSwift

struct AdvancedSetupView: View {
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    @State private var link: String = ""
    @State private var showWebView = false
    @State private var urlToLoad: URL = URL(string: "https://chaitables.com")!
    @State private var showAlert = false
    @State private var showNextView = false

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text("Please go to chaitables.com and create a table of the current year for the area you specified. Then copy the link/address of the table and enter it here:")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextField("https://chaitables.com/...", text: $link)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button {
                    setVisibleSunriseForThisLocation(true)
                    guard !link.trimmingCharacters(in: .whitespaces).isEmpty,
                          let _ = URL(string: link)
                    else { return }
                    
                    startScrape(with: link)
                } label: {
                    Text("Set Link")
                    Image(systemName: "calendar.badge.checkmark")
                }
                .foregroundStyle(.black)
                .font(.title3.bold())
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("Gold"), Color("GoldStart"), Color("Gold")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text("Or")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button {
                    setVisibleSunriseForThisLocation(true)
                    urlToLoad = Locale.isHebrewLocale() ? URL(string: "https://chaitables.com/chai_heb.php")! : URL(string: "https://bit.ly/3rhS55b")!
                    showAlert = true
                } label: {
                    Text("Go to the website in the app")
                    Image(systemName: "platter.filled.top.iphone")
                }
                .foregroundStyle(.black)
                .font(.title3.bold())
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("Gold"), Color("GoldStart"), Color("Gold")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button {
                    setVisibleSunriseForThisLocation(false)
                    showNextView = true
                } label: {
                    Text("Skip")
                }
                .buttonStyle(FilledButtonStyle(color: .gray.opacity(0.3)))
            }
            .background {
                NavigationLink(destination: SetupElevationView(), isActive: $showNextView) { EmptyView() }.hidden()
            }
            .sheet(isPresented: $showWebView) {
                WebView(url: $urlToLoad, onScrapeDetected: handleScrapeFromWeb)
            }
            .alert("How to get info from chaitables.com".localized(), isPresented: $showAlert) {
                Button("OK") {
                    showWebView = true
                }
            } message: {
                Text(Locale.isHebrewLocale()
                     ? "(אני ממליץ לך לבקר קודם באתר.) בחר את האזור שלך ובעמוד הבא כל מה שאתה צריך לעשות הוא למלא את שלבים 1 ו-2, וללחוץ על הכפתור כדי לחשב את הטבלאות בתחתית העמוד .ודא שרדיוס החיפוש שלך גדול מספיק ועזוב את השנה היהודית בשקט. האפליקציה תעשה את השאר."
                     : "(I recommend you visit the website first.) \n\n Choose your area and on the next page all you need to do is to fill out steps 1 and 2, choose visible sunrise, and click the button on the bottom of the page to calculate the tables. \n\n Just make sure your search radius is big enough and the app will do the rest.")
            }
        }
    }
    
    func setVisibleSunriseForThisLocation(_ useMishor: Bool) {
        defaults.set(useMishor, forKey: "useMishorSunrise".appending(GlobalStruct.geoLocation.locationName))
    }

    func startScrape(with rawLink: String) {
        let chaitables = ChaiTablesScraper(
            link: rawLink,
            locationName: GlobalStruct.geoLocation.locationName,
            jewishYear: JewishCalendar().getJewishYear(),
            defaults: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? .standard
        )

        chaitables.scrape {
            chaitables.jewishYear += 1
            chaitables.link = chaitables.link.replacingOccurrences(of: "&cgi_yrheb=\(JewishCalendar().getJewishYear())", with: "&cgi_yrheb=\(JewishCalendar().getJewishYear() + 1)")
            chaitables.scrape {
                showNextView = true
            }
        }
    }

    func handleScrapeFromWeb(urlString: String) {
        let corrected = assertCorrectURL(url: urlString)
        startScrape(with: corrected)
    }

    func assertCorrectURL(url: String) -> String {
        return url
            .replacingOccurrences(of: "&cgi_types=-1", with: "&cgi_types=0")
            .replacingOccurrences(of: "&cgi_types=1", with: "&cgi_types=0")
            .replacingOccurrences(of: "&cgi_types=2", with: "&cgi_types=0")
            .replacingOccurrences(of: "&cgi_types=3", with: "&cgi_types=0")
            .replacingOccurrences(of: "&cgi_types=4", with: "&cgi_types=0")
            .replacingOccurrences(of: "&cgi_types=5", with: "&cgi_types=0")
            .replacingOccurrences(of: "&cgi_optionheb=0", with: "&cgi_optionheb=1")
            .replacingOccurrences(of: "&cgi_Language=Hebrew", with: "&cgi_Language=English")
    }
}

struct WebView: UIViewRepresentable {
    @Binding var url: URL
    var onScrapeDetected: (String) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            guard let urlStr = webView.url?.absoluteString else { return }

            if urlStr.starts(with: "http://chaitables.com/cgi-bin/") {
                parent.onScrapeDetected(urlStr)
            }
        }
    }
}


#Preview {
    AdvancedSetupView()
}
