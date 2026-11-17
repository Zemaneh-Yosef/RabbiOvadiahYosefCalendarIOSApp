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
    let dateFormatterForJer = DateFormatter()
    
    @State var userChosenDate: Date = GlobalStruct.userChosenDate
    @State var datePickerIsVisible = false
    @State var hebrewDatePickerIsVisible = false
    
    init() {
        if Locale.isHebrewLocale() {
            dateFormatter.dateFormat = "E MMM d H:mm:ss"
            dateFormatterForJer.dateFormat = "E MMM d H:mm:ss"
        } else {
            dateFormatter.dateFormat = "E MMM d h:mm:ss a"
            dateFormatterForJer.dateFormat = "E MMM d h:mm:ss a"
        }
        dateFormatterForJer.timeZone = TimeZone(identifier: "Asia/Jerusalem")
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
                Image("molad_sky")
                    .resizable()
                    .scaledToFill()
                    .overlay { DriftingCloudsView() }
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
                
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
                        Text("Molad for This Month (Jerusalem Time Zone)")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                        Text(dateFormatterForJer.string(from: GlobalStruct.jewishCalendar.getMoladAsDate()))
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.yellow)
                    }
                    .padding()
                    .background(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.5))
                    }
                    
                    VStack {
                        Text("Molad for This Month (Your Time Zone)")
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
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
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

/// Draws two seamlessly tiling cloud layers over the molad sky (molad_sky) and drifts them to the right, forever:
/// the clouds near the bottom (faster) and the wispy band near the top (slower, for a sense of depth). A small, fixed picture
/// of the moon is drawn last so the wisps always pass behind the moon and never over it.
///
/// Each cloud image is exactly one loop wide, so when the animation wraps around the picture is identical and there is no
/// visible jump. Everything is positioned with the same aspect-fill math as the sky image underneath, so the layers stay lined
/// up with the sky on every screen size. The clouds stay still when Reduce Motion is on.
struct DriftingCloudsView: View {
    /// The size of the background image (molad_sky) that these layers sit on.
    private static let backgroundSize = CGSize(width: 720, height: 1280)
    /// One full cycle of the animation. Each layer finishes a whole number of loops in a cycle, so everything wraps together.
    private static let cycleDuration: TimeInterval = 150
    /// Where (in background pixels) the moon picture belongs.
    private static let moonRect = CGRect(x: 405, y: 295, width: 260, height: 260)

    private struct Layer {
        let imageName: String
        /// The size of the image in background pixels; its width is one loop.
        let size: CGSize
        /// The row of the background image where the top of the image belongs.
        let top: CGFloat
        /// How many times the image loops in one cycle. Higher is faster.
        let loopsPerCycle: Double
    }

    /// Wisps first so the lower clouds are drawn over them; the wisps drift at half the speed of the clouds.
    private static let layers = [
        Layer(imageName: "molad_wisps", size: CGSize(width: 640, height: 518), top: 30, loopsPerCycle: 1),
        Layer(imageName: "molad_clouds", size: CGSize(width: 600, height: 740), top: 540, loopsPerCycle: 2)
    ]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let cycle = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: Self.cycleDuration) / Self.cycleDuration
            Canvas { context, size in
                draw(in: &context, size: size, cycle: cycle)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func draw(in context: inout GraphicsContext, size: CGSize, cycle: Double) {
        guard size.width > 0, size.height > 0 else { return }
        let bg = Self.backgroundSize

        // the same scaling and centering that aspect-fill does for the sky image
        let scale = max(size.width / bg.width, size.height / bg.height)
        let left = (size.width - bg.width * scale) / 2
        let top = (size.height - bg.height * scale) / 2
        let visibleStart = -left / scale         // background x at the left edge of the screen
        let visibleEnd = (size.width - left) / scale

        context.translateBy(x: left, y: top)
        context.scaleBy(x: scale, y: scale)

        for layer in Self.layers {
            let image = context.resolve(Image(layer.imageName))
            let tileWidth = layer.size.width
            let phase = (cycle * layer.loopsPerCycle).truncatingRemainder(dividingBy: 1)
            let shift = phase * tileWidth        // in background pixels, grows to the right
            // draw as many copies of the tile as it takes to cover the screen, starting from the one that holds visibleStart
            var x = shift + ((visibleStart - shift) / tileWidth).rounded(.down) * tileWidth
            while x < visibleEnd {
                context.draw(image, in: CGRect(x: x, y: layer.top, width: tileWidth, height: layer.size.height))
                x += tileWidth
            }
        }
        // fixed, on top, so the wisps pass behind the moon
        context.draw(context.resolve(Image("molad_moon")), in: Self.moonRect)
    }
}

#Preview {
    MoladView()
}
