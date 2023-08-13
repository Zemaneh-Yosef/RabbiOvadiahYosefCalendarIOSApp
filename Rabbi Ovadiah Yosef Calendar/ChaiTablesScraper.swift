//
//  ChaiTablesScraper.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Macbook Pro on 8/7/23.
//

import Foundation
import SwiftSoup

class ChaiTablesScraper {
    
    var link: String
    var locationName: String
    var jewishYear: Int
    var defaults: UserDefaults
    var errored: Bool
    
    init(link: String, locationName: String, jewishYear: Int, defaults: UserDefaults) {
        self.link = link
        self.locationName = locationName
        self.jewishYear = jewishYear
        self.defaults = defaults
        self.errored = false
    }
    
    func scrape() {
        DispatchQueue.global().async { [self] in
            let url2 = URL(string:link)
            do {
                let html = try String(contentsOf: url2!)
                let doc: Document = try SwiftSoup.parse(html)
                if try doc.text().contains("You can increase the search radius and try again") {
                    errored = true
                    return
                }
                
                let tables = try doc.select("table").array()
                
                guard tables.count >= 5 else {
                    print("No table found")
                    errored = true
                    return
                }
                
                let table = tables[4] // Assuming the HTML has at least 5 tables
                
                var csv = ""
                
                // Process table headers
                let headerRow = try table.select("thead tr th").array()
                let headerTexts = try headerRow.map { try $0.text() }
                csv += headerTexts.joined(separator: ",") + "\n"
                
                // Process table rows
                let rows = try table.select(":not(thead) tr").array()
                for row in rows {
                    let rowItems = try row.select("td").array()
                    let rowTexts = try rowItems.map { try $0.text() }
                    csv += rowTexts.joined(separator: ",") + "\n"
                }
                
                defaults.set(csv, forKey: "visibleSunriseTable\(locationName)\(jewishYear)")
            } catch {
                errored = true
                print("Error:", error.localizedDescription)
            }
        }
    }
}
