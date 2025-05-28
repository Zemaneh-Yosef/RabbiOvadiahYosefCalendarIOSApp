//
//  SetupChooserView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/8/25.
//

import SwiftUI

struct SetupChooserView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showInfo = false
    @State private var navigateToSimple = false
    @State private var navigateToAdvanced = false

    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
            
            Image("yy_quote")
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            Button(action: {
                navigateToSimple = true
            }) {
                Text("Setup your city!")
                    .foregroundStyle(.black)
                    .font(.title.bold())
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
            
            Button("Advanced Setup") {
                navigateToAdvanced = true
            }
            .buttonStyle(FilledButtonStyle(color: .gray.opacity(0.3)))
            
            NavigationLink(destination: SimpleSetupView(), isActive: $navigateToSimple) { EmptyView() }
            NavigationLink(destination: AdvancedSetupView(), isActive: $navigateToAdvanced) { EmptyView() }
        }
        .padding()
        .navigationTitle("Visible Sunrise Setup")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .alert("Introduction".localized(), isPresented: $showInfo) {
            Button("Dismiss".localized(), role: .cancel) {}
        } message: {
            Text(infoMessage)
        }
    }

    var infoMessage: String {
        if Locale.isHebrewLocale() {
            return "ישנם שני אפשרויות להוריד את זמני זריחה הנראים עבור המיקום שלך.\n\nלחיצה על כפתור \"התקן את העיר שלך!\" תקח אותך לדף שישאל אותך לבחור את העיר/האזור שלך.\n\nפעם שבחרת את העיר שלך, הוא יוריד טבלה המפרטת את הזמנים לזריחה הנראית לעתיד הקרוב במשך שנתיים מהאתר ChaiTables.com. האפשרות \"התקנה מתקדמת\" מאפשרת לך לבחור האם ברצונך לספק את כתובת ה-URL שלך לאתר ה-ChaiTables,\n\nאו לנווט באתר בעצמך. ידוע שנתוני זריחה הנראים משתנים עבור כל עיר ועיר, ותצטרך להגדיר מחדש את נתוני הזריחה הנראים של העיר שלך בכל פעם שתשנה ערים."
        } else {
            return "There are 2 options in order to download the visible sunrise times for your location.\n\n Pressing the \"Setup your city!\" button will take you to a page that will ask you to choose your city/area. Once you choose your city, it will download a table that lists the times for VISIBLE sunrise throughout the next 2 years from a website called ChaiTables.com.\n\nThe \"Advanced Setup\" option allows you to choose whether you want to supply your own URL for the chaitables website, or do navigate the website yourself.\n\nKnow that the visible sunrise data changes for each and every city and you will need to set the visible sunrise data of your city every time you change cities."
        }
    }
}

// MARK: - Styles

struct FilledButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct PlainButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 2))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}


#Preview {
    SetupChooserView()
}
