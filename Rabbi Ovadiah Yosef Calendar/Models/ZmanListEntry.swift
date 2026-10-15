//
//  ZmanListEntry.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 2/24/23.
//

import Foundation

struct ZmanListEntry: Hashable {
    var title: String // Name of zman or information of the day
    var desc: String = "" // if this object is being used for limudim
    var src: String = "" // if this object is being used for limudim
    var zman: Date? = nil // Date time of zman
    var type: ZmanListEntryType = .unspecified // What type of entry this object contains
    var isNoteworthyZman: Bool = false // For weekly view
    var secondTreatment: SecondTreatment = .roundEarlier // To know how to treat the seconds
    var shouldBeDimmed: Bool = false // For Tzeit on Shabbat/Yom Tov
    var isVisibleSunriseZman = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: ZmanListEntry, rhs: ZmanListEntry) -> Bool {
        return lhs.title == rhs.title && lhs.src == rhs.src && lhs.zman == rhs.zman && lhs.type.isZman == rhs.type.isZman
    }
}
