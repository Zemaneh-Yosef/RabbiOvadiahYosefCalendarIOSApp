//
//  ChaiTables.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 8/9/23.
//

import Foundation
import KosherSwift

class ChaiTables {
    
    var chaitableVisibleSunrise: String
    var jewishCalendar = JewishCalendar()
    
    init(locationName: String, jewishCalendar: JewishCalendar, defaults: UserDefaults) {
        chaitableVisibleSunrise = defaults.string(forKey: "visibleSunriseTable\(locationName)\(jewishCalendar.getJewishYear())") ?? ""
        self.jewishCalendar = jewishCalendar
    }
    
    func getVisibleSurise(forDate: Date) -> Date? {
        var hebrewCal = Calendar(identifier: .hebrew)
        hebrewCal.timeZone = jewishCalendar.timeZone
        
        let components = hebrewCal.dateComponents([.month, .day], from: forDate)
            
        var month = components.month ?? 0
        if !jewishCalendar.isJewishLeapYear() && month >= 7 {
            month = month - 1
        }
        let day = components.day ?? 0
        
        let rows = chaitableVisibleSunrise.components(separatedBy: "\n")
        var parsedTable: [[String]] = []

        for row in rows {
            let columns = row.components(separatedBy: ",")
            parsedTable.append(columns)
        }
        
        if parsedTable.isEmpty || parsedTable.count == 1 {
            return nil
        }
        
        let visibleSunrise = parsedTable[day + 1][month]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"

        guard let currentTime = dateFormatter.date(from: visibleSunrise) else {
            return nil // Unable to parse the time string
        }

        let calendar = Calendar.current
        let currentDate = forDate

        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: currentTime)
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)

        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second

        return calendar.date(from: combinedComponents)
    }
}
