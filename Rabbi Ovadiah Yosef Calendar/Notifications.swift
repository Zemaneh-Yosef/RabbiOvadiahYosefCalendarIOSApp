//
//  Notifications.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 5/3/23.
//

import Foundation
import KosherSwift
import UserNotifications
import UIKit

class NotificationManager : NSObject, UNUserNotificationCenterDelegate {
    
    static let instance = NotificationManager()
    let defaults = UserDefaults.getMyUserDefaults()
    let notificationCenter = UNUserNotificationCenter.current()
    
    var locationName = ""
    var lat: Double = 0
    var long: Double = 0
    var elevation: Double = 0
    var timezone: TimeZone = TimeZone.current
    
    var amountOfNotificationsSet = 0
    let amountOfPossibleNotifications = 63 // really 64 but programming

    private var zmanimCalendar = ComplexZmanimCalendar()
    private var jewishCalendar = JewishCalendar()
    
    var notificationsAreBeingSet:Bool = false
    var lastOmerNotification:Bool = false
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) {(success, error) in}
    }

    fileprivate func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Jewish Special Day".localized()
        content.sound = .default
        content.body = "Today is ".localized() + jewishCalendar.getSpecialDay(addOmer: false)

        if amountOfNotificationsSet == amountOfPossibleNotifications - 1 {// if this is the last notification being set
            content.body = content.body.appending(" / Last notification until the app is opened again.".localized())
        }

        //So... Ideally, I wanted to make the notifications like the android version that fires at sunrise/sunset everyday. But it seems like Apple/IOS does not not allow different trigger times for local notifications in the background. And apparently there is no way to run any code in the background while the app is closed. So there is no way to update the notifications unless the user interacts with the application. Best I can do is set the notifications in advanced for a week. Not what I wanted, but it'll have to do until Apple adds more options to local notifications or lets developers run background tasks/threads while the app is closed.
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zmanimCalendar.getSeaLevelSunrise() ?? Date()), repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        if content.body != "Today is ".localized() {//avoid scheduling notifications that are not going to be displayed
            notificationCenter.add(request)
            amountOfNotificationsSet+=1
        }
    }

    func scheduleSunriseNotifications() {
        amountOfNotificationsSet = 0
        notificationCenter.removeAllPendingNotificationRequests()//always start from scratch...

        if zmanimCalendar.getElevationAdjustedSunrise()?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 < Date().timeIntervalSince1970 {// if after sunrise, skip today
            addOneDayToCalendars()
        }

        for _ in 1...14 {
            scheduleDailyNotification()
            addOneDayToCalendars()
        }
        zmanimCalendar.workingDate = Date()
        jewishCalendar.workingDate = zmanimCalendar.workingDate//reset to today

        //Tekufa can happen whenever, so not neccesarily sunrise, but in my android app I check for tekufa at sunrise so it makes sense to put this code here
        let tekufaSetting = defaults.integer(forKey: "tekufaOpinion")
        if (tekufaSetting == 0 && !defaults.bool(forKey: "LuachAmudeiHoraah")) || tekufaSetting == 1  {
            let tekufaContent = UNMutableNotificationContent()
            tekufaContent.title = "Tekufa / Season Changes".localized()
            tekufaContent.sound = .default

            let dateFormatter = DateFormatter()
            if Locale.isHebrewLocale() {
                dateFormatter.dateFormat = "H:mm"
            } else {
                dateFormatter.dateFormat = "h:mm aa"
            }
            let backup = jewishCalendar.workingDate
            while jewishCalendar.getTekufaAsDate() == nil {
                jewishCalendar.forward()
            }
            let tekufa = jewishCalendar.getTekufaAsDate()
            let beginTime = Date(timeIntervalSince1970: tekufa!.timeIntervalSince1970 - 1800) // half hour before earlier time
            let endTime = Date(timeIntervalSince1970: tekufa!.timeIntervalSince1970 + 1800) // half hour after later time
            tekufaContent.body = "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!) + ". Do not drink water from " + dateFormatter.string(from: beginTime) + " until ".localized() + dateFormatter.string(from: endTime)
            jewishCalendar.workingDate = backup
            
            let tekufaTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: tekufa?.addingTimeInterval(-1800) ?? Date()), repeats: false)
            
            let tekufaRequest = UNNotificationRequest(identifier: "TekufaNotification", content: tekufaContent, trigger: tekufaTrigger)
            notificationCenter.add(tekufaRequest)
            amountOfNotificationsSet+=1
        } else if tekufaSetting == 2 || (tekufaSetting == 0 && defaults.bool(forKey: "LuachAmudeiHoraah")) {
            let tekufaContent = UNMutableNotificationContent()
            tekufaContent.title = "Tekufa / Season Changes".localized()
            tekufaContent.sound = .default
            
            let dateFormatter = DateFormatter()
            if Locale.isHebrewLocale() {
                dateFormatter.dateFormat = "H:mm"
            } else {
                dateFormatter.dateFormat = "h:mm aa"
            }
            let backup = jewishCalendar.workingDate
            while jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true) == nil {
                jewishCalendar.forward()
            }
            let tekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            let beginTime = Date(timeIntervalSince1970: tekufa!.timeIntervalSince1970 - 1800) // half hour before earlier time
            let endTime = Date(timeIntervalSince1970: tekufa!.timeIntervalSince1970 + 1800) // half hour after later time
            tekufaContent.body = "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!) + ". Do not drink water from ".localized() + dateFormatter.string(from: beginTime) + " until ".localized() + dateFormatter.string(from: endTime)
            jewishCalendar.workingDate = backup
            
            let tekufaTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: tekufa?.addingTimeInterval(-1800) ?? Date()), repeats: false)
            
            let tekufaRequest = UNNotificationRequest(identifier: "TekufaNotification", content: tekufaContent, trigger: tekufaTrigger)
            notificationCenter.add(tekufaRequest)
            amountOfNotificationsSet+=1
        } else {
            let tekufaContent = UNMutableNotificationContent()
            tekufaContent.title = "Tekufa / Season Changes".localized()
            tekufaContent.sound = .default
            
            let dateFormatter = DateFormatter()
            if Locale.isHebrewLocale() {
                dateFormatter.dateFormat = "H:mm"
            } else {
                dateFormatter.dateFormat = "h:mm aa"
            }
            let backup = jewishCalendar.workingDate
            while jewishCalendar.getTekufaAsDate() == nil {
                jewishCalendar.forward()
            }
            let tekufa = jewishCalendar.getTekufaAsDate()
            let AHTekufa = Date(timeIntervalSince1970: tekufa!.timeIntervalSince1970 - 1260) // 21 minutes in seconds
            let beginTime = Date(timeIntervalSince1970: AHTekufa.timeIntervalSince1970 - 1800) // half hour before earlier time
            let endTime = Date(timeIntervalSince1970: tekufa!.timeIntervalSince1970 + 1800) // half hour after later time
            tekufaContent.body = "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: AHTekufa) + "/" + dateFormatter.string(from: tekufa!) + ". Do not drink water from ".localized() + dateFormatter.string(from: beginTime) + " until ".localized() + dateFormatter.string(from: endTime)
            jewishCalendar.workingDate = backup
            
            let tekufaTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: AHTekufa.addingTimeInterval(-1800)), repeats: false)
            
            let tekufaRequest = UNNotificationRequest(identifier: "TekufaNotification", content: tekufaContent, trigger: tekufaTrigger)
            notificationCenter.add(tekufaRequest)
            amountOfNotificationsSet+=1
        }
    }
    
    fileprivate func scheduleOmerNotifications() {
        let omerList = ["הַיּוֹם יוֹם אֶחָד לָעֹמֶר:",
                        "הַיּוֹם שְׁנֵי יָמִים לָעֹמֶר:",
                        "הַיּוֹם שְׁלֹשָׁה יָמִים לָעֹמֶר:",
                        "הַיּוֹם אַרְבָּעָה יָמִים לָעֹמֶר:",
                        "הַיּוֹם חֲמִשָּׁה יָמִים לָעֹמֶר:",
                        "הַיּוֹם שִׁשָּׁה יָמִים לָעֹמֶר:",
                        "הַיּוֹם שִׁבְעָה יָמִים לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד:",
                        "הַיּוֹם שְׁמוֹנָה יָמִים לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד וְיוֹם אֶחָד:",
                        "הַיּוֹם תִּשְׁעָה יָמִים לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד וּשְׁנֵי יָמִים:",
                        "הַיּוֹם עֲשָׂרָה יָמִים לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד וּשְׁלֹשָׁה יָמִים:",
                        "הַיּוֹם אַחַד עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד וְאַרְבָּעָה יָמִים:",
                        "הַיּוֹם שְׁנֵים עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד וַחֲמִשָּׁה יָמִים:",
                        "הַיּוֹם שְׁלֹשָׁה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שָׁבוּעַ אֶחָד וְשִׁשָּׁה יָמִים:",
                        "הַיּוֹם אַרְבָּעָה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שְׁנֵי שָׁבוּעוֹת:",
                        "הַיּוֹם חֲמִשָּׁה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שְׁנֵי שָׁבוּעוֹת ויוֹם אֶחָד:",
                        "הַיּוֹם שִׁשָּׁה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שְׁנֵי שָׁבוּעוֹת וּשְׁנֵי יָמִים:",
                        "הַיּוֹם שִׁבְעָה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שְׁנֵי שָׁבוּעוֹת וּשְׁלֹשָׁה יָמִים:",
                        "הַיּוֹם שְׁמוֹנָה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שְׁנֵי שָׁבוּעוֹת וְאַרְבָּעָה יָמִים:",
                        "הַיּוֹם תִּשְׁעָה עָשָׂר יוֹם לָעֹמֶר, שֶׁהֵם שְׁנֵי שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים:",
                        "הַיּוֹם עֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שְׁנֵי שָׁבוּעוֹת וְשִׁשָּׁה יָמִים:",
                        "הַיּוֹם אֶחָד וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שְׁלֹשָׁה שָׁבוּעוֹת:",
                        "הַיּוֹם שְׁנַיִם וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שְׁלֹשָׁה שָׁבוּעוֹת וְיוֹם אֶחָד:",
                        "הַיּוֹם שְׁלֹשָׁה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שְׁלֹשָׁה שָׁבוּעוֹת וּשְׁנֵי יָמִים:",
                        "הַיּוֹם אַרְבָּעָה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שְׁלֹשָׁה שָׁבוּעוֹת וּשְׁלֹשָׁה יָמִים:",
                        "הַיּוֹם חֲמִשָּׁה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שְׁלֹשָׁה שָׁבוּעוֹת וְאַרְבָּעָה יָמִים:",
                        "הַיּוֹם שִׁשָּׁה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שְׁלֹשָׁה שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים:",
                        "הַיּוֹם שִׁבְעָה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם שְׁלֹשָׁה שָׁבוּעוֹת וְשִׁשָּׁה יָמִים:",
                        "הַיּוֹם שְׁמוֹנָה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת:",
                        "הַיּוֹם תִּשְׁעָה וְעֶשְׂרִים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת וְיוֹם אֶחָד:",
                        "הַיּוֹם שְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת וּשְׁנֵי יָמִים:",
                        "הַיּוֹם אֶחָד וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת וּשְׁלֹשָׁה יָמִים:",
                        "הַיּוֹם שְׁנַיִם וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת וְאַרְבָּעָה יָמִים:",
                        "הַיּוֹם שְׁלֹשָׁה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים:",
                        "הַיּוֹם אַרְבָּעָה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת וְשִׁשָּׁה יָמִים:",
                        "הַיּוֹם חֲמִשָּׁה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת:",
                        "הַיּוֹם שִׁשָּׁה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת וְיוֹם אֶחָד:",
                        "הַיּוֹם שִׁבְעָה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת וּשְׁנֵי יָמִים:",
                        "הַיּוֹם שְׁמוֹנָה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת וּשְׁלֹשָׁה יָמִים:",
                        "הַיּוֹם תִּשְׁעָה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת וְאַרְבָּעָה יָמִים:",
                        "הַיּוֹם אַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים:",
                        "הַיּוֹם אֶחָד וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם חֲמִשָּׁה שָׁבוּעוֹת וְשִׁשָּׁה יָמִים:",
                        "הַיּוֹם שְׁנַיִם וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת:",
                        "הַיּוֹם שְׁלֹשָׁה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת וְיוֹם אֶחָד:",
                        "הַיּוֹם אַרְבָּעָה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת וּשְׁנֵי יָמִים:",
                        "הַיּוֹם חֲמִשָּׁה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת וּשְׁלֹשָׁה יָמִים:",
                        "הַיּוֹם שִׁשָּׁה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת וְאַרְבָּעָה יָמִים:",
                        "הַיּוֹם שִׁבְעָה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים:",
                        "הַיּוֹם שְׁמוֹנָה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁשָּׁה שָׁבוּעוֹת וְשִׁשָּׁה יָמִים:",
                        "הַיּוֹם תִּשְׁעָה וְאַרְבָּעִים יוֹם לָעֹמֶר, שֶׁהֵם שִׁבְעָה שָׁבוּעוֹת:"]

        let content = UNMutableNotificationContent()
        content.title = "Day of Omer".localized()
        content.sound = .default
        content.subtitle = "Don't forget to count!".localized()
        let dayOfOmer = jewishCalendar.getDayOfOmer()
        if dayOfOmer != -1 && dayOfOmer != 49 {//we don't want to send a notification right before shavuot I.E. 49 + 1
            if lastOmerNotification {
                content.body = omerList[dayOfOmer].appending(" / This is the last omer notification until you open the app".localized())
            } else {
                content.body = omerList[dayOfOmer]
            }

            // Create a notification action
            let action = UNNotificationAction(identifier: "omerAction", title: "See full text".localized(), options: [.foreground])
            // Add the action to the notification content
            content.categoryIdentifier = "omerCategory"
            content.userInfo = ["omerAction": "showView"]
            // Create a notification category
            let category = UNNotificationCategory(identifier: "omerCategory", actions: [action], intentIdentifiers: [], options: [])
            // Register the notification category
            notificationCenter.setNotificationCategories([category])

            //same issue as described in scheduleDailyNotifications()
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zmanimCalendar.getTzeitHacochavim(defaults: defaults) ?? Date()), repeats: false)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            notificationCenter.add(request)
            amountOfNotificationsSet+=1
        }
    }

    fileprivate func addOneDayToCalendars() {
        zmanimCalendar.workingDate = zmanimCalendar.workingDate.advanced(by: 86400)
        jewishCalendar.workingDate = zmanimCalendar.workingDate
    }

    func scheduleSunsetNotifications() {
        if defaults.bool(forKey: "omerNotifications") {
            for _ in 1...13 {
                scheduleOmerNotifications()
                addOneDayToCalendars()
            }
            lastOmerNotification = true
            scheduleOmerNotifications()
            lastOmerNotification = false // clean up for next run
        }
        
        zmanimCalendar.workingDate = Date()
        jewishCalendar.workingDate = zmanimCalendar.workingDate//reset to today

        while !TefilaRules().isVeseinTalUmatarStartDate(jewishCalendar: jewishCalendar) {
            jewishCalendar.forward()
        }//now that the jewish date is set to the date where we change to Barech Aleinu in the morning, make a notification for sunset the day before
        jewishCalendar.back()
        zmanimCalendar.workingDate = jewishCalendar.workingDate
        let contentBarech = UNMutableNotificationContent()
        contentBarech.title = "Barech Aleinu Tonight!".localized()
        contentBarech.sound = .default
        contentBarech.subtitle = locationName
        contentBarech.body = "Tonight we start saying Barech Aleinu!".localized()

        let triggerBarech = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zmanimCalendar.getElevationAdjustedSunset() ?? Date()), repeats: false)

        let request = UNNotificationRequest(identifier: "BarechAleinuNotification", content: contentBarech, trigger: triggerBarech)
        notificationCenter.add(request)
        amountOfNotificationsSet+=1
        zmanimCalendar.workingDate = Date()
        jewishCalendar.workingDate = zmanimCalendar.workingDate//reset to today
    }
    
    func scheduleZmanimNotifications() {
        if !defaults.bool(forKey: "zmanim_notifications") {
            //if zmanim notifications are off, we can use the other local notifications for daily notifications which are the most important in my opinion
            if zmanimCalendar.getElevationAdjustedSunrise()?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 < Date().timeIntervalSince1970 {// if after sunrise, skip today
                addOneDayToCalendars()
            }
            //we already scheduled for 14 days, so advance the dates 15/16 days
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.advanced(by: 86400 * 15)
            jewishCalendar.workingDate = zmanimCalendar.workingDate
            while amountOfNotificationsSet != amountOfPossibleNotifications {
                scheduleDailyNotification()
                addOneDayToCalendars()
            }
            return
        }
        let zmanTimeFormatter = DateFormatter()
        zmanTimeFormatter.dateFormat = (Locale.isHebrewLocale() ? "H" : "h") + ":mm" + (defaults.bool(forKey: "showSeconds") ? ":ss" : "") + (Locale.isHebrewLocale() ? "" : " aa")
        zmanTimeFormatter.timeZone = timezone
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
                              "Plag HaMincha Halacha Berurah",
                              "Plag HaMincha Yalkut Yosef",
                              "Candle Lighting",
                              "Sunset",
                              "Tzeit Hacochavim",
                              "Tzeit Hacochavim (Stringent)",
                              "Fast Ends",
                              "Shabbat Ends",
                              "Rabbeinu Tam",
                              "Chatzot Layla"]

        for string in editableZmanim {
            if !defaults.bool(forKey: "Notify"+string) || defaults.integer(forKey: string) < 0 {
                editableZmanim.remove(at: editableZmanim.firstIndex(of: string)!)//get rid of zmanim we do not want to notify for
            }
        }
        if editableZmanim.isEmpty {
            //if there are no zmanim to notify for, we can use the other local notifications for daily notifications which are the most important in my opinion
            if zmanimCalendar.getElevationAdjustedSunrise()?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 < Date().timeIntervalSince1970 {// if after sunrise, skip today
                addOneDayToCalendars()
            }
            //we already scheduled for 14 days, so advance the date by 15 days
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.advanced(by: 86400 * 15)
            jewishCalendar.workingDate = zmanimCalendar.workingDate
            while amountOfNotificationsSet != amountOfPossibleNotifications {
                scheduleDailyNotification()
                addOneDayToCalendars()
            }
            return
        }
        let isHebrew = defaults.bool(forKey: "isZmanimInHebrew")
        while amountOfNotificationsSet <= amountOfPossibleNotifications {
            var zmanim: Array<ZmanListEntry> = []
            zmanim = ZmanimFactory.addZmanim(list: zmanim, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar)
            for zmanEntry in zmanim {
                let zman = zmanEntry.zman
                if zman != nil && zman ?? Date() > Date() {
                    let zmanContent = UNMutableNotificationContent()
                    zmanContent.title = zmanEntry.title
                    zmanContent.sound = .default
                    zmanContent.subtitle = locationName
                    zmanContent.interruptionLevel = .timeSensitive
                    if isHebrew {
                        zmanContent.body = zmanTimeFormatter.string(from: zman ?? Date()) + " : " + zmanEntry.title
                    } else {
                        zmanContent.body = zmanEntry.title + " is at " + zmanTimeFormatter.string(from: zman ?? Date())
                    }
                    if amountOfNotificationsSet == amountOfPossibleNotifications - 1 {// if this is the last notification being set
                        zmanContent.body = zmanContent.body.appending(" / Last notification until the app is opened again.".localized())
                    }

                    if !defaults.bool(forKey: "zmanim_notifications_on_shabbat") && jewishCalendar.isAssurBemelacha() {
                        //no notification
                    } else {//notify
                        if amountOfNotificationsSet <= amountOfPossibleNotifications && editableZmanim.contains(zmanEntry.desc) {
                            let triggerZman = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: zman?.addingTimeInterval(TimeInterval(-60 * defaults.integer(forKey: zmanEntry.desc))) ?? Date()), repeats: false)
                            let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                                content: zmanContent,
                                                                trigger: triggerZman)
                            notificationCenter.add(request)
                            amountOfNotificationsSet+=1
                        }
                    }
                }
            }
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.advanced(by: 86400)
            jewishCalendar.workingDate = zmanimCalendar.workingDate
        }
//        notificationCenter.getNotificationSettings { settings in
//            if settings.authorizationStatus != .authorized {
//                print("Notifications not authorized!")
//            } else if settings.timeSensitiveSetting == .enabled {
//                print("Time Sensitive notifications are enabled.")
//            } else if settings.timeSensitiveSetting == .disabled {
//                print("Time Sensitive notifications are disabled.")
//            } else if settings.timeSensitiveSetting == .notSupported {
//                print("Time Sensitive notifications are not supported.")
//            }
//        }

        //printPendingNotifications()
    }

    // MARK: - Helper methods

    func initializeLocationObjectsAndSetNotifications() {
        guard !notificationsAreBeingSet else { return }
        notificationsAreBeingSet = true
        
        if defaults.bool(forKey: "useAdvanced") {
            setLocation(defaultsLN: "advancedLN", defaultsLat: "advancedLat", defaultsLong: "advancedLong", defaultsTimezone: "advancedTimezone")
        } else if defaults.bool(forKey: "useLocation1") {
            setLocation(defaultsLN: "location1", defaultsLat: "location1Lat", defaultsLong: "location1Long", defaultsTimezone: "location1Timezone")
        } else if defaults.bool(forKey: "useLocation2") {
            setLocation(defaultsLN: "location2", defaultsLat: "location2Lat", defaultsLong: "location2Long", defaultsTimezone: "location2Timezone")
        } else if defaults.bool(forKey: "useLocation3") {
            setLocation(defaultsLN: "location3", defaultsLat: "location3Lat", defaultsLong: "location3Long", defaultsTimezone: "location3Timezone")
        } else if defaults.bool(forKey: "useLocation4") {
            setLocation(defaultsLN: "location4", defaultsLat: "location4Lat", defaultsLong: "location4Long", defaultsTimezone: "location4Timezone")
        } else if defaults.bool(forKey: "useLocation5") {
            setLocation(defaultsLN: "location5", defaultsLat: "location5Lat", defaultsLong: "location5Long", defaultsTimezone: "location5Timezone")
        } else if defaults.bool(forKey: "useZipcode") {
            setLocation(defaultsLN: "locationName", defaultsLat: "lat", defaultsLong: "long", defaultsTimezone: "timezone")
        } else {
            let concurrentQueue = DispatchQueue(label: "notifiications", attributes: .concurrent)
            LocationManagerForNotifications.shared.getUserLocationForNotifications {
                location in concurrentQueue.async { [self] in
                    lat = location.coordinate.latitude
                    long = location.coordinate.longitude
                    timezone = TimeZone.current
                    zmanimCalendar.useElevation = defaults.bool(forKey: "useElevation")
                    zmanimCalendar.geoLocation = GeoLocation(locationName: locationName, latitude: lat, longitude: long, elevation: elevation, timeZone: timezone)
                    LocationManagerForNotifications.shared.resolveLocationNameForNotifications(with: location) { [self] locationName in
                        self.locationName = locationName ?? ""
                        zmanimCalendar.geoLocation.locationName = self.locationName
                        resolveElevation()
                        zmanimCalendar.geoLocation.elevation = self.elevation
                        jewishCalendar = JewishCalendar(workingDate: Date(), timezone: timezone)
                        jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
                        jewishCalendar.useModernHolidays = true
                        self.scheduleSunriseNotifications()
                        self.scheduleSunsetNotifications()
                        self.scheduleZmanimNotifications()
                        self.notificationsAreBeingSet = false
                    }
                }
            }
            return // prevent the code at the bottom from running since it will happen in the above mmethod's callback
        }
        zmanimCalendar.geoLocation = GeoLocation(locationName: locationName, latitude: lat, longitude: long, elevation: elevation, timeZone: timezone)
        zmanimCalendar.useElevation = defaults.bool(forKey: "useElevation")
        if !defaults.bool(forKey: "hasShownVSNotification") {
            let content = UNMutableNotificationContent()
            content.title = "Setup Visible Sunrise".localized()
            content.sound = .default
            content.body = "Setup visible sunrise now! (Want to try later? Visit the Sunrise description)".localized()
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: Date()), repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            notificationCenter.add(request)
            defaults.set(true, forKey: "hasShownVSNotification")
        }
        scheduleSunriseNotifications()
        scheduleSunsetNotifications()
        scheduleZmanimNotifications()
        notificationsAreBeingSet = false
    }
        
    func setLocation(defaultsLN:String, defaultsLat:String, defaultsLong:String, defaultsTimezone:String) {
        locationName = defaults.string(forKey: defaultsLN) ?? ""
        lat = defaults.double(forKey: defaultsLat)
        long = defaults.double(forKey: defaultsLong)
        resolveElevation()
        timezone = TimeZone.init(identifier: defaults.string(forKey: defaultsTimezone) ?? TimeZone.current.identifier) ?? TimeZone.current
        jewishCalendar = JewishCalendar(workingDate: Date(), timezone: timezone)
        jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
        jewishCalendar.useModernHolidays = true
    }
    
    func resolveElevation() {
        if self.defaults.object(forKey: "elevation" + self.locationName) != nil {//if we have been here before, use the elevation saved for this location
            if self.defaults.bool(forKey: "useElevation") {
                self.elevation = self.defaults.double(forKey: "elevation" + self.locationName)
            } else {
                self.elevation = 0
            }
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
    }
 

    func getShabbatAndOrChag() -> String {
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
    
    func printPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("🚀 Pending Notifications: \(requests.count)")
            for request in requests {
                //print("🔔 Identifier: \(request.identifier)")
                print("📅 Trigger: \(String(describing: request.trigger))")
                print("📝 Content: \(request.content.body)")
            }
        }
    }

}
