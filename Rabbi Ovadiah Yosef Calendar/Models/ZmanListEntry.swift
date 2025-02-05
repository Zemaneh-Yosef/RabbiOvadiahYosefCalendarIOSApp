//
//  ZmanListEntry.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 2/24/23.
//

import Foundation

struct ZmanListEntry {
    var title: String // Name of zman or information of the day
    var src: String = "" // if this object is being used for limudim
    var zman: Date? = nil // Date time of zman
    var isZman: Bool = false // Whether or not this object is a zman or just some text
    var isNoteworthyZman: Bool = false // For weekly view
    var isRTZman: Bool = false // To know whether to round up
    var shouldBeDimmed: Bool = false // For Tzeit on Shabbat/Yom Tov
    var isVisibleSunriseZman = false
    var isBirchatHachamahZman = false
    var is66MisheyakirZman = false
}

#if DEBUG
extension ZmanListEntry {
    static var sampleData = [
        ZmanListEntry(title: "Great Neck, New York"),
        ZmanListEntry(title: "Alot", zman: Date(), isZman: true),
        ZmanListEntry(title: "Sunrise", zman: Date(), isZman: true),
        ZmanListEntry(title: "MGA", zman: Date(), isZman: true),
        ZmanListEntry(title: "GRA", zman: Date(), isZman: true),
        ZmanListEntry(title: "Brachot Shma", zman: Date(), isZman: true),
        ZmanListEntry(title: "Chatzot", zman: Date(), isZman: true),
        ZmanListEntry(title: "Mincha Gedolah", zman: Date(), isZman: true),
        ZmanListEntry(title: "Mincha Ketana", zman: Date(), isZman: true),
        ZmanListEntry(title: "Plag", zman: Date(), isZman: true),
        ZmanListEntry(title: "Candle Lighting", zman: Date(), isZman: true, isNoteworthyZman: true),
        ZmanListEntry(title: "Sunset", zman: Date(), isZman: true),
        ZmanListEntry(title: "Nightfall", zman: Date(), isZman: true),
        ZmanListEntry(title: "RT", zman: Date(), isZman: true, isNoteworthyZman: true, isRTZman: true),
    ]
}
#endif
