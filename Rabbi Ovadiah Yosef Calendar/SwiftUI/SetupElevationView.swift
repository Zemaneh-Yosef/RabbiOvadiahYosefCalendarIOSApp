//
//  SetupElevationView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/13/25.
//

import SwiftUI

struct SetupElevationView: View {
    @State private var text: String = ""
    @State private var showManualAlert = false
    @State private var showAlert = false
    @State private var alertMessage = "Please only enter numbers and decimals! For example: 30.0".localized()
    @State private var isLoading = false

    private let acceptableCharacters = CharacterSet(charactersIn: "0123456789.")

    var body: some View {
        ZStack {
            ScrollView {
                Text(Locale.isHebrewLocale() ? hebrewText : englishText)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()

                Button {
                    text = "0"
                    handleManualInput()
                } label: {
                    Text("Use Mishor (Sea Level) Sunrise/Sunset")
                        .foregroundStyle(.black)
                        .font(.title3.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("Gold"), Color("GoldStart"), Color("Gold")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    showManualAlert = true
                } label: {
                    Text("Enter Elevation Manually")
                        .foregroundStyle(.black)
                        .font(.title3.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("Gold"), Color("GoldStart"), Color("Gold")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    fetchElevationFromSources()
                } label: {
                    Text("Get From Online")
                        .foregroundStyle(.black)
                        .font(.title3.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("Gold"), Color("GoldStart"), Color("Gold")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .navigationTitle("Setup Elevation")
            .padding()
            .alert("Invalid input", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            .alert("Enter elevation in meters", isPresented: $showManualAlert) {
                TextField(text: $text, prompt: Text("ex: 30.0")) {}
                Button("OK") {
                    handleManualInput()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter elevation in meters")
            }
            if isLoading {
                Color.black.opacity(0.25)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxWidth: .infinity)
                ProgressView("Downloading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundStyle(.white)
            }
        }
    }

    private func handleManualInput() {
        guard !text.isEmpty else { return }

        if CharacterSet(charactersIn: text).isSubset(of: acceptableCharacters) {
            NotificationCenter.default.post(name: NSNotification.Name("elevation"), object: text)
            goBackToRootView()
        } else {
            showAlert = true
        }
    }

    private func fetchElevationFromSources() {
        isLoading = true
        var e1 = 0, e2 = 0, e3 = 0
        var results: [Int] = []
        let group = DispatchGroup()
        let geo = LSGeoLookup(withUserID: "Elyahu41")
        let lat = GlobalStruct.geoLocation.latitude
        let lon = GlobalStruct.geoLocation.longitude

        group.enter()
        geo.findElevationGtopo30(latitude: lat, longitude: lon) { elev in
            if let elev = elev { e1 = Int(truncating: elev) }
            group.leave()
        }

        group.enter()
        geo.findElevationSRTM3(latitude: lat, longitude: lon) { elev in
            if let elev = elev { e2 = Int(truncating: elev) }
            group.leave()
        }

        group.enter()
        geo.findElevationAstergdem(latitude: lat, longitude: lon) { elev in
            if let elev = elev { e3 = Int(truncating: elev) }
            group.leave()
        }

        group.notify(queue: .main) {
            if e1 > 0 { results.append(e1) }
            if e2 > 0 { results.append(e2) }
            if e3 > 0 { results.append(e3) }

            let count = max(results.count, 1)
            let average = Double(e1 + e2 + e3) / Double(count)
            NotificationCenter.default.post(name: NSNotification.Name("elevation"), object: String(average))
            isLoading = false
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

    private var englishText: String {
        """
        Rabbi Asher Darshan (who was on the team for the Ohr HaChaim calendar in Israel) told me that Rabbi Ovadiah Yosef ZT\"L held that the actual sunrise/sunset that should be used for calculating zmanim is when sunrise/sunset is seen at the highest point in the city. However, Rabbi David Yosef Shlita writes that many have told him that Rabbi Ovadiah ZT\"L held to use Mishor (Sea Level) sunrise/sunset. Rabbi Leeor Dahan says that it makes sense to use elevation in cities that have hills, and to not use it when the city, E.G. New York, is close to sea level. You can use the buttons below to choose the appropriate settings that you want. (See Halacha Berura vol. 14, in Otzrot Yosef (Kuntrus Ki Ba Hashemesh), Siman 6, Perek 21 for an in depth discussion)
        """
    }

    private var hebrewText: String {
        """
        הרב אשר דרשן (שהיה בצוות לוח אור החיים בישראל) אמר לי שהרב עובדיה יוסף זצ\"ל סבר כי זמן הזריחה/שקיעה שיש להשתמש בו לחישוב הזמנים הוא כאשר הזריחה/שקיעה נראית בנקודה הגבוהה ביותר בעיר. עם זאת, הרב דוד יוסף שליט\"א כותב שרבים אמרו לו שהרב עובדיה זצ\"ל סבר שיש להשתמש בזריחה/שקיעה לפי מישור (גובה פני הים). הרב ליאור דהן אומר שהגיוני להשתמש בגובה בערים שיש בהן גבעות, ולא להשתמש בו כאשר העיר, למשל ניו יורק, קרובה לגובה פני הים. ניתן להשתמש בכפתורים למטה כדי לבחור את ההגדרות המתאימות עבורכם. (ראו הלכה ברורה חלק י\"ד, באוצרות יוסף (קונטרוס כי בא השמש), סימן ו', פרק כ\"א לדיון מעמיק)
        """
    }
}

#Preview {
    SetupElevationView()
}
