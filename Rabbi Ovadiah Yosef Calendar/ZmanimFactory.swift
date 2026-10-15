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
        let zmanimNames = ZmanimTimeNames(defaults: defaults)
        if jewishCalendar.isRegularTaanis() && jewishCalendar.getYomTovIndex() != JewishCalendar.TISHA_BEAV {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(),
                                      zman: useAHZmanim ? zmanimCalendar.getAlosAmudeiHoraah() : zmanimCalendar.getAlos72Zmanis(),
                                      type: .fastStartsNonTishaBavZman,
                                      secondTreatment: .roundEarlier))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getAlotString(),
                                  desc: "Alot Hashachar",
                                  zman: useAHZmanim ? zmanimCalendar.getAlosAmudeiHoraah() : zmanimCalendar.getAlos72Zmanis(),
                                  type: .alotHashacharZman,
                                  secondTreatment: .roundEarlier))
        temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(),
                                  desc: "Talit And Tefilin",
                                  zman: useAHZmanim ? zmanimCalendar.getMisheyakir60AmudeiHoraah() : zmanimCalendar.getMisheyakir60MinutesZmanis(),
                                  type: .misheyakir60Zman,
                                  secondTreatment: .roundLater))
        if add66Misheyakir {
            temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString().appending(" (66)"),
                                      zman: useAHZmanim ? zmanimCalendar.getMisheyakir66AmudeiHoraah() : zmanimCalendar.getMisheyakir66MinutesZmanis(),
                                      type: .misheyakir66Zman,
                                      secondTreatment: .roundLater))
        }
        let chaitables = ChaiTables(locationName: zmanimCalendar.geoLocation.locationName,
                                    jewishCalendar: jewishCalendar,
                                    defaults: defaults)
        let visibleSurise = chaitables.getVisibleSurise(forDate: zmanimCalendar.workingDate)
        if visibleSurise != nil {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(),
                                      desc: "Sunrise",
                                      zman: visibleSurise,
                                      type: .hanetzZman,
                                      secondTreatment: .alwaysDisplay,
                                      isVisibleSunriseZman: true))
        } else {
            temp.append(ZmanListEntry(title: "\(zmanimNames.getHaNetzString()) (\(zmanimNames.getMishorString()))",
                                      desc: "Sunrise",
                                      zman: zmanimCalendar.getSeaLevelSunrise(),
                                      type: .hanetzZman,
                                      secondTreatment: .roundLater))
        }
        if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
            temp.append(ZmanListEntry(title: "\(zmanimNames.getHaNetzString()) (\(zmanimNames.getMishorString()))",
                                      zman: zmanimCalendar.getSeaLevelSunrise(),
                                      type: .hanetzZman,
                                      secondTreatment: .roundLater))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(),
                                  desc: "Sof Zman Shma MGA", 
                                  zman: useAHZmanim ? zmanimCalendar.getSofZmanShmaMGA72MinutesZmanisAmudeiHoraah() : zmanimCalendar.getSofZmanShmaMGA72MinutesZmanis(),
                                  type: .sofZmanShmaMGAZman,
                                  secondTreatment: .roundEarlier))
        if (jewishCalendar.isBirkasHachamah()) {
            temp.append(ZmanListEntry(title: zmanimNames.getBirkatHachamaString(),
                                      zman: zmanimCalendar.getSofZmanShmaGRA(),
                                      type: .birkatHachmahZman,
                                      secondTreatment: .roundEarlier))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(),
                                  desc: "Sof Zman Shma GRA",
                                  zman: zmanimCalendar.getSofZmanShmaGRA(),
                                  type: .sofZmanShmaGRAZman,
                                  secondTreatment: .roundEarlier))
        if jewishCalendar.getYomTovIndex() == JewishCalendar.EREV_PESACH {
            temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(),
                                      desc: "Achilat Chametz",
                                      zman: useAHZmanim ? zmanimCalendar.getSofZmanAchilatChametzAmudeiHoraah() : zmanimCalendar.getSofZmanTfilaMGA72MinutesZmanis(),
                                      type: .sofZmanAchilatChametzZman,
                                      isNoteworthyZman: true,
                                      secondTreatment: .roundEarlier))
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(),
                                      desc: "Sof Zman Tefila",
                                      zman: zmanimCalendar.getSofZmanTfilaGRA(),
                                      type: .sofZmanBerachotShmaZman,
                                      secondTreatment: .roundEarlier))
            temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(),
                                      desc: "Biur Chametz",
                                      zman: useAHZmanim ? zmanimCalendar.getSofZmanBiurChametzMGAAmudeiHoraah() : zmanimCalendar.getSofZmanBiurChametzMGA72MinutesZmanis(),
                                      type: .sofZmanBiurChametzZman,
                                      isNoteworthyZman: true,
                                      secondTreatment: .roundEarlier))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(),
                                      desc: "Sof Zman Tefila",
                                      zman: zmanimCalendar.getSofZmanTfilaGRA(),
                                      type: .sofZmanBerachotShmaZman,
                                      secondTreatment: .roundEarlier))
        }
        zmanimCalendar.useAstronomicalChatzos = false
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(),
                                  desc: "Chatzot",
                                  zman: zmanimCalendar.getChatzos(),
                                  type: .chatzotZman,
                                  secondTreatment: .roundEarlier))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(),
                                  desc: "Mincha Gedolah",
                                  zman: zmanimCalendar.getMinchaGedolaGreaterThan30(),
                                  type: .minchaGedolahZman,
                                  secondTreatment: .roundLater))
        temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(),
                                  desc: "Mincha Ketana",
                                  zman: zmanimCalendar.getMinchaKetana(),
                                  type: .minchaKetanaZman,
                                  secondTreatment: .roundLater))
        temp.append(ZmanListEntry(title: "\(zmanimNames.getPlagHaminchaString()) (\(zmanimNames.getHalachaBerurahString()))",
                                  desc: "Plag HaMincha Halacha Berurah",
                                  zman: zmanimCalendar.getPlagHamincha(),
                                  type: .plagHaminchaHBZman,
                                  secondTreatment: .roundLater))
        temp.append(ZmanListEntry(title: "\(zmanimNames.getPlagHaminchaString()) (\(zmanimNames.getYalkutYosefString()))",
                                  desc: "Plag HaMincha Yalkut Yosef",
                                  zman: useAHZmanim ? zmanimCalendar.getPlagHaminchaYalkutYosefAmudeiHoraah() : zmanimCalendar.getPlagHaminchaYalkutYosef(),
                                  type: .plagHaminchaYYZman,
                                  secondTreatment: .roundLater))
        if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.getDayOfWeek() == 6 {
            zmanimCalendar.candleLightingOffset = 20// override default
            if defaults.object(forKey: "candleLightingOffset") != nil {
                zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
            }
            temp.append(ZmanListEntry(title: "\(zmanimNames.getCandleLightingString()) (\(zmanimCalendar.candleLightingOffset))",
                                      desc: "Candle Lighting",
                                      zman: zmanimCalendar.getCandleLighting(),
                                      type: .candlelightingZman,
                                      isNoteworthyZman: true,
                                      secondTreatment: .roundEarlier))
        }
        if defaults.bool(forKey: "showWhenShabbatChagEnds") {
            if jewishCalendar.isTomorrowShabbosOrYomTov() {
                jewishCalendar.forward()
                zmanimCalendar.workingDate = jewishCalendar.workingDate// go to the next day
                if !jewishCalendar.isTomorrowShabbosOrYomTov() {// only add if shabbat/chag actually ends
                    if defaults.bool(forKey: "showRegularWhenShabbatChagEnds") {
                        temp = addShabbatEndsZman(list: temp,
                                                  zmanimCalendar: zmanimCalendar,
                                                  jewishCalendar: jewishCalendar,
                                                  zmanimNames: zmanimNames,
                                                  defaults: defaults,
                                                  useAHZmanim: useAHZmanim,
                                                  isForCandLighting: false,
                                                  isForTommorow: true)
                    }
                    if defaults.bool(forKey: "showRTWhenShabbatChagEnds") {
                        temp = addRTZman(list: temp,
                                         zmanimCalendar: zmanimCalendar,
                                         jewishCalendar: jewishCalendar,
                                         zmanimNames: zmanimNames,
                                         defaults: defaults,
                                         useAHZmanim: useAHZmanim,
                                         isForTommorow: true)
                    }
                }
                jewishCalendar.back()
                zmanimCalendar.workingDate = jewishCalendar.workingDate//go back
            }
        }
        if jewishCalendar.tomorrow().isTishaBav() {
            temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(),
                                      zman: zmanimCalendar.getElevationAdjustedSunset(),
                                      type: .fastStartsTishaBavZman,
                                      secondTreatment: .roundEarlier))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(),
                                  desc: "Sunset",
                                  zman: zmanimCalendar.getElevationAdjustedSunset(),
                                  type: .sunsetZman,
                                  secondTreatment: .roundEarlier))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(),
                                  desc: "Tzeit Hacochavim",
                                  zman: useAHZmanim ? zmanimCalendar.getTzaisAmudeiHoraah() : zmanimCalendar.getTzais13Point5MinutesZmanis(),
                                  type: .tzetHakokhavimZman,
                                  secondTreatment: .roundLater))
        temp.append(ZmanListEntry(title: "\(zmanimNames.getTzaitHacochavimString()) \(zmanimNames.getLChumraString())",
                                  desc: "Tzeit Hacochavim (Stringent)",
                                  zman: useAHZmanim ? zmanimCalendar.getTzaisAmudeiHoraahLChumra() : zmanimCalendar.getTzeit20MinutesZmanit(),
                                  type: .tzetHakokhavimLChumraZman,
                                  secondTreatment: .roundLater))
        if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.getDayOfWeek() != 6 {
            if jewishCalendar.getDayOfWeek() == 7 {
                temp = addShabbatEndsZman(list: temp,
                                          zmanimCalendar: zmanimCalendar,
                                          jewishCalendar: jewishCalendar,
                                          zmanimNames: zmanimNames,
                                          defaults: defaults,
                                          useAHZmanim: useAHZmanim,
                                          isForCandLighting: true,
                                          isForTommorow: false)
            } else {// just yom tov
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(),
                                          zman: useAHZmanim ? zmanimCalendar.getTzaisAmudeiHoraahLChumra() : zmanimCalendar.getTzeit20MinutesZmanit(),
                                          type: .candlelightingZman,
                                          isNoteworthyZman: true,
                                          secondTreatment: .roundLater))
            }
        }
        if jewishCalendar.isRegularTaanis() {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString(),
                                      desc: "Fast Ends",
                                      zman: useAHZmanim ? zmanimCalendar.getTzaisAmudeiHoraahLChumra() : zmanimCalendar.getTzeit20MinutesZmanit(),
                                      type: .fastEndsZman,
                                      isNoteworthyZman: true,
                                      secondTreatment: .roundLater))
        }
        if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
            temp = addShabbatEndsZman(list: temp,
                                      zmanimCalendar: zmanimCalendar,
                                      jewishCalendar: jewishCalendar,
                                      zmanimNames: zmanimNames,
                                      defaults: defaults,
                                      useAHZmanim: useAHZmanim,
                                      isForCandLighting: false,
                                      isForTommorow: false)
            temp = addRTZman(list: temp,
                             zmanimCalendar: zmanimCalendar,
                             jewishCalendar: jewishCalendar,
                             zmanimNames: zmanimNames,
                             defaults: defaults,
                             useAHZmanim: useAHZmanim,
                             isForTommorow: false)
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
            temp = addRTZman(list: temp,
                             zmanimCalendar: zmanimCalendar,
                             jewishCalendar: jewishCalendar,
                             zmanimNames: zmanimNames,
                             defaults: defaults,
                             useAHZmanim: useAHZmanim,
                             isForTommorow: false)
        } else if defaults.bool(forKey: "alwaysShowRT") {
            if !(jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting()) {
                temp = addRTZman(list: temp,
                                 zmanimCalendar: zmanimCalendar,
                                 jewishCalendar: jewishCalendar,
                                 zmanimNames: zmanimNames,
                                 defaults: defaults,
                                 useAHZmanim: useAHZmanim,
                                 isForTommorow: false)
            }
        }
        temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(),
                                  desc: "Chatzot Layla",
                                  zman:zmanimCalendar.getSolarMidnightIfSunTransitNil(),
                                  type: .chatzotLaylaZman,
                                  secondTreatment: .roundLater))
        return temp
    }
    
    private static func addShabbatEndsZman(list: Array<ZmanListEntry>, zmanimCalendar: ComplexZmanimCalendar, jewishCalendar: JewishCalendar, zmanimNames: ZmanimTimeNames, defaults: UserDefaults, useAHZmanim: Bool, isForCandLighting: Bool, isForTommorow: Bool) -> Array<ZmanListEntry> {
        var temp = list
        zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
        if defaults.object(forKey: "shabbatOffset") != nil {
            zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
        }
        var endShabbat = ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(defaults: defaults, jewishCalendar: jewishCalendar) + zmanimNames.getEndsString(),
                                       zman: useAHZmanim ? zmanimCalendar.getTzaisShabbosAmudeiHoraah() : zmanimCalendar.getTzaisAteretTorah(),
                                       type: .shabbatChagEndsZman)
        
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
        endShabbat.desc = "Shabbat Ends"
        endShabbat.secondTreatment = .roundLater
        temp.append(endShabbat)
        return temp
    }
    
    private static func addRTZman(list: Array<ZmanListEntry>, zmanimCalendar: ComplexZmanimCalendar, jewishCalendar: JewishCalendar, zmanimNames: ZmanimTimeNames, defaults: UserDefaults, useAHZmanim: Bool, isForTommorow: Bool) -> Array<ZmanListEntry> {
        var temp = list
        var rt = ZmanListEntry(title: zmanimNames.getRTString(),
                               zman: useAHZmanim ? zmanimCalendar.getTzais72ZmanisAmudeiHoraahLkulah() : zmanimCalendar.getTzais72Zmanis(),
                               type: .rabbenuTamZman)
        if defaults.bool(forKey: "overrideRTZman") {
            rt.zman = zmanimCalendar.getTzais72Zmanis()
        }
        rt.title += zmanimNames.getRTType(isFixed: rt.zman == zmanimCalendar.getTzais72())
        if isForTommorow {
            rt.title += zmanimNames.getMacharString()
        }
        rt.title = rt.title.trimmingCharacters(in: .whitespaces)
        rt.desc = "Rabbeinu Tam"
        rt.secondTreatment = .roundLater
        rt.isNoteworthyZman = true
        temp.append(rt)
        return temp
    }
    
    private static func getShabbatAndOrChag(defaults: UserDefaults, jewishCalendar: JewishCalendar) -> String {
        let hebrew = defaults.bool(forKey: "isZmanimInHebrew")
        
        if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.getDayOfWeek() == 7 {
            return hebrew ? "שבת/חג" : "Shabbat/Ḥag";
        } else if jewishCalendar.getDayOfWeek() == 7 {
            return hebrew ? "שבת" : "Shabbat";
        } else {
            let americanized = defaults.bool(forKey: "isZmanimAmericanized")
            return hebrew ? "חג" :
            americanized ? "Chag" : "Ḥag";
        }
    }
    
    public static func getDemoZmanim(isZmanimInHebrew: Bool, isZmanimEnglishTranslated: Bool, isZmanimAmericanized: Bool) -> Array<ZmanListEntry> {
        let defaults = UserDefaults.getMyUserDefaults()
        var zmanimNames = ZmanimTimeNames(defaults: defaults)
        zmanimNames.mIsZmanimInHebrew = isZmanimInHebrew
        zmanimNames.mIsZmanimEnglishTranslated = isZmanimEnglishTranslated
        zmanimNames.mIsZmanimAmericanized = isZmanimAmericanized
        
        var zmanim = Array<ZmanListEntry>()
        zmanim.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: nil))
        zmanim.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: nil))
        zmanim.append( ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getShmaGraString(), zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getChatzotString(), zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " (" + zmanimNames.getHalachaBerurahString() + ")", zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " (" + zmanimNames.getYalkutYosefString() + ")", zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (20)", zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getSunsetString(), zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(defaults: defaults, jewishCalendar: JewishCalendar()) + zmanimNames.getEndsString(), zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getRTString() + zmanimNames.getRTType(isFixed: false), zman: nil));
        zmanim.append( ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman: nil));
        return zmanim;
    }
}
