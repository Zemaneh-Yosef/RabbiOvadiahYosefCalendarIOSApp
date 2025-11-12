//
//  ZmanimFactory.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 1/31/25.
//

import Foundation
import KosherSwift

class ZmanimFactory {
    
    public static func addZmanim(list:Array<ZmanListEntry>, defaults: UserDefaults, zmanimCalendar: ComplexZmanimCalendar, jewishCalendar: JewishCalendar, add66Misheyakir: Bool = false) -> Array<ZmanListEntry> {
        let useAHZmanim = defaults.bool(forKey: "LuachAmudeiHoraah")
        var temp = list
        let zmanimNames = ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        if jewishCalendar.isTaanis()
            && jewishCalendar.getYomTovIndex() != JewishCalendar.TISHA_BEAV
            && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: useAHZmanim ? zmanimCalendar.getAlosAmudeiHoraah() : zmanimCalendar.getAlos72Zmanis(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: useAHZmanim ? zmanimCalendar.getAlosAmudeiHoraah() : zmanimCalendar.getAlos72Zmanis(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: useAHZmanim ? zmanimCalendar.getMisheyakir60AmudeiHoraah() : zmanimCalendar.getMisheyakir60MinutesZmanis(), isZman: true))
        if add66Misheyakir {
            temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString().appending(" (66)"), zman: useAHZmanim ? zmanimCalendar.getMisheyakir66AmudeiHoraah() : zmanimCalendar.getMisheyakir66MinutesZmanis(), isZman: true, is66MisheyakirZman: true))
        }
        let chaitables = ChaiTables(locationName: zmanimCalendar.geoLocation.locationName, jewishCalendar: jewishCalendar, defaults: defaults)
        let visibleSurise = chaitables.getVisibleSurise(forDate: zmanimCalendar.workingDate)
        if visibleSurise != nil {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true, isVisibleSunriseZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
        }
        if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman: useAHZmanim ? zmanimCalendar.getSofZmanShmaMGA72MinutesZmanisAmudeiHoraah() : zmanimCalendar.getSofZmanShmaMGA72MinutesZmanis(), isZman: true))
        if (jewishCalendar.isBirkasHachamah()) {
            temp.append(ZmanListEntry(title: zmanimNames.getBirkatHachamaString(), zman: zmanimCalendar.getSofZmanShmaGRA(), isZman: true, isBirchatHachamahZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman: zmanimCalendar.getSofZmanShmaGRA(), isZman: true))
        if jewishCalendar.getYomTovIndex() == JewishCalendar.EREV_PESACH {
            temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(), zman: useAHZmanim ? zmanimCalendar.getSofZmanAchilatChametzAmudeiHoraah() : zmanimCalendar.getSofZmanTfilaMGA72MinutesZmanis(), isZman: true, isNoteworthyZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman: zmanimCalendar.getSofZmanTfilaGRA(), isZman: true))
            temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(), zman: useAHZmanim ? zmanimCalendar.getSofZmanBiurChametzMGAAmudeiHoraah() : zmanimCalendar.getSofZmanBiurChametzMGA72MinutesZmanis(), isZman: true, isNoteworthyZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman: zmanimCalendar.getSofZmanTfilaGRA(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(), zman: zmanimCalendar.getChatzosIfHalfDayNil(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman: zmanimCalendar.getMinchaGedolaGreaterThan30(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman: zmanimCalendar.getMinchaKetana(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " (" + zmanimNames.getHalachaBerurahString() + ")", zman: zmanimCalendar.getPlagHamincha(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " (" + zmanimNames.getYalkutYosefString() + ")", zman: useAHZmanim ? zmanimCalendar.getPlagHaminchaYalkutYosefAmudeiHoraah() : zmanimCalendar.getPlagHaminchaYalkutYosef(), isZman: true))
        if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.getDayOfWeek() == 6 {
            zmanimCalendar.candleLightingOffset = 20// override default
            if defaults.object(forKey: "candleLightingOffset") != nil {
                zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
            }
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (" + String(zmanimCalendar.candleLightingOffset) + ")", zman: zmanimCalendar.getCandleLighting(), isZman: true, isNoteworthyZman: true))
        }
        if defaults.bool(forKey: "showWhenShabbatChagEnds") {
            if jewishCalendar.isTomorrowShabbosOrYomTov() {
                jewishCalendar.forward()
                zmanimCalendar.workingDate = jewishCalendar.workingDate// go to the next day
                if !jewishCalendar.isTomorrowShabbosOrYomTov() {// only add if shabbat/chag actually ends
                    if defaults.bool(forKey: "showRegularWhenShabbatChagEnds") {
                        temp = addShabbatEndsZman(list: temp, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, zmanimNames: zmanimNames, defaults: defaults, useAHZmanim: useAHZmanim, isForCandLighting: false, isForTommorow: true)
                    }
                    if defaults.bool(forKey: "showRTWhenShabbatChagEnds") {
                        temp = addRTZman(list: temp, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, zmanimNames: zmanimNames, defaults: defaults, useAHZmanim: useAHZmanim, isForTommorow: true)
                    }
                }
                jewishCalendar.back()
                zmanimCalendar.workingDate = jewishCalendar.workingDate//go back
            }
        }
        if jewishCalendar.tomorrow().isTishaBav() {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.getElevationAdjustedSunset(), isZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman: zmanimCalendar.getElevationAdjustedSunset(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman: useAHZmanim ? zmanimCalendar.getTzaisAmudeiHoraah() : zmanimCalendar.getTzais13Point5MinutesZmanis(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman: useAHZmanim ? zmanimCalendar.getTzaisAmudeiHoraahLChumra() : zmanimCalendar.getTzaisAteretTorah(minutes: 20), isZman: true))
        if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.getDayOfWeek() != 6 {
            if jewishCalendar.getDayOfWeek() == 7 {
                temp = addShabbatEndsZman(list: temp, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, zmanimNames: zmanimNames, defaults: defaults, useAHZmanim: useAHZmanim, isForCandLighting: true, isForTommorow: false)
            } else {// just yom tov
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman: useAHZmanim ? zmanimCalendar.getTzaisAmudeiHoraahLChumra() : zmanimCalendar.getTzaisAteretTorah(minutes: 20), isZman: true, isNoteworthyZman: true))
            }
        }
        if jewishCalendar.isTaanis() && !jewishCalendar.isYomKippur() {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString(), zman: useAHZmanim ? zmanimCalendar.getTzaisAmudeiHoraahLChumra() : zmanimCalendar.getTzaisAteretTorah(minutes: 20), isZman: true, isNoteworthyZman: true))
        }
        if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
            temp = addShabbatEndsZman(list: temp, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, zmanimNames: zmanimNames, defaults: defaults, useAHZmanim: useAHZmanim, isForCandLighting: false, isForTommorow: false)
            temp = addRTZman(list: temp, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, zmanimNames: zmanimNames, defaults: defaults, useAHZmanim: useAHZmanim, isForTommorow: false)
            var index = 0
            for var zman in temp {
                if zman.title == zmanimNames.getTzaitHacochavimString() || zman.title == zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString() {
                    zman.shouldBeDimmed = true
                    temp.remove(at: index)
                    temp.insert(zman, at: index)
                }
                index+=1
            }
        } else if jewishCalendar.getDayOfWeek() == 7 {// always add RT for shabbat
            temp = addRTZman(list: temp, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, zmanimNames: zmanimNames, defaults: defaults, useAHZmanim: useAHZmanim, isForTommorow: false)
        } else if defaults.bool(forKey: "alwaysShowRT") {
            if !(jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting()) {
                temp = addRTZman(list: temp, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, zmanimNames: zmanimNames, defaults: defaults, useAHZmanim: useAHZmanim, isForTommorow: false)
            }
        }
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman:zmanimCalendar.getSolarMidnightIfSunTransitNil(), isZman: true))
        return temp
    }
    
    private static func addShabbatEndsZman(list: Array<ZmanListEntry>, zmanimCalendar: ComplexZmanimCalendar, jewishCalendar: JewishCalendar, zmanimNames: ZmanimTimeNames, defaults: UserDefaults, useAHZmanim: Bool, isForCandLighting: Bool, isForTommorow: Bool) -> Array<ZmanListEntry> {
        var temp = list
        zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
        if defaults.object(forKey: "shabbatOffset") != nil {
            zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
        }
        var endShabbat = ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(defaults: defaults, jewishCalendar: jewishCalendar) + zmanimNames.getEndsString(), zman: useAHZmanim ? zmanimCalendar.getTzaisShabbosAmudeiHoraah() : zmanimCalendar.getTzaisAteretTorah(), isZman: true)
        
        if defaults.bool(forKey: "overrideAHEndShabbatTime") {// if user wants to override
            if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                endShabbat.zman = zmanimCalendar.getTzaisAteretTorah()
            } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                endShabbat.zman = zmanimCalendar.getTzaisShabbosAmudeiHoraah()
            } else {
                endShabbat.zman = zmanimCalendar.getTzaisShabbosAmudeiHoraahLesserThan40()
            }
        }
        if isForTommorow {
            endShabbat.title += zmanimNames.getMacharString()
        }
        if isForCandLighting {
            endShabbat.title = zmanimNames.getCandleLightingString()
        }
        endShabbat.isNoteworthyZman = true
        temp.append(endShabbat)
        return temp
    }
    
    private static func addRTZman(list: Array<ZmanListEntry>, zmanimCalendar: ComplexZmanimCalendar, jewishCalendar: JewishCalendar, zmanimNames: ZmanimTimeNames, defaults: UserDefaults, useAHZmanim: Bool, isForTommorow: Bool) -> Array<ZmanListEntry> {
        var temp = list
        var rt = ZmanListEntry(title: zmanimNames.getRTString(), zman: useAHZmanim ? zmanimCalendar.getTzais72ZmanisAmudeiHoraahLkulah() : zmanimCalendar.getTzais72Zmanis(), isZman: true)
        if defaults.bool(forKey: "overrideRTZman") {
            rt.zman = zmanimCalendar.getTzais72Zmanis()
        }
        rt.title += zmanimNames.getRTType(isFixed: rt.zman == zmanimCalendar.getTzais72())
        if isForTommorow {
            rt.title += zmanimNames.getMacharString()
        }
        rt.title = rt.title.trimmingCharacters(in: .whitespaces)
        rt.isRTZman = true
        rt.isNoteworthyZman = true
        temp.append(rt)
        return temp
    }
    
    private static func getShabbatAndOrChag(defaults: UserDefaults, jewishCalendar: JewishCalendar) -> String {
        if (defaults.bool(forKey: "isZmanimInHebrew")) {
            if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.getDayOfWeek() == 7 {
                return "\u{05E9}\u{05D1}\u{05EA}/\u{05D7}\u{05D2}"
            } else if jewishCalendar.getDayOfWeek() == 7 {
                return "\u{05E9}\u{05D1}\u{05EA}"
            } else {
                return "\u{05D7}\u{05D2}"
            }
        } else {
            if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.getDayOfWeek() == 7 {
                return "Shabbat/Chag";
            } else if jewishCalendar.getDayOfWeek() == 7 {
                return "Shabbat";
            } else {
                return "Chag";
            }
        }
    }
}
