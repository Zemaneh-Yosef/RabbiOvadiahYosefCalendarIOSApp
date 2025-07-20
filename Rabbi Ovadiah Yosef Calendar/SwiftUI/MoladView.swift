//
//  MoladView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 2/19/25.
//

import SwiftUI

struct MoladView: View {
    @State var englishMonth = ""
    @State var hebrewMonth = ""
    let dateFormatter = DateFormatter()
    
    @State var userChosenDate: Date = GlobalStruct.userChosenDate
    @State var datePickerIsVisible = false
    @State var hebrewDatePickerIsVisible = false
    
    init() {
        if Locale.isHebrewLocale() {
            dateFormatter.dateFormat = "E MMM d H:mm:ss"
        } else {
            dateFormatter.dateFormat = "E MMM d h:mm:ss a"
        }
    }
    
    func getMoladAnnouncement() -> String {
        GlobalStruct.jewishCalendar.calculateMolad()
        return String(GlobalStruct.jewishCalendar.moladHours) + "h:".localized() + String(GlobalStruct.jewishCalendar.moladMinutes) + "m and ".localized() + String(GlobalStruct.jewishCalendar.moladChalakim) + " Chalakim".localized()
    }
    
    func getEnglishMonth() -> String {
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        return monthFormatter.string(from: GlobalStruct.jewishCalendar.workingDate)
    }
    
    func getHebrewMonth() -> String {
        let hebrewMonthFormatter = DateFormatter()
        hebrewMonthFormatter.calendar = Calendar.init(identifier: .hebrew)
        hebrewMonthFormatter.dateFormat = "MMMM"
        return hebrewMonthFormatter.string(from: GlobalStruct.jewishCalendar.workingDate)
            .replacingOccurrences(of: "Heshvan", with: "Cheshvan")
            .replacingOccurrences(of: "Tamuz", with: "Tammuz")
    }
    
    func syncCalendarDates() {//with userChosenDate
        GlobalStruct.jewishCalendar.workingDate = userChosenDate
        GlobalStruct.userChosenDate = userChosenDate
        englishMonth = getEnglishMonth()
        hebrewMonth = getHebrewMonth()
    }
    
    func alerts(view: any View) -> some View {
        let result = view.overlay {
            ZStack {
                if datePickerIsVisible {
                    VStack {
                        DatePicker("", selection: $userChosenDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .onChange(of: userChosenDate) { newValue in
                                syncCalendarDates()
                            }
                        HStack {
                            Button {
                                withAnimation {
                                    datePickerIsVisible.toggle()
                                    hebrewDatePickerIsVisible.toggle()
                                }
                            } label: {
                                Text("Change Calendar")
                            }
                            Spacer()
                            Button {
                                withAnimation {
                                    datePickerIsVisible.toggle()
                                }
                            } label: {
                                Text("Done")
                            }
                        }.padding()
                    }.frame(width: 320)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .foregroundColor(Color(UIColor.secondarySystemBackground))
                                .shadow(radius: 1)
                        }
                }
                if hebrewDatePickerIsVisible {
                    VStack {
                        DatePicker("", selection: $userChosenDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .environment(\.locale, Locale(identifier: "he"))
                            .environment(\.calendar, Calendar(identifier: .hebrew))
                            .onChange(of: userChosenDate) { newValue in
                                syncCalendarDates()
                            }
                        HStack {
                            Button {
                                withAnimation {
                                    hebrewDatePickerIsVisible.toggle()
                                    datePickerIsVisible.toggle()
                                }
                            } label: {
                                Text("Change Calendar")
                            }
                            Spacer()
                            Button {
                                withAnimation {
                                    hebrewDatePickerIsVisible.toggle()
                                }
                            } label: {
                                Text("Done")
                            }
                        }.padding()
                    }.frame(width: 320)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .foregroundColor(Color(UIColor.secondarySystemBackground))
                                .shadow(radius: 1)
                        }
                }
            }
        }
        return AnyView(result)
    }
    
    var body: some View {
        alerts(view:
                ScrollView {
            ZStack {
                Image("molad_background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    HStack {
                        VStack {
                            Text(englishMonth)
                                .font(.title2)
                                .foregroundStyle(Color.white)
                            Text(String(Calendar.current.dateComponents([.year], from: userChosenDate).year ?? 1))
                                .foregroundStyle(Color.white)
                        }
                        Button(action: {
                            withAnimation {
                                datePickerIsVisible.toggle()
                            }
                        }) {
                            Image(systemName: "pencil.circle.fill").resizable().frame(width: 24, height: 24).tint(.white)
                        }
                        .padding(.horizontal)
                        VStack {
                            Text(hebrewMonth)
                                .font(.title2)
                                .foregroundStyle(Color.white)
                            Text(String(GlobalStruct.jewishCalendar.getJewishYear()))
                                .foregroundStyle(Color.white)
                        }
                    }
                    .padding()
                    .background(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.5))
                    }
                    .onTapGesture {
                        withAnimation {
                            datePickerIsVisible.toggle()
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Molad Time Announced")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                        Text(getMoladAnnouncement())
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.yellow)
                    }
                    .padding()
                    .background(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.5))
                    }
                    
                    VStack {
                        Text("Molad for This Month (Your Timezone)")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                        Text(dateFormatter.string(from: GlobalStruct.jewishCalendar.getMoladAsDate()))
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.yellow)
                    }
                    .padding()
                    .background(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.5))
                    }
                    
                    VStack {
                        Text("Earliest Birchat Halevana (7 days)")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                        Text(dateFormatter.string(from: GlobalStruct.jewishCalendar.getTchilasZmanKidushLevana7Days()))
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.yellow)
                        
                        Divider().background(Color.white)
                        
                        Text("Latest Birchat Halevana (15 days)")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                        Text("The Whole 15th Night of the Hebrew Month")
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .foregroundStyle(Color.yellow)
                    }
                    .padding()
                    .background(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    Text("Disclaimer: Times are just for reference, you should ask a rav if you can say the bracha earlier or later.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.teal)
                        .padding(.bottom, 10)
                }
                .padding()
            }.onAppear {
                syncCalendarDates()
            }
            .onTapGesture {// dismiss the datepickers if the user taps elsewhere while they are up
                withAnimation {
                    if datePickerIsVisible {
                        datePickerIsVisible.toggle()
                    }
                    if hebrewDatePickerIsVisible {
                        hebrewDatePickerIsVisible.toggle()
                    }
                }
            }
        }
            .navigationTitle("Molad Calculator")
        )
    }
}

#Preview {
    MoladView()
}
