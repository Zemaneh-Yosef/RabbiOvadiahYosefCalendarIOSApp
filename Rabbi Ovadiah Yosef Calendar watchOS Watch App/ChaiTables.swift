//
//  ChaiTables.swift
//  Rabbi Ovadiah Yosef Calendar watchOS Watch App
//
//  Created by User on 11/16/23.
//

import Foundation

class ChaiTables {
    
    var chaitableVisibleSunrise: String
    
    init(locationName: String, jewishYear: Int, defaults: UserDefaults) {
        chaitableVisibleSunrise = defaults.string(forKey: "visibleSunriseTable\(locationName)\(jewishYear)") ?? ""
    }
    
    func getVisibleSurise(forDate: Date) -> Date? {
        let hebrewCal = Calendar(identifier: .hebrew)
        
        let components = hebrewCal.dateComponents([.month, .day], from: forDate)
            
        var month = components.month ?? 0
        if month >= 7 {
            month = month - 1
        }
        let day = components.day ?? 0
        
        let rows = chaitableVisibleSunrise.components(separatedBy: "\n")
        var parsedTable: [[String]] = []

        for row in rows {
            let columns = row.components(separatedBy: ",")
            parsedTable.append(columns)
        }
        
        if parsedTable.count == 1 {
            return nil
        }
        
        let visibleSunnrise = parsedTable[day + 1][month]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"

        guard let currentTime = dateFormatter.date(from: visibleSunnrise) else {
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
