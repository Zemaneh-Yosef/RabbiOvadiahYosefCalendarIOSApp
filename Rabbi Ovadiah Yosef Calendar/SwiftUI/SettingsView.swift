//
//  SettingsView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 2/24/25.
//

import SwiftUI
import MessageUI

@available(iOS 15.0, *)
struct SettingsView: View {
    
    private let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? .standard

    @AppStorage("zmanimNotifications", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var zmanimNotifications: Bool = false
    @AppStorage("showSeconds", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var showSeconds: Bool = false
    @AppStorage("alwaysShowRT", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var alwaysShowRT: Bool = false
    @AppStorage("roundUpRT", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var roundUpRT: Bool = false
    @AppStorage("showWhenShabbatChagEnds", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var showWhenShabbatChagEnds: Bool = false
    @AppStorage("showRegularWhenShabbatChagEnds", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var showRegularWhenShabbatChagEnds: Bool = false
    @AppStorage("showRTWhenShabbatChagEnds", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var showRTWhenShabbatChagEnds: Bool = false
    @AppStorage("alwaysShowMishorSunrise", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var alwaysShowMishorSunrise: Bool = false
    @AppStorage("showShmita", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var showShmita: Bool = false
    @AppStorage("showShabbatMevarchim", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var showShabbatMevarchim: Bool = false
    @AppStorage("setElevationToLastKnownLocation", store: UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar")) private var setElevationToLastKnownLocation: Bool = false

    @State private var showSecondsAlert = false
    @State private var showHaskamotAlert = false
    @State private var showMailView = false
    @State private var showCantSendAlert = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Zmanim Settings")) {
                    NavigationLink("Change Zmanim Settings", destination: ZmanimSettingsView())
                }
                Section(header: Text("Notifications")) {
                    Toggle("Receive daily zmanim notifications", isOn: $zmanimNotifications)
                    if zmanimNotifications {
                        NavigationLink("Zmanim Notifications Settings", destination: ZmanimNotificationsSettingsView())
                    }
                }
                Section(header: Text("Zmanim Display")) {
                    Toggle("Show seconds?", isOn: $showSeconds)
                        .onChange(of: showSeconds) { value in
                            if value { showSecondsAlert = true }
                        }
                    Toggle("Show Rabbeinu Tam everyday?", isOn: $alwaysShowRT)
                    Toggle("Round up Rabbeinu Tam?", isOn: $roundUpRT)
                }
                Section(header: Text("Shabbat/Chag Settings")) {
                    Toggle("Show when Shabbat/Chag ends the day before?", isOn: $showWhenShabbatChagEnds)
                    if showWhenShabbatChagEnds {
                        Toggle("Show Regular Minutes", isOn: $showRegularWhenShabbatChagEnds)
                        Toggle("Show Rabbeinu Tam", isOn: $showRTWhenShabbatChagEnds)
                    }
                }
                Section(header: Text("Other Settings")) {
                    Toggle("Always show mishor sunrise?", isOn: $alwaysShowMishorSunrise)
                    Toggle("Show year of Shemita cycle?", isOn: $showShmita)
                    Toggle("Show Shabbat Mevarchim?", isOn: $showShabbatMevarchim)
                    Toggle("Set elevation to last known location?", isOn: $setElevationToLastKnownLocation)
                }
                Section(header: Text("Help & Support")) {
                    Button("Contact Developer") { sendEmail() }
                    Button("Haskamot") { showHaskamotAlert = true }
                    Button("Watch Video Guide") { openURL("https://youtu.be/NP1_4kMA-Vs") }
                }
            }
            .navigationTitle("Settings")
            
            .alert("Choose a haskama to view", isPresented: $showHaskamotAlert) {
                Button("Rabbi Elbaz (English)", action: { openURL("https://royzmanim.com/assets/Haskamah.pdf") })
                Button("Rabbi Dahan (Hebrew)", action: { openURL("https://royzmanim.com/assets/%D7%94%D7%A1%D7%9B%D7%9E%D7%94.pdf") })
                Button("Dismiss", role: .cancel, action: {})
            } message: {
                Text("Multiple rabbanim have given their haskama/approval to this app. Choose which one you would like to view.")
            }
            .textCase(nil)
            
            .alert("Do not rely on these seconds!".localized(), isPresented: $showSecondsAlert) {
                Button("Dismiss", role: .cancel) { }
            } message: {
                Text("DO NOT RELY ON THESE SECONDS. The only zman that can be relied on to the second is the visible sunrise time based on chaitables.com. Otherwise, these zmanim are NOT accurate to the second! You should always round up or down a minute or two just in case.".localized())
            }
            .textCase(nil)
            
            .alert("Cannot Send Email".localized(), isPresented: $showCantSendAlert) {
                Button("Dismiss", role: .cancel) { }
            } message: {
                Text("Your device is not configured to send emails. Please send an email from another device to ElyahuJacobi@gmail.com")
            }
            .textCase(nil)
            
            .sheet(isPresented: $showMailView) {
                MailView(recipient: "elyahujacobi@gmail.com")
            }
        }
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            showMailView = true
        } else {
            showCantSendAlert = true
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    let recipient: String

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) {
                self.parent.presentation.wrappedValue.dismiss()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setSubject("Zmanei Yosef (iOS)".localized())
        mailComposer.setToRecipients([recipient])
        return mailComposer
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

#Preview {
    if #available(iOS 15.0, *) {
        SettingsView()
    } else {
        // Fallback on earlier versions
    }
}
