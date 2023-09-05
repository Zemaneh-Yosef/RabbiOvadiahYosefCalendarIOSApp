//
//  ZmanimAlertInfoHolder.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/30/23.
//

import Foundation
import UIKit

struct ZmanimAlertInfoHolder {
    
    var title = ""
    var mIsZmanimInHebrew = false
    var mIsZmanimEnglishTranslated = false
    
    func getFullTitle() -> String {
        let zmanimNames = ZmanimTimeNames(mIsZmanimInHebrew: mIsZmanimInHebrew, mIsZmanimEnglishTranslated: mIsZmanimEnglishTranslated)
        if title.contains(zmanimNames.getAlotString()) {
            return "Dawn - Alot Hashachar - עלות השחר"
        }
        if title.contains(zmanimNames.getTalitTefilinString()) {
            return "Earliest Talit/Tefilin - טלית ותפילין"
        }
        if title.contains(zmanimNames.getHaNetzString()) {
            return "Sunrise - HaNetz - הנץ"
        }
        if title.contains(zmanimNames.getAchilatChametzString()) {
            return "Sof Zman Achilat Chametz - Latest time to eat Chametz - סוף זמן אכילת חמץ"
        }
        if title.contains(zmanimNames.getBiurChametzString()) {
            return "Latest time to burn Chametz - Sof Zman Biur Chametz - סוף זמן ביעור חמץ"
        }
        if title.contains(zmanimNames.getShmaMgaString()) {
            return "Latest Shma MG\"A - Sof Zman Shma MG\"A - סוף זמן שמע מג\"א"
        }
        if title.contains(zmanimNames.getShmaGraString()) {
            return "Latest Shma GR\"A - Sof Zman Shma GR\"A - סוף זמן שמע גר\"א"
        }
        if title.contains(zmanimNames.getBrachotShmaString()) {
            return "Latest Brachot Shma - Sof Zman Brachot Shma - סוף זמן ברכות שמע"
        }
        if title.contains(zmanimNames.getChatzotString()) {
            return "Mid-day - Chatzot - חצות"
        }
        if title.contains(zmanimNames.getMinchaGedolaString()) {
            return "Earliest Mincha - Mincha Gedola - מנחה גדולה"
        }
        if title.contains(zmanimNames.getMinchaKetanaString()) {
            return "Mincha Ketana - מנחה קטנה"
        }
        if title.contains(zmanimNames.getPlagHaminchaString()) {
            return "Plag HaMincha - פלג המנחה"
        }
        if title.contains(zmanimNames.getCandleLightingString()) {
            return "Candle Lighting - הדלקת נרות"
        }
        if title.contains(zmanimNames.getSunsetString()) {
            return "Sunset - Shkia - שקיעה"
        }
        if title.contains(zmanimNames.getTzaitHacochavimString()) {
            return "Nightfall - Tzait Hacochavim - צאת הכוכבים"
        }
        if title.contains(zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() + " " + zmanimNames.getLChumraString()) {
            return "Fast Ends (Stringent) - Tzeit Taanit L'Chumra - צאת תענית לחומרה"
        }
        if title.contains(zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString()) {
            return "Fast Ends - Tzeit Taanit - צאת תענית"
        }
        if title.contains("Shabbat") || title.contains("Chag") || title.contains("\u{05E9}\u{05D1}\u{05EA}") || title.contains("\u{05D7}\u{05D2}") {
            return "Shabbat/Chag Ends - Tzeit Shabbat/Chag - צאת \u{05E9}\u{05D1}\u{05EA}/\u{05D7}\u{05D2}"
        }
        if title.contains(zmanimNames.getRTString()) {
            return "Rabbeinu Tam - רבינו תם"
        }
        if title.contains(zmanimNames.getChatzotLaylaString()) {
            return "Midnight - Chatzot Layla - חצות לילה"
        }
        if title.contains("וּלְכַפָּרַת פֶּשַׁע") {
            return "וּלְכַפָּרַת פֶּשַׁע"
        }
        if title.contains("Tekufa") {
            return "Tekufa - Season"
        }
        if title.contains("Three Weeks") || title.contains("Nine Days") || title.contains("Shevuah Shechal Bo") {
            return title
        }
        
        return ""
    }
    
    func getFullMessage() -> String {//these strings were brought over from java. Hence all the concatenation
        let zmanimNames = ZmanimTimeNames(mIsZmanimInHebrew: mIsZmanimInHebrew, mIsZmanimEnglishTranslated: mIsZmanimEnglishTranslated)
        if title.contains(zmanimNames.getAlotString()) {
            return "In Tanach this time is called Alot HaShachar (בראשית לב:כה), whereas in the gemara it is called Amud HaShachar.\n\n" +
            "This is the time when the day begins according to halacha. " +
            "Most mitzvot (commandments), Arvit for example, that take place at night are not allowed " +
            "to be done after this time.\nAfter this time, mitzvot that must be done in the daytime are " +
            "allowed to be done B'dieved (after the fact) or B'shaat hadachak (in a time of need). However, one should ideally wait " +
            "until sunrise to do them L'chatchila (optimally).\n\n" +
            "This time is calculated as 72 zmaniyot/seasonal minutes (according to the GR\"A) before sunrise. Both sunrise and sunset " +
            "have elevation included.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated by finding out how many minutes " +
            "are between sunrise and 72 minutes as degrees (16.04) before sunrise on a equal day with sunrise and sunset set around 12 " +
            "hours apart. Then we take those minutes and make them zmaniyot according to the GR\"A and we subtract that time from " +
            "sunrise to get the time for Alot Hashachar. This is according to the Halacha Berurah and this should only be done outside of Israel in more northern or southern areas."
        }
        if title.contains(zmanimNames.getTalitTefilinString()) {
            return "Misheyakir (literally \"when you recognize\") is the time when a person can distinguish between blue and white. " +
            "The gemara (ברכות ט) explains that when a person can distinguish between the blue (techelet) and white strings " +
            "of their tzitzit, that is the earliest time a person can put on their talit and tefilin for shacharit.\n\n" +
            "This is also the earliest time one can say Shema L'chatchila (optimally).\n\n" +
            "This time is calculated as 6 zmaniyot/seasonal minutes (according to the GR\"A) after Alot HaShachar (Dawn).\n\n" +
            "Note: This time is only for people who need to go to work or leave early in the morning to travel, however, normally a " +
            "person should put on his talit/tefilin 60 regular minutes (and in the winter 50 regular minutes) before sunrise.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated by finding out how many minutes " +
            "are between sunrise and 72 minutes as degrees (16.04) before sunrise on a equal day with sunrise and sunset set around 12 " +
            "hours apart. Then we take those minutes and make them zmaniyot according to the GR\"A and we subtract 5/6 of that time from " +
            "sunrise to get the time for Misheyakir. This is according to the Halacha Berurah and this should only be done outside of " +
            "Israel in more northern or southern areas. " +
            "Elevation is not included in Luach Amudei Horaah mode."
        }
        if title.contains(zmanimNames.getHaNetzString()) {
            return "This is the earliest time when all mitzvot (commandments) that are to be done during the daytime are allowed to be " +
            "performed L'chatchila (optimally). Halachic sunrise is defined as the moment when the top edge of the sun appears on the " +
            "horizon while rising. Whereas, the gentiles define sunrise as the moment when the sun is halfway through the horizon. " +
            "This halachic sunrise is called mishor (sea level) sunrise and it is what many jews rely on when praying for Netz.\n\n" +
            "However, it should be noted that the Shulchan Aruch writes in Orach Chayim 89:1, \"The mitzvah of shacharit starts at " +
            "Netz, like it says in the pasuk/verse, 'יראוך עם שמש'\". Based on this, the poskim write that a person should wait until " +
            "the sun is VISIBLE to say shacharit. In Israel, the Ohr HaChaim calendar uses a table of sunrise times from the " +
            "luach/calendar 'לוח ביכורי יוסף' (Luach Bechoray Yosef) each year. These times were made by Chaim Keller, creator of the " +
            "ChaiTables website. Ideally, you should download these VISIBLE sunrise times from his website with the capability of " +
            "this app by pressing the button below. However, if you did not download the times, you will see 'Mishor' or 'Sea Level' " +
            "sunrise instead."
        }
        if title.contains(zmanimNames.getAchilatChametzString()) {
            return "This is the latest time a person can eat chametz.\n\n" +
            "This is calculated as 4 zmaniyot/seasonal hours, according to the Magen Avraham, after Alot HaShachar (Dawn) with " +
            "elevation included. Since Chametz is a mitzvah from the torah, we are stringent and we use the Magen Avraham's time to " +
            "calculate the last time a person can eat chametz.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated the same way as above except using the skewed Alot/Tzait of the " +
            "Amudei Horaah calendar, and no elevation is included."
        }
        if title.contains(zmanimNames.getBiurChametzString()) {
            return "This is the latest time a person can own chametz before pesach begins. You should get rid of all chametz in your " +
            "possession by this time.\n\n" +
            "This is calculated as 5 zmaniyot/seasonal hours, according to the MG\"A, after Alot HaShachar (Dawn) with " +
            "elevation included.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated the same way as above except using the skewed Alot/Tzait of the " +
            "Amudei Horaah calendar, and no elevation is included."
        }
        if title.contains(zmanimNames.getShmaMgaString()) {
            return "This is the latest time a person can fulfill his obligation to say Shma everyday according to the Magen Avraham.\n\n" +
            "The Magen Avraham/Terumat HeDeshen calculate this time as 3 zmaniyot/seasonal hours after Alot HaShachar (Dawn). " +
            "They calculate a zmaniyot/seasonal hour by taking the time between Alot HaShachar (Dawn) and Tzeit Hachocavim (Nightfall) " +
            "of Rabbeinu Tam and divide it into 12 equal parts.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated the same way as above except using the skewed Alot/Tzait of the " +
            "Amudei Horaah calendar, and no elevation is included."
        }
        if title.contains(zmanimNames.getShmaGraString()) {
            return "This is the latest time a person can fulfill his obligation to say Shma everyday according to the GR\"A " +
            "(HaGaon Rabbeinu Eliyahu)" + "\n\n" +
            "The GR\"A calculates this time as 3 zmaniyot/seasonal hours after sunrise (elevation included). " +
            "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
            "divides it into 12 equal parts.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated the same way as above except no elevation is included."
        }
        if title.contains(zmanimNames.getBrachotShmaString()) {
            return "This is the latest time a person can say the Brachot Shma according to the GR\"A. However, a person can still say " +
            "Pisukei D'Zimra until Chatzot.\n\n" +
            "The GR\"A calculates this time as 4 zmaniyot/seasonal hours after sunrise (elevation included). " +
            "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
            "divides it into 12 equal parts.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated the same way as above except no elevation is included."
        }
        if title.contains(zmanimNames.getChatzotString()) {
            return "This is the middle of the halachic day, when the sun is exactly in the middle of the sky relative to the length of the" +
            " day. It should be noted, that the sun can only be directly above every person, such that they don't even have shadows, " +
            "in the Tropic of Cancer and the Tropic of Capricorn. Everywhere else, the sun will be at an angle even in the middle of " +
            "the day.\n\n" +
            "After this time, you can no longer say the Amidah prayer of Shacharit, and you should preferably say Musaf before this " +
            "time.\n\n" +
            "This time is calculated as 6 zmaniyot/seasonal hours after sunrise. " +
            "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
            "divides it into 12 equal parts.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated the same way as above except no elevation is included."
        }
        if title.contains(zmanimNames.getMinchaGedolaString()) {
            return "Mincha Gedolah, literally \"Greater Mincha\", is the earliest time a person can say Mincha. " +
            "It is also the preferred time a person should say Mincha according to some poskim.\n\n" +
            "It is called Mincha Gedolah because there is a lot of time left until sunset.\n\n" +
            "A person should ideally start saying Korbanot AFTER this time.\n\n" +
            "This time is calculated as 30 regular minutes after Chatzot (Mid-day). However, if the zmaniyot/seasonal minutes are longer," +
            " we use those minutes instead to be stringent. " +
            "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
            "divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated the same way as above except no elevation is included."
        }
        if title.contains(zmanimNames.getMinchaKetanaString()) {
            return "Mincha Ketana, literally \"Lesser Mincha\", is the most preferred time a person can say Mincha according to some poskim.\n\n" +
            "It is called Mincha Ketana because there is less time left until sunset.\n\n" +
            "This time is calculated as 9 and a half zmaniyot/seasonal hours after sunrise. " +
            "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
            "divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute."
        }
        if title.contains(zmanimNames.getPlagHaminchaString()) {
            return "Plag HaMincha, literally \"Half of Mincha\", is the midpoint between Mincha Ketana and sunset. Since Mincha Ketana is " +
            "2 and a half hours before sunset, Plag is half of that at an hour and 15 minutes before sunset.\n" +
            "You can start saying arvit/maariv by this time according to Rabbi Yehudah in (ברכות כ'ו ע'א).\n\n" +
            "A person should not accept shabbat before this time as well.\n\n" +
            "The Halacha Berurah says to calculate this time by subtracting an hour and 15 zmaniyot minutes from sunset, however, the " +
            "Yalkut Yosef says to calculate it as 1 hour and 15 zmaniyot/seasonal minutes before tzeit (13.5 zmaniyot minutes). \n\n" +
            "In Luach Amudei Horaah mode, both ways to calculate this zman are shown. The only difference is that the tzeit of the " +
            "Amudei Horaah is used instead of the regular 13.5 zmaniyot minutes.\n\n" +
            "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
            "divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute."
        }
        if title.contains(zmanimNames.getCandleLightingString()) {
            return "This is the ideal time for a person to light the candles before shabbat/chag starts.\n\n" +
            "When there is candle lighting on a day that is Yom tov/Shabbat before another day that is Yom tov, " +
            "the candles are lit after Tzeit/Nightfall. However, if the next day is Shabbat, the candles are lit at their usual time.\n\n" +
            "This time is calculated as 20 " +
            "regular minutes before sunset (elevation included).\n\n" +
            "The Ohr HaChaim calendar always shows the candle lighting time as 20 and 40 minutes before sunset."
        }
        if title.contains(zmanimNames.getSunsetString()) {
            return "This is the time of the day that the day starts to transition into the next day according to halacha.\n\n" +
            "Halachic sunset is defined as the moment when the top edge of the sun disappears on the " +
            "horizon while setting (elevation included). Whereas, the gentiles define sunset as the moment when the sun is halfway " +
            "through the horizon.\n\n" +
            "Immediately after the sun sets, Bein Hashmashot/twilight starts according to the Geonim, however, according to Rabbeinu Tam " +
            "the sun continues to set for another 58.5 minutes and only after that Bein Hashmashot starts for another 13.5 minutes.\n\n" +
            "It should be noted that many poskim, like the Mishna Berura, say that a person should ideally say mincha BEFORE sunset " +
            "and not before Tzeit/Nightfall.\n\n" +
            "Most mitzvot that are to be done during the day should ideally be done before this time."
        }
        if title.contains(zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString()) {
            return "This time is calculated as 20 minutes after sunset (elevation included).\n\n" +
            "This time is important for fast days and deciding when to do a brit milah. Otherwise, it should not be used for anything else like the latest time for mincha.\n\n" +
            "This time is shown in gray on shabbat and yom tov (as advised by my rabbeim) in order to not let people think that shabbat/yom tov ends at this time.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated by finding out the the amount of minutes between sunset and 5.3 " +
            "degrees below the horizon on a equal day, then we add that amount of zmaniyot minutes to sunset to get the time of " +
            "Tzeit/Nightfall. We use 5.3 degrees below the horizon because that is the time when it is 20 minutes after sunset in Israel."
        }
        if title.contains(zmanimNames.getTzaitHacochavimString()) {
            return "Tzeit/Nightfall is the time when the next halachic day starts after Bein Hashmashot/twilight finishes.\n\n" +
            "This is the latest time a person can say Mincha according Rav Ovadiah Yosef Z\"TL. A person should start mincha at " +
            "least 2 minutes before this time.\n\n" +
            "This time is shown in gray on shabbat and yom tov (as advised by my rabbeim) in order to not let people think that shabbat/yom tov ends at this time.\n\n" +
            "This time is calculated as 13 and a half zmaniyot/seasonal minutes after sunset (elevation included).\n\n" +
            "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
            "divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated by finding out the the amount of minutes between sunset and 3.75 " +
            "degrees below the horizon on a equal day, then we add that amount of zmaniyot minutes to sunset to get the time of " +
            "Tzeit/Nightfall. We use 3.75 degrees below the horizon because that is the time when it is 13.5 minutes after sunset in Israel."
        }
        if title.contains(zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() + " " + zmanimNames.getLChumraString()) {
            return "This is a more stringent time that the fast/taanit ends. This time is according to the opinion of Chacham Ben Zion Abba" +
            " Shaul.\n\n" +
            "This time is calculated as 30 regular minutes after sunset (elevation included)."
        }
        if title.contains(zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString()) {
            return "This is the time that the fast/taanit ends.\n\n" +
            "This time is calculated as 20 regular minutes after sunset (elevation included).\n\n" +
            "It is brought down in Halacha Berurah that Rabbi Ovadiah Yosef Z\"TL was once traveling in New York and he said to his son, " +
            "Rabbi David Yosef Shlita, that the fast ends 13.5 zmaniyot minutes after sunset. However, in his sefer Chazon Ovadiah, he " +
            "writes that the fast ends 20 minutes after sunset.\n\n" +
            "In the Ohr HaChaim calendar, they write that the fast ends at Tzait Hacochavim. I asked Rabbi Benizri if this meant that " +
            "the fast ends at 13.5 zmaniyot minutes after sunset and he said, \"Not necessarily, the calendar just says that the fast ends " +
            "at Tzait Hacochavim, a person can end the fast at 20 minutes " +
            "after sunset if he wants to be stringent.\" I then asked him if those 20 minutes are zmaniyot minutes or regular minutes " +
            "and he said, \"Regular minutes.\"\n\n" +
            "To summarize: If a person wants to end the fast at 13.5 zmaniyot minutes after sunset, he has the right to do so. However, if a person wants to " +
            "be stringent, he can end the fast at 20 minutes after sunset."
        }
        if title.contains("Shabbat Ends") || title.contains("Chag Ends") || title.contains("Tzait Shabbat") || title.contains("Tzait Chag") || title.contains("צאת שבת/חג") || title.contains("צאת שבת") || title.contains("צאת חג") {
            return "This is the time that Shabbat/Chag ends.\n\n" +
            "Note that there are many customs on when shabbat ends, by default, it is set to 40 regular minutes after sunset (elevation " +
            "included) outside of Israel and 30 regular minutes after sunset inside Israel. I used 40 minutes because Rabbi Meir Gavriel " +
            "Elbaz Shlita has told me that anywhere outside of Israel, " +
            "if you wait 40 regular minutes after sunset, that is enough time to end shabbat." +
            "You can change this time in the settings to accommodate your communities minhag.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated by using a degree of 7.14. We use this degree because " +
            "Rabbi Ovadiah Yosef ZT\"L ruled that regarding Motzeh Shabbat the listed time should be set as 30 fixed minutes after " +
            "sunset. This degree is interpreted as 30 minutes after sunset all year round in Israel."
        }
        if title.contains(zmanimNames.getRTString()) {
            return "This time is Tzeit/Nightfall according to Rabbeinu Tam.\n\n" +
            "Tzeit/Nightfall is the time when the next halachic day starts after Bein Hashmashot/twilight finishes.\n\n" +
            "This time is calculated as 72 zmaniyot/seasonal minutes after sunset (elevation included). " +
            "According to Rabbeinu Tam, these 72 minutes are made up of 2 parts. The first part is 58 and a half minutes until the " +
            "second sunset (see Pesachim 94a and Tosafot there). After the second sunset, there are an additional 13.5 minutes until " +
            "Tzeit/Nightfall.\n\n" +
            "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
            "divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute in order " +
            "to calculate 72 minutes. Another way of calculating this time is by calculating how many minutes are between sunrise and " +
            "sunset. Take that number and divide it by 10, and then add the result to sunset. The app uses the first method.\n\n" +
            "In Luach Amudei Horaah mode, this time is calculated by finding out how many minutes " +
            "are between sunset and 72 minutes as degrees (16.0) after sunset on a equal day with sunrise and sunset set around 12 " +
            "hours apart. Then we take those minutes and make them zmaniyot according to the GR\"A and we add that time to " +
            "sunset to get the time for Rabbeinu Tam. This is according to the Halacha Berurah and this should only be done outside of " +
            "Israel in more northern or southern areas. The Halacha Berurah writes to do this because it is more according to the nature " +
            "of the world, however, it does not seem like Rabbi Ovadiah Yosef ZT\"L or the Yalkut Yosef agrees with this opinion. " +
            "Elevation is not included in Luach Amudei Horaah mode.\n\n" +
            "It should be noted that Rabbi Ovadiah Yosef ZT\"L was of the opinion to keep the zmaniyot zman of rabbeinu tam whether or " +
            "not it fell out before or after 72 regular minutes after sunset. However, in Luach Amudei Horaah mode, we use the lesser of " +
            "the two times."
        }
        if title.contains(zmanimNames.getChatzotLaylaString()) {
            return "This is the middle of the halachic night, when the sun is exactly in the middle of the sky beneath us.\n\n" +
            "It is best to have Melaveh Malka before this time.\n\n" +
            "This time is calculated as 6 zmaniyot/seasonal hours after sunset. " +
            "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
            "divides it into 12 equal parts.\n\n"
        }
        if title.contains("וּלְכַפָּרַת פֶּשַׁע") {
            return "When Rosh Chodesh happens during a leap year, we add the words, \"וּלְכַפָּרַת פֶּשַׁע\" during Musaf. We only add these words from Tishri until the second month of Adar. However, for the rest of the year and during non leap years we do not say it."
        }
        if title.contains("Tekufa") {
            return "This is the time that the tekufa (season) changes.\n\nThere are 4 tekufas every year: Tishri (autumn), Tevet (winter), " +
            "Nissan (spring), and Tammuz (summer). Each Tekufa happens 91.3125 (365.25 / 4) days after the previous Tekufa.\n\n" +
            "The Achronim write that a person should not drink water when the seasons change. Rabbi Ovadiah Yosef Z\"TL writes " +
            "(in Halichot Olam, Chelek 7, Page 183, Halacha 8) that a person should not drink water from a half hour before this time " +
            "till a half hour after this time unless there is a slim piece of iron in the water.\n\nNOTE: This only applies to water, not " +
            "to other drinks." + "\n\n" +
            "Both the Ohr HaChaim and the Amudei Horaah calendars use the above method to get the time for the tekufa. However, the " +
            "Amudei Horaah calendar differs from the Ohr HaChaim calendar, by using the local midday time of Israel. Which causes a 21 " +
            "minute difference. " +
            "Therefore, the Amudei Horaah calendar time for the tekufa will always be 21 minutes before the Ohr HaChaim's time.\n\n" +
            "In practice, it is recommended to keep both times if possible as it is only adding an additional 21 minutes."
        }
        if title.contains("Tachanun") || title.contains("צדקתך") {
            return "Here is a list of days with no tachanun:\n\n" +
            "Rosh Chodesh\n" +
            "The entire month of Nissan\n" +
            "Pesach Sheni (14th of Iyar)\n" +
            "Lag Ba'Omer\n" +
            "Rosh Chodesh Sivan until the 12th of Sivan (12th included)\n" +
            "9th of Av\n" +
            "15th of Av\n" +
            "Erev Rosh Hashanah and Rosh Hashanah\n" +
            "Erev Yom Kippur and Yom Kippur\n" +
            "From the 11th of Tishrei until the end of Tishrei\n" +
            "All of Chanukah\n" +
            "15th of Shevat\n" +
            "14th and 15th of Adar I and Adar II (and only 14th of Adar I in a leap year)\n" +
            "Every Shabbat\n" +
            "Every Erev Rosh Chodesh\n" +
            "Fast of Esther\n" +
            "Tisha Be'av\n" +
            "Tu Be'Shvat\n" +
            "Lag Ba'Omer\n" +
            "Pesach Sheni\n" +
            "Yom Yerushalayim but not Yom Ha'atzmaut (according to the minhag of Rabbi Ovadiah ZT\"L)\n\n" +
            "Note that there are other times you should not say tachanun, but this list is only for days with no tachanun. Sometimes " +
            "you can skip tachanun if there are mourners making up majority of the minyan or if there is a simcha (joyous occasion)."
        }
        if title.contains("Three Weeks") || title.contains("Nine Days") || title.contains("Shevuah Shechal Bo") {
            return "During the time of the Three weeks/Nine days/Shevuah shechal bo " +
            "certain restrictions apply:\n\n" +
            "Three Weeks:\n" +
            "No listening to music\n" +
            "Better to delay shehechiyanu\n\n" +
            "Nine Days:\n" +
            "No listening to music\n" +
            "Better to delay shehechiyanu\n" +
            "Better to delay any construction\n" +
            "No weddings\n" +
            "No purchasing new clothing (unless there is great need ex: a sale)\n" +
            "No consumption of meat or wine (excludes Rosh Chodesh and Shabbat)\n" +
            "No wearing brand new clothing\n\n" +
            "Shevuah Shechal Bo:\n" +
            "No listening to music\n" +
            "Better to delay shehechiyanu\n" +
            "No construction\n" +
            "No weddings\n" +
            "No purchasing new clothing (unless there is great need ex: a sale)\n" +
            "No consumption of meat or wine\n" +
            "No wearing brand new clothing\n" +
            "No taking haircuts or shaving (Men Only)\n" +
            "No swimming\n" +
            "No showering (with hot water)\n" +
            "No laundry\n" +
            "No wearing freshly laundered clothing (excludes undergarments)\n"
        }
        
        return ""
    }
    
}
