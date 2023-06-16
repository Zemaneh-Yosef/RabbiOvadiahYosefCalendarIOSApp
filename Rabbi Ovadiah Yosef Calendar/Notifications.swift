//
//  Notifications.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 5/3/23.
//

import Foundation
import KosherCocoa
import UserNotifications

class NotificationManager : NSObject, UNUserNotificationCenterDelegate {
    
    static let instance = NotificationManager()
    let defaults = UserDefaults.standard
    let notificationCenter = UNUserNotificationCenter.current()
    
    var locationName = ""
    var lat: Double = 0
    var long: Double = 0
    var elevation: Double = 0
    var timezone: TimeZone = TimeZone.current
    
    var amountOfNotificationsSet = 0
    let amountOfPossibleNotifications = 63 // really 64 but programming

    var zmanimCalendar = ComplexZmanimCalendar()
    var jewishCalendar = JewishCalendar()
    
    var notificationsAreBeingSet:Bool = false
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) {(success, error) in}
    }
    
    fileprivate func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Jewish Special Day"
        content.sound = .default
        if defaults.bool(forKey: "showDayOfOmer") {
            content.body = "Today is " + jewishCalendar.getSpecialDay()
        } else {
            content.body = "Today is " + jewishCalendar.getSpecialDayWithoutOmer()
        }
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        
        //So... Ideally, I wanted to make the notifications like the android version that fires at sunrise/sunset everyday. But it seems like Apple/IOS does not not allow different trigger times for local notifications in the background. And apparently there is no way to run any code in the background while the app is closed. So there is no way to update the notifications unless the user interacts with the application. Best I can do is set the notifications in advanced for a week. Not what I wanted, but it'll have to do until Apple adds more options to local notifications or lets developers run background tasks/threads while the app is closed.
        var trigger: UNCalendarNotificationTrigger
        if zmanimCalendar.sunrise()?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 < Date().timeIntervalSince1970 {//if after sunrise
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(86400)//set to next day's sunrise
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zmanimCalendar.sunrise() ?? Date()), repeats: false)
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(-86400)//reset
        } else {//set to upcoming sunrise
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zmanimCalendar.sunrise() ?? Date()), repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        if content.body != "Today is " {//avoid scheduling notifications that are not going to be displayed
            notificationCenter.add(request)
            amountOfNotificationsSet+=1
        }
    }
    
    func scheduleSunriseNotifications() {
        amountOfNotificationsSet = 0
        notificationCenter.removeAllPendingNotificationRequests()//always start from scratch...
        for _ in 1...14 {
            scheduleDailyNotification()
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.advanced(by: 86400)
            jewishCalendar.workingDate = zmanimCalendar.workingDate
        }
        zmanimCalendar.workingDate = Date()
        jewishCalendar.workingDate = zmanimCalendar.workingDate//reset to today
        
        //Tekufa can happen whenever, so not neccesarily sunrise, but in my android app I check for tekufa at sunrise so it makes sense to put this code here
        let tekufaSetting = defaults.integer(forKey: "tekufaOpinion")
        if tekufaSetting == 1 {
            let tekufaContent = UNMutableNotificationContent()
            tekufaContent.title = "Tekufa / Season Changes"
            tekufaContent.sound = .default
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm aa"
            let backup = jewishCalendar.workingDate
            while jewishCalendar.getTekufaAsDate() == nil {
                jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
            }
            let tekufa = jewishCalendar.getTekufaAsDate()
            tekufaContent.body = "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufa!) + ". Do not drink water half an hour before or after this time."
            jewishCalendar.workingDate = backup
            tekufaContent.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
            
            let tekufaTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: tekufa?.addingTimeInterval(-1800) ?? Date()), repeats: false)
            
            let tekufaRequest = UNNotificationRequest(identifier: "TekufaNotification", content: tekufaContent, trigger: tekufaTrigger)
            notificationCenter.add(tekufaRequest)
            amountOfNotificationsSet+=1
        } else if tekufaSetting == 2 {
            let tekufaContent = UNMutableNotificationContent()
            tekufaContent.title = "Tekufa / Season Changes"
            tekufaContent.sound = .default
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm aa"
            let backup = jewishCalendar.workingDate
            while jewishCalendar.getAmudeiHoraahTekufaAsDate() == nil {
                jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
            }
            let tekufa = jewishCalendar.getAmudeiHoraahTekufaAsDate()
            tekufaContent.body = "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufa!) + ". Do not drink water half an hour before or after this time."
            jewishCalendar.workingDate = backup
            tekufaContent.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
            
            let tekufaTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: tekufa?.addingTimeInterval(-1800) ?? Date()), repeats: false)
            
            let tekufaRequest = UNNotificationRequest(identifier: "TekufaNotification", content: tekufaContent, trigger: tekufaTrigger)
            notificationCenter.add(tekufaRequest)
            amountOfNotificationsSet+=1
        } else {
            let tekufaContent = UNMutableNotificationContent()
            tekufaContent.title = "Tekufa / Season Changes"
            tekufaContent.sound = .default
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm aa"
            let backup = jewishCalendar.workingDate
            while jewishCalendar.getTekufaAsDate() == nil {
                jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
            }
            let tekufa = jewishCalendar.getTekufaAsDate()
            tekufaContent.body = "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufa!) + ". Do not drink water half an hour before or after this time."
            jewishCalendar.workingDate = backup
            tekufaContent.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
            
            let tekufaTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: tekufa?.addingTimeInterval(-1800) ?? Date()), repeats: false)
            
            let tekufaRequest = UNNotificationRequest(identifier: "TekufaNotification", content: tekufaContent, trigger: tekufaTrigger)
            notificationCenter.add(tekufaRequest)
            amountOfNotificationsSet+=1
            
            let tekufaContent2 = UNMutableNotificationContent()
            tekufaContent2.title = "Tekufa / Season Changes"
            tekufaContent2.sound = .default
            
            while jewishCalendar.getAmudeiHoraahTekufaAsDate() == nil {
                jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
            }
            let tekufa2 = jewishCalendar.getAmudeiHoraahTekufaAsDate()
            tekufaContent2.body = "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufa2!) + ". Do not drink water half an hour before or after this time."
            jewishCalendar.workingDate = backup
            tekufaContent2.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
            
            let tekufaTrigger2 = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: tekufa2?.addingTimeInterval(-1800) ?? Date()), repeats: false)
            
            let tekufaRequest2 = UNNotificationRequest(identifier: "TekufaNotification2", content: tekufaContent2, trigger: tekufaTrigger2)
            notificationCenter.add(tekufaRequest2)
            amountOfNotificationsSet+=1
        }
    }
    
    fileprivate func scheduleOmerNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Day of Omer"
        content.sound = .default
        content.subtitle = "Don't forget to count!"
        let dayOfOmer = jewishCalendar.getDayOfOmer()
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        content.body = "Tonight is the " + formatter.string(from: dayOfOmer as NSNumber)! + " day of the Omer"
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        
        //same issue as described in scheduleDailyNotifications()
        var trigger: UNCalendarNotificationTrigger

        if defaults.bool(forKey: "LuachAmudeiHoraah") {
            if zmanimCalendar.tzaitAmudeiHoraah()?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 < Date().timeIntervalSince1970 {
                zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(86400)
                trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zmanimCalendar.tzaitAmudeiHoraah() ?? Date()), repeats: false)
                zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(-86400)
            } else {
                trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zmanimCalendar.tzaitAmudeiHoraah() ?? Date()), repeats: false)
            }
        } else {
            if zmanimCalendar.tzeit()?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 < Date().timeIntervalSince1970 {
                zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(86400)
                trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zmanimCalendar.tzeit() ?? Date()), repeats: false)
                zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(-86400)
            } else {
                trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zmanimCalendar.tzeit() ?? Date()), repeats: false)
            }
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        if dayOfOmer != -1 {
            notificationCenter.add(request)
            amountOfNotificationsSet+=1
        }
    }
    
    func scheduleSunsetNotifications() {
        for _ in 1...14 {
            scheduleOmerNotifications()
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.advanced(by: 86400)
            jewishCalendar.workingDate = zmanimCalendar.workingDate
        }
        zmanimCalendar.workingDate = Date()
        jewishCalendar.workingDate = zmanimCalendar.workingDate//reset to today
        
        while jewishCalendar.isVeseinBerachaRecited() {
            jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
        }//now that the jewish date is set to the date where we change to Barech Aleinu, make a notification for sunset
        zmanimCalendar.workingDate = jewishCalendar.workingDate
        let contentBarech = UNMutableNotificationContent()
        contentBarech.title = "Barech Aleinu Tonight!"
        contentBarech.sound = .default
        contentBarech.subtitle = locationName
        contentBarech.body = "Tonight we start saying Barech Aleinu!"
        contentBarech.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        
        let triggerBarech = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zmanimCalendar.sunset() ?? Date()), repeats: false)
        
        let request = UNNotificationRequest(identifier: "BarechAleinuNotification", content: contentBarech, trigger: triggerBarech)
        notificationCenter.add(request)
        amountOfNotificationsSet+=1
        zmanimCalendar.workingDate = Date()
        jewishCalendar.workingDate = zmanimCalendar.workingDate//reset to today
    }
    
    func scheduleZmanimNotifications() {
        if !defaults.bool(forKey: "zmanim_notifications") {
            //if zmanim notifications are off, we can use the other local notifications for daily notifications which are the most important in my opinion
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.advanced(by: 86400 * 15)
            jewishCalendar.workingDate = zmanimCalendar.workingDate
            //we already scheduled for 14 days, so advance the dates 15 days
            while amountOfNotificationsSet != amountOfPossibleNotifications {
                scheduleDailyNotification()
                zmanimCalendar.workingDate = zmanimCalendar.workingDate.advanced(by: 86400)
                jewishCalendar.workingDate = zmanimCalendar.workingDate
            }
            return
        }
        while amountOfNotificationsSet <= amountOfPossibleNotifications {
            let zmanTimeFormatter = DateFormatter()
            if defaults.bool(forKey: "showSeconds") {
                zmanTimeFormatter.dateFormat = "h:mm:ss aa"
            } else {
                zmanTimeFormatter.dateFormat = "h:mm aa"
            }
            var editableZmanim = ["Alot Hashachar",
                                  "Talit And Tefilin",
                                  "Sunrise",
                                  "Sof Zman Shma MGA",
                                  "Sof Zman Shma GRA",
                                  "Sof Zman Tefila",
                                  "Achilat Chametz",
                                  "Biur Chametz",
                                  "Chatzot",
                                  "Mincha Gedolah",
                                  "Mincha Ketana",
                                  "Plag HaMincha Yalkut Yosef",
                                  "Plag HaMincha Halacha Berurah",
                                  "Candle Lighting",
                                  "Sunset",
                                  "Tzeit Hacochavim",
                                  "Tzeit Hacochavim (Stringent)",
                                  "Fast Ends",
                                  "Fast Ends (Stringent)",
                                  "Shabbat Ends",
                                  "Rabbeinu Tam",
                                  "Chatzot Layla"]
            
            if !defaults.bool(forKey: "LuachAmudeiHoraah") {
                editableZmanim.remove(at: editableZmanim.firstIndex(of: "Plag HaMincha Halacha Berurah")!)
                editableZmanim.remove(at: editableZmanim.firstIndex(of: "Tzeit Hacochavim (Stringent)")!)
            } else {
                editableZmanim.remove(at: editableZmanim.firstIndex(of: "Fast Ends")!)
                editableZmanim.remove(at: editableZmanim.firstIndex(of: "Fast Ends (Stringent)")!)
            }
            for string in editableZmanim {
                if !defaults.bool(forKey: "Notify"+string) || defaults.integer(forKey: string) < 0 {
                    editableZmanim.remove(at: editableZmanim.firstIndex(of: string)!)//get rid of zmanim we do not want to notify for
                }
            }
            var zmanim: Array<ZmanListEntry> = []
            zmanim = addZmanim(list: zmanim)//list is already filtered in this method
            var index = 0 //we need the index for the list to match the array above
            for zmanEntry in zmanim {
                let zman = zmanEntry.zman
                if zman != nil && zman?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 > Date().timeIntervalSince1970 {
                    let zmanContent = UNMutableNotificationContent()
                    zmanContent.title = zmanEntry.title
                    zmanContent.sound = .default
                    zmanContent.subtitle = locationName
                    if defaults.bool(forKey: "isZmanimInHebrew") {
                        zmanContent.body = zmanTimeFormatter.string(from: zman ?? Date()) + " : " + zmanEntry.title
                    } else {
                        zmanContent.body = zmanEntry.title + " is at " + zmanTimeFormatter.string(from: zman ?? Date())
                    }
                    zmanContent.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
                    
                    if !defaults.bool(forKey: "zmanim_notifications_on_shabbat") && jewishCalendar.isAssurBemelacha() {
                        //no notification
                    } else {//notify
                        if amountOfNotificationsSet <= amountOfPossibleNotifications {
                            let triggerZman = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zman?.addingTimeInterval(TimeInterval(-60 * defaults.integer(forKey: editableZmanim[index]))) ?? Date()), repeats: false)
                            
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: zmanContent, trigger: triggerZman)
                            notificationCenter.add(request)
                            amountOfNotificationsSet+=1
                        }
                    }
                }
                index+=1
            }
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.advanced(by: 86400)
            jewishCalendar.workingDate = zmanimCalendar.workingDate
        }
    }
    
    func addZmanim(list:Array<ZmanListEntry>) -> Array<ZmanListEntry> {
        if defaults.bool(forKey: "LuachAmudeiHoraah") {
            return addAmudeiHoraahZmanim(list:list)
        }
        var temp = list
        let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        if defaults.bool(forKey: "NotifyAlot Hashachar") {
            temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.alos72Zmanis(), isZman: true))
        }
        if defaults.bool(forKey: "NotifyTalit And Tefilin") {
            temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.talitTefilin(), isZman: true))
        }
        if defaults.bool(forKey: "NotifySunrise") {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
        }
        if defaults.bool(forKey: "NotifySof Zman Shma MGA") {
            temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.sofZmanShmaMGA72MinutesZmanis(), isZman: true))
        }
        if defaults.bool(forKey: "NotifySof Zman Shma GRA") {
            temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.sofZmanShmaGra(), isZman: true))
        }
        if jewishCalendar.yomTovIndex() == kErevPesach.rawValue {
            if defaults.bool(forKey: "NotifyAchilat Chametz") {
                temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(), zman:zmanimCalendar.sofZmanTfilaMGA72MinutesZmanis(), isZman: true, isNoteworthyZman: true))
            }
            if defaults.bool(forKey: "NotifySof Zman Tefila") {
                temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
            }
            if defaults.bool(forKey: "NotifyBiur Chametz") {
                temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(), zman:zmanimCalendar.sofZmanBiurChametzMGA(), isZman: true, isNoteworthyZman: true))
            }
        } else {
            if defaults.bool(forKey: "NotifySof Zman Tefila") {
                temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
            }
        }
        if defaults.bool(forKey: "NotifyChatzot") {
            temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(), zman:zmanimCalendar.chatzos(), isZman: true))
        }
        if defaults.bool(forKey: "NotifyMincha Gedolah") {
            temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman:zmanimCalendar.minchaGedolaGreaterThan30(), isZman: true))
        }
        if defaults.bool(forKey: "NotifyMincha Ketana") {
            temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman:zmanimCalendar.minchaKetana(), isZman: true))
        }
        if defaults.integer(forKey: "plagOpinion") == 1 || defaults.object(forKey: "plagOpinion") == nil {
            if defaults.bool(forKey: "NotifyPlag HaMincha Yalkut Yosef") {
                temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString(), zman:zmanimCalendar.plagHamincha(), isZman: true))
            }
        } else if defaults.integer(forKey: "plagOpinion") == 2 {
            if defaults.bool(forKey: "NotifyPlag HaMincha Halacha Berurah") {
                temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.plagHaminchaHalachaBerurah(), isZman: true))
            }
        } else {
            if defaults.bool(forKey: "NotifyPlag HaMincha Yalkut Yosef") {
                temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString(), zman:zmanimCalendar.plagHamincha(), isZman: true))
            }
            if defaults.bool(forKey: "NotifyPlag HaMincha Halacha Berurah") {
                temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.plagHaminchaHalachaBerurah(), isZman: true))
            }
        }
        if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.currentDayOfTheWeek() == 6 {
            zmanimCalendar.candleLightingOffset = 20
            if defaults.object(forKey: "candleLightingOffset") != nil {
                zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
            }
            if defaults.bool(forKey: "NotifyCandle Lighting") {
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (" + String(zmanimCalendar.candleLightingOffset) + ")", zman:zmanimCalendar.candleLighting(), isZman: true, isNoteworthyZman: true))
            }
        }
        if defaults.bool(forKey: "NotifySunset") {
            temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.sunset(), isZman: true))
        }
        if defaults.bool(forKey: "NotifyTzeit Hacochavim") {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.tzeit(), isZman: true))
        }
        if defaults.bool(forKey: "showTzeitLChumra") && defaults.bool(forKey: "NotifyTzeit Hacochavim (Stringent)") {
           temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getLChumraString(), zman: zmanimCalendar.tzeitTaanit(), isZman: true))
       }
        if jewishCalendar.isTaanis() && jewishCalendar.yomTovIndex() != kYomKippur.rawValue {
            if defaults.bool(forKey: "NotifyFast Ends") {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzeitTaanit(), isZman: true, isNoteworthyZman: true))
            }
            if defaults.bool(forKey: "NotifyFast Ends (Stringent)") {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.tzeitTaanitLChumra(), isZman: true, isNoteworthyZman: true))
            }
        }
        if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
            zmanimCalendar.ateretTorahSunsetOffset = 40
            if defaults.object(forKey: "shabbatOffset") != nil {
                zmanimCalendar.ateretTorahSunsetOffset = Int32(defaults.integer(forKey: "shabbatOffset"))
            }
            if defaults.bool(forKey: "NotifyShabbat Ends") {
                if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                    temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + " (" + String(zmanimCalendar.ateretTorahSunsetOffset) + ")", zman:zmanimCalendar.tzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
                } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                    temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
                } else {
                    temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
                }
            }
        }
        if defaults.bool(forKey: "NotifyRabbeinu Tam") {
            temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.tzait72Zmanit(), isZman: true, isNoteworthyZman: true, isRTZman: true))
        }
        if defaults.bool(forKey: "NotifyChatzot Layla") {
            temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman:zmanimCalendar.solarMidnight(), isZman: true))
        }
        return temp
    }
    
    func addAmudeiHoraahZmanim(list:Array<ZmanListEntry>) -> Array<ZmanListEntry> {
        var temp = list
        let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        if defaults.bool(forKey: "NotifyAlot Hashachar") {
            temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.alotAmudeiHoraah(), isZman: true))
        }
        if defaults.bool(forKey: "NotifyTalit And Tefilin") {
            temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.talitTefilinAmudeiHoraah(), isZman: true))
        }
        if defaults.bool(forKey: "NotifySunrise") {
            temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
        }
        if defaults.bool(forKey: "NotifySof Zman Shma MGA") {
            temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.shmaMGAAmudeiHoraah(), isZman: true))
        }
        if defaults.bool(forKey: "NotifySof Zman Shma GRA") {
            temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.sofZmanShmaGra(), isZman: true))
        }
        if jewishCalendar.yomTovIndex() == kErevPesach.rawValue {
            if defaults.bool(forKey: "NotifyAchilat Chametz") {
                temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(), zman:zmanimCalendar.achilatChametzAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            }
            if defaults.bool(forKey: "NotifySof Zman Tefila") {
                temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
            }
            if defaults.bool(forKey: "NotifyBiur Chametz") {
                temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(), zman:zmanimCalendar.biurChametzAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            }
        } else {
            if defaults.bool(forKey: "NotifySof Zman Tefila") {
                temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
            }
        }
        if defaults.bool(forKey: "NotifyChatzot") {
            temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(), zman:zmanimCalendar.chatzos(), isZman: true))
        }
        if defaults.bool(forKey: "NotifyMincha Gedolah") {
            temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman:zmanimCalendar.minchaGedolaGreaterThan30(), isZman: true))
        }
        if defaults.bool(forKey: "NotifyMincha Ketana") {
            temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman:zmanimCalendar.minchaKetana(), isZman: true))
        }
        if defaults.bool(forKey: "NotifyPlag HaMincha Halacha Berurah") {
            temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.plagHaminchaHalachaBerurah(), isZman: true))
        }
        if defaults.bool(forKey: "NotifyPlag HaMincha Yalkut Yosef") {
            temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedYalkutYosefString(), zman:zmanimCalendar.plagHaminchaYalkutYosefAmudeiHoraah(), isZman: true))
        }
        if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.currentDayOfTheWeek() == 6 {
            zmanimCalendar.candleLightingOffset = 20
            if defaults.object(forKey: "candleLightingOffset") != nil {
                zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
            }
            if defaults.bool(forKey: "NotifyCandle Lighting") {
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (" + String(zmanimCalendar.candleLightingOffset) + ")", zman:zmanimCalendar.candleLighting(), isZman: true, isNoteworthyZman: true))
            }
        }
        if defaults.bool(forKey: "NotifySunset") {
            temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.sunset(), isZman: true))
        }
        if defaults.bool(forKey: "NotifyTzeit Hacochavim") {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.tzaitAmudeiHoraah(), isZman: true))
        }
        if defaults.bool(forKey: "NotifyTzeit Hacochavim (Stringent)") {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.tzaitAmudeiHoraahLChumra(), isZman: true))
        }
        if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
            zmanimCalendar.ateretTorahSunsetOffset = 40
            if defaults.object(forKey: "shabbatOffset") != nil {
                zmanimCalendar.ateretTorahSunsetOffset = Int32(defaults.integer(forKey: "shabbatOffset"))
            }
            if defaults.bool(forKey: "NotifyShabbat Ends") {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            }
        }
        if defaults.bool(forKey: "NotifyRabbeinu Tam") {
            temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.tzait72ZmanitAmudeiHoraahLkulah(), isZman: true, isNoteworthyZman: true, isRTZman: true))
        }
        if defaults.bool(forKey: "NotifyChatzot Layla") {
            temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman:zmanimCalendar.solarMidnight(), isZman: true))
        }
        return temp
    }
    
    // MARK: - Helper methods
    
    func initializeLocationObjectsAndSetNotifications() {
        if notificationsAreBeingSet {
            return
        }
        notificationsAreBeingSet = true
        if defaults.bool(forKey: "useZipcode") {
            locationName = defaults.string(forKey: "locationName") ?? ""
            lat = defaults.double(forKey: "lat")
            long = defaults.double(forKey: "long")
            if self.defaults.object(forKey: "elevation" + self.locationName) != nil {//if we have been here before, use the elevation saved for this location
                self.elevation = self.defaults.double(forKey: "elevation" + self.locationName)
            } else {//we have never been here before, get the elevation from online
                if self.defaults.bool(forKey: "useElevation") {
                    self.getElevationFromOnline()
                } else {
                    self.elevation = 0//undo any previous values
                }
            }
            if locationName.isEmpty {
                locationName = "Lat: " + String(lat) + " Long: " + String(long)
                if defaults.bool(forKey: "setElevationToLastKnownLocation") {
                    self.elevation = self.defaults.double(forKey: "elevation" + (defaults.string(forKey: "lastKnownLocation") ?? ""))
                }
            }
            timezone = TimeZone.init(identifier: defaults.string(forKey: "timezone")!)!
            zmanimCalendar = ComplexZmanimCalendar(location: GeoLocation(latitude: lat, andLongitude: long, elevation: elevation, andTimeZone: timezone))
            jewishCalendar = JewishCalendar(location: zmanimCalendar.geoLocation)
            jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
            jewishCalendar.returnsModernHolidays = true
        } else {
            LocationManager.shared.getUserLocation {
                location in DispatchQueue.main.async { [self] in
                    self.lat = location.coordinate.latitude
                    self.long = location.coordinate.longitude
                    self.timezone = TimeZone.current
                    zmanimCalendar = ComplexZmanimCalendar(location: GeoLocation(latitude: lat, andLongitude: long, elevation: elevation, andTimeZone: timezone))
                    LocationManager.shared.resolveLocationName(with: location) { [self] locationName in
                        self.locationName = locationName ?? ""
                        if self.defaults.object(forKey: "elevation" + self.locationName) != nil {//if we have been here before, use the elevation saved for this location
                            self.elevation = self.defaults.double(forKey: "elevation" + self.locationName)
                        } else {//we have never been here before, get the elevation from online
                            if self.defaults.bool(forKey: "useElevation") {
                                self.getElevationFromOnline()
                            } else {
                                self.elevation = 0//undo any previous values
                            }
                        }
                        if self.locationName.isEmpty {
                            self.locationName = "Lat: " + String(lat) + " Long: " + String(long)
                            if defaults.bool(forKey: "setElevationToLastKnownLocation") {
                                self.elevation = self.defaults.double(forKey: "elevation" + (defaults.string(forKey: "lastKnownLocation") ?? ""))
                            }
                        }
                        zmanimCalendar = ComplexZmanimCalendar(location: GeoLocation(latitude: lat, andLongitude: long, elevation: elevation, andTimeZone: timezone))
                        jewishCalendar = JewishCalendar(location: zmanimCalendar.geoLocation)
                        jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
                        jewishCalendar.returnsModernHolidays = true
                        self.scheduleSunriseNotifications()
                        self.scheduleSunsetNotifications()
                        self.scheduleZmanimNotifications()
                        self.notificationsAreBeingSet = false
                    }
                }
            }
        }
    }
    
    func getShabbatAndOrChag() -> String {
        if (defaults.bool(forKey: "isZmanimInHebrew")) {
            if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.currentDayOfTheWeek() == 7 {
                return "\u{05E9}\u{05D1}\u{05EA}/\u{05D7}\u{05D2}"
            } else if jewishCalendar.currentDayOfTheWeek() == 7 {
                return "\u{05E9}\u{05D1}\u{05EA}"
            } else {
                return "\u{05D7}\u{05D2}"
            }
        } else {
            if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.currentDayOfTheWeek() == 7 {
                return "Shabbat/Chag";
            } else if jewishCalendar.currentDayOfTheWeek() == 7 {
                return "Shabbat";
            } else {
                return "Chag";
            }
        }
    }
    
    func getElevationFromOnline() {
        var intArray: [Int] = []
        var e1:Int = 0
        var e2:Int = 0
        var e3:Int = 0
        let group = DispatchGroup()
        group.enter()
        let geocoder = LSGeoLookup(withUserID: "Elyahu41")
        geocoder.findElevationGtopo30(latitude: lat, longitude: long) {
            elevation in
            if let elevation = elevation {
                e1 = Int(truncating: elevation)
            }
            group.leave()
        }
        group.enter()
        geocoder.findElevationSRTM3(latitude: lat, longitude: long) {
            elevation in
            if let elevation = elevation {
                e2 = Int(truncating: elevation)
            }
            group.leave()
        }
        group.enter()
        geocoder.findElevationAstergdem(latitude: lat, longitude: long) {
            elevation in
            if let elevation = elevation {
                e3 = Int(truncating: elevation)
            }
            group.leave()
        }
        group.notify(queue: .main) {
            if e1 > 0 {
                intArray.append(e1)
            } else {
                e1 = 0
            }
            if e2 > 0 {
                intArray.append(e2)
            } else {
                e2 = 0
            }
            if e3 > 0 {
                intArray.append(e3)
            } else {
                e3 = 0
            }
            var count = Double(intArray.count)
            if count == 0 {
                count = 1 //edge case
            }
            let text = String(Double(e1 + e2 + e3) / Double(count))
            self.elevation = Double(text) ?? 0
            self.defaults.set(self.elevation, forKey: "elevation" + self.locationName)
        }
    }
}
