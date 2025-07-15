//
//  NetzView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 2/20/25.
//

import SwiftUI
import Combine
import KosherSwift

class NetzViewModel: ObservableObject {
    @Published var countdownText: String = "Calculating...".localized()
    private var timer: AnyCancellable?
    private let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard

    init() {
        getNextNetzAndStartCountdown()
    }

    func getNextNetzAndStartCountdown() {
        let zmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
        zmanimCalendar.geoLocation.elevation = 0 // Ensure elevation is considered
        let jewishCalendar = JewishCalendar()
        
        var netz = ChaiTables(
            locationName: GlobalStruct.geoLocation.locationName,
            jewishCalendar: jewishCalendar,
            defaults: defaults
        ).getVisibleSurise(forDate: zmanimCalendar.workingDate)
        
        if netz == nil {
            netz = zmanimCalendar.getSeaLevelSunrise()
        }
        
        // If the time is in the past, adjust to the next day
        if netz?.timeIntervalSinceNow ?? 0 < 0 {
            zmanimCalendar.workingDate = Calendar.current.date(byAdding: .day, value: 1, to: zmanimCalendar.workingDate)!
            jewishCalendar.workingDate = zmanimCalendar.workingDate
            
            netz = ChaiTables(
                locationName: GlobalStruct.geoLocation.locationName,
                jewishCalendar: jewishCalendar,
                defaults: defaults
            ).getVisibleSurise(forDate: zmanimCalendar.workingDate) ?? zmanimCalendar.getSeaLevelSunrise()
        }
        
        startCountdown(netz: netz ?? Date())
    }

    func startCountdown(netz: Date) {
        let netzNames = ZmanimTimeNames(
            mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"),
            mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")
        )
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.unitsStyle = .short
        
        timer?.cancel() // Cancel any existing timer
        let targetTime = netz.timeIntervalSinceReferenceDate
        
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                let now = Date().timeIntervalSinceReferenceDate
                let secondsRemaining = max(0, targetTime - now)
                
                if secondsRemaining > 0 {
                    self?.countdownText = netzNames.getHaNetzString()
                        .appending(netzNames.getIsInString())
                        .appending("\n\n")
                        .appending(formatter.string(from: secondsRemaining) ?? "")
                } else {
                    self?.timer?.cancel()
                    self?.countdownText = "Netz/Sunrise has passed. Count will automatically restart at sunset. Swipe down to restart.".localized()
                    self?.setTimerForSunset()
                }
            }
    }

    func setTimerForSunset() {
        let sunset = ComplexZmanimCalendar(location: GlobalStruct.geoLocation).getElevationAdjustedSunset()
        guard let sunsetTimeLeft = sunset?.timeIntervalSinceNow, sunsetTimeLeft > 0 else {
            getNextNetzAndStartCountdown()
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + sunsetTimeLeft) { [weak self] in
            self?.getNextNetzAndStartCountdown()
        }
    }
}

@available(iOS 15.0, *)
struct NetzView: View {
    @StateObject private var viewModel = NetzViewModel()

    var body: some View {
        VStack {
            Spacer()
            Text(viewModel.countdownText)
                .bold()
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundStyle(Color.yellow)
            Spacer()
        }
        .gesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .local)
                .onEnded { gesture in
                    if gesture.translation.height > 0 { // Swipe down
                        viewModel.getNextNetzAndStartCountdown()
                    }
                }
        )
    }
}


#Preview {
    if #available(iOS 15.0, *) {
        NetzView()
    } else {
        // Fallback on earlier versions
    }
}

// //
// //  NetzView.swift
// //  Rabbi Ovadiah Yosef Calendar
// //
// //  Created by Elyahu Jacobi on 2/20/25.
// //
//
//import SwiftUI
//import Combine
//import KosherSwift
//
//class NetzViewModel: ObservableObject {
//    @Published var countdownText: String = "Calculating..."
//    @Published var isUsingChaiTables: Bool = false
//    @Published var progressToNetz: Double = 0.0
//    private var timer: AnyCancellable?
//    private let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
//    
//    init() {
//        getNextNetzAndStartCountdown()
//    }
//    
//    func getNextNetzAndStartCountdown() {
//        let zmanimCalendar = ComplexZmanimCalendar(location: GlobalStruct.geoLocation)
//        zmanimCalendar.geoLocation.elevation = 0 // Ensure elevation is not considered
//        let jewishCalendar = JewishCalendar()
//        
//        var netz = ChaiTables(
//            locationName: GlobalStruct.geoLocation.locationName,
//            jewishCalendar: jewishCalendar,
//            defaults: defaults
//        ).getVisibleSurise(forDate: zmanimCalendar.workingDate)
//        
//        isUsingChaiTables = netz != nil
//        
//        if !isUsingChaiTables {
//            netz = zmanimCalendar.getSeaLevelSunrise()
//        }
//        
//        // If the time is in the past, adjust to the next day
//        if netz?.timeIntervalSinceNow ?? 0 < 0 {
//            zmanimCalendar.workingDate = Calendar.current.date(byAdding: .day, value: 1, to: zmanimCalendar.workingDate)!
//            jewishCalendar.workingDate = zmanimCalendar.workingDate
//            
//            netz = ChaiTables(
//                locationName: GlobalStruct.geoLocation.locationName,
//                jewishCalendar: jewishCalendar,
//                defaults: defaults
//            ).getVisibleSurise(forDate: zmanimCalendar.workingDate) ?? zmanimCalendar.getSeaLevelSunrise()
//        }
//        
//        startCountdown(netz: netz ?? Date())
//    }
//    
//    func startCountdown(netz: Date) {
//        let netzNames = ZmanimTimeNames(
//            mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"),
//            mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")
//        )
//        
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second]
//        formatter.zeroFormattingBehavior = .dropLeading
//        formatter.unitsStyle = .short
//        
//        timer?.cancel() // Cancel any existing timer
//        let targetTime = netz.timeIntervalSinceReferenceDate
//        
//        timer = Timer.publish(every: 1.0, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                let now = Date().timeIntervalSinceReferenceDate
//                let secondsRemaining = max(0, targetTime - now)
//                
//                if secondsRemaining > 0 {
//                    self?.progressToNetz = 1.0 - (secondsRemaining / 86400.0) // 86400 = 24 hours
//                    self?.countdownText = netzNames.getHaNetzString()
//                        .appending(netzNames.getIsInString())
//                        .appending("\n\n")
//                        .appending(formatter.string(from: secondsRemaining) ?? "")
//                } else {
//                    self?.timer?.cancel()
//                    self?.countdownText = "Netz/Sunrise has passed. Count will automatically restart at sunset. Swipe down to restart.".localized()
//                    self?.setTimerForSunset()
//                }
//            }
//    }
//
//    func setTimerForSunset() {
//        let sunset = ComplexZmanimCalendar(location: GlobalStruct.geoLocation).getElevationAdjustedSunset()
//        guard let sunsetTimeLeft = sunset?.timeIntervalSinceNow, sunsetTimeLeft > 0 else {
//            getNextNetzAndStartCountdown()
//            return
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + sunsetTimeLeft) { [weak self] in
//            self?.getNextNetzAndStartCountdown()
//        }
//    }
//}
//
//struct NetzView: View {
//    @StateObject private var viewModel = NetzViewModel()
//    
//    var body: some View {
//        ZStack {
//            // Dynamic background
//            AnimatedBackground()
//
//            VStack {
//                Spacer()
//                
//                // Countdown timer with glowing text
//                Text(viewModel.countdownText)
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .shadow(color: .yellow.opacity(0.7), radius: 10, x: 0, y: 0)
//                    .padding()
//                    .foregroundStyle(Color.white)
//                
//                Spacer()
//                
//                // Animated sun that moves up as Netz approaches
//                SunAnimation(progress: viewModel.progressToNetz, isUsingChaiTables: viewModel.isUsingChaiTables)
//
//                Spacer()
//            }
//        }
//        .gesture(
//            DragGesture(minimumDistance: 50, coordinateSpace: .local)
//                .onEnded { gesture in
//                    if gesture.translation.height > 0 { // Swipe down
//                        viewModel.getNextNetzAndStartCountdown()
//                    }
//                }
//        )
//    }
//}
//
//struct AnimatedBackground: View {
//    var body: some View {
//        LinearGradient(gradient: Gradient(colors: [
//            Color(red: 0.05, green: 0.05, blue: 0.1), // Deep dark blue (night fading)
//            Color(red: 0.05, green: 0.05, blue: 0.1), // Deep dark blue (night fading)
//            Color(red: 0.05, green: 0.05, blue: 0.2), // Deep dark blue (night fading)
//            Color(red: 0.2, green: 0.2, blue: 0.4),   // Faint pre-dawn blue
//            Color(red: 0.4, green: 0.3, blue: 0.5),   // Subtle purple transition
//            Color(red: 0.6, green: 0.4, blue: 0.3)    // Faint warm orange glow near the bottom
//        ]),
//        startPoint: .top,
//        endPoint: .bottom)
//        .edgesIgnoringSafeArea(.all)
//    }
//}
//
//
//struct SunAnimation: View {
//    var progress: Double // 0.0 (night) → 1.0 (netz)
//    var isUsingChaiTables: Bool
//
//    var body: some View {
//        ZStack {
//            // Background element (mountain or sea)
//            Image(systemName: isUsingChaiTables ? "mountain.2.fill" : "water.waves")
//                .resizable()
//                .scaledToFit()
//                .frame(height: 200)
//                .offset(y: 50)
//
//            // Sun rising effect
//            Image(systemName: "sun.max.fill")
//                .resizable()
//                .frame(width: 100, height: 100)
//                .shadow(color: .yellow, radius: 10)
//                .offset(y: sunOffset()) // Controls visibility of the sun
//                .animation(.easeInOut(duration: 1), value: progress)
//                .foregroundStyle(Color.yellow)
//                .opacity(progress >= 1.0 ? 1.0 : 0.0) // Fully hidden until Netz
//        }
//    }
//
//    private func sunOffset() -> CGFloat {
//        if progress < 1.0 {
//            return 200 // Keep the sun fully hidden below the horizon
//        } else {
//            return 90 // Show only the top of the sun at Netz
//        }
//    }
//}
//
//#Preview {
//    NetzView()
//}


