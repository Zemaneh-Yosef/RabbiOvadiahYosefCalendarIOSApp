//
//  GlobalStruct.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/22/25.
//

import KosherSwift
import Foundation

struct GlobalStruct {
    static var useElevation = false
    static var geoLocation = GeoLocation()
    static var jewishCalendar = JewishCalendar()
    static var chosenPrayer = ""
    static var meEyinShaloshChoices = ""
    static var siyumChoices = Array<String>()
    static var userChosenDate = Date()
}
