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
        if title == zmanimNames.getAlotString() {
            return "Dawn - Alot Hashachar - עלות השחר"
        }
        if title.contains(zmanimNames.getTalitTefilinString()) {
            return "Earliest Talit/Tefilin - טלית ותפילין"
        }
        if title.contains(zmanimNames.getHaNetzString()) {
            return "Sunrise - HaNetz - הנץ"
        }
        if title == zmanimNames.getAchilatChametzString() {
            return "Sof Zman Achilat Chametz - Latest time to eat Chametz - סוף זמן אכילת חמץ"
        }
        if title == zmanimNames.getBiurChametzString() {
            return "Latest time to burn Chametz - Sof Zman Biur Chametz - סוף זמן ביעור חמץ"
        }
        if title == zmanimNames.getShmaMgaString() {
            return "Latest Shma MG\"A - Sof Zman Shma MG\"A - סוף זמן שמע מג\"א"
        }
        if title == zmanimNames.getShmaGraString() {
            return "Latest Shma GR\"A - Sof Zman Shma GR\"A - סוף זמן שמע גר\"א"
        }
        if title == zmanimNames.getBrachotShmaString() {
            return "Latest Brachot Shma - Sof Zman Brachot Shma - סוף זמן ברכות שמע"
        }
        if title == zmanimNames.getChatzotString() {
            return "Mid-day - Chatzot - חצות"
        }
        if title == zmanimNames.getMinchaGedolaString() {
            return "Earliest Mincha - Mincha Gedola - מנחה גדולה"
        }
        if title == zmanimNames.getMinchaKetanaString() {
            return "Mincha Ketana - מנחה קטנה"
        }
        if title.contains(zmanimNames.getPlagHaminchaString()) {
            return "Plag HaMincha - פלג המנחה"
        }
        if title.contains(zmanimNames.getCandleLightingString()) {
            return "Candle Lighting - הדלקת נרות"
        }
        if title == zmanimNames.getSunsetString() {
            return "Sunset - Shkia - שקיעה"
        }
        if title == zmanimNames.getTzaitHacochavimString() {
            return "Nightfall - Tzait Hacochavim - צאת הכוכבים"
        }
        if title == zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString() {
            return "Nightfall (Stringent) - Tzait Hacochavim L'Chumra - צאת הכוכבים לחומרא"
        }
        if title == zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() + " " + zmanimNames.getLChumraString() {
            return "Fast Ends (Stringent) - Tzeit Taanit L'Chumra - צאת תענית לחומרא"
        }
        if title == zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() {
            return "Fast Ends - Tzeit Taanit - צאת תענית"
        }
        if title.contains("Shabbat") || title.contains("Chag") || title.contains("\u{05E9}\u{05D1}\u{05EA}") || title.contains("\u{05D7}\u{05D2}") {
            return "Shabbat/Chag Ends - Tzeit Shabbat/Chag - צאת \u{05E9}\u{05D1}\u{05EA}/\u{05D7}\u{05D2}"
        }
        if title == zmanimNames.getRTString() {
            return "Rabbeinu Tam - רבינו תם"
        }
        if title == zmanimNames.getChatzotLaylaString() {
            return "Midnight - Chatzot Layla - חצות הלילה"
        }
        if title.contains("וּלְכַפָּרַת פֶּשַׁע") {
            return "וּלְכַפָּרַת פֶּשַׁע"
        }
        if title.contains("Tekufa".localized()) {
            return "Tekufa - Season"
        }
        if title.contains("Three Weeks".localized()) || title.contains("Nine Days".localized()) || title.contains("Shevuah Shechal Bo".localized()) {
            return title
        }
        if title.contains("ברכת החמה") || title.contains("Birchat HaChamah") {
            return "Latest Birchat HaChamah - סוף זמן ברכת החמה - Sof Zman Birchat HaChamah"
        }
        if title.contains("ברכת הלבנה") || title.contains("Birchat HaLevana") {
            return "ברכת הלבנה - Birchat Halevana"
        }
        if title.contains("שמיטה") || title.contains("Shmita") {
            return "Shmita - שמיטה"
        }
        
        return ""
    }
    
    func getFullMessage() -> String {//these strings were brought over from java. Hence all the concatenation
        let zmanimNames = ZmanimTimeNames(mIsZmanimInHebrew: mIsZmanimInHebrew, mIsZmanimEnglishTranslated: mIsZmanimEnglishTranslated)
        if title == zmanimNames.getAlotString() {
            if Locale.isHebrewLocale() {
                return "בתנ\"ך, הזמן הזה נקרא \"עלות השחר\" (בראשית ל\"ב:כ\"ה), בעוד בגמרא הוא נקרא \"עמוד השחר\".  זהו הזמן בו מתחיל היום לפי ההלכה. רוב המצוות, דוגמת ערבית, שמתבצעות בלילה, אסורות להתבצע אחרי הזמן הזה. לאחריו, מצוות שחייבות להתבצע בזמן היום מותרות להתבצע בדיעבד או בשעת הדחק. אף על פי כן, יש לחכות עד לזריחה כדי לממש אותן לפי הלכה.  הזמן הזה נחשב ל-72 דקות זמניות (על פי הגר\"א) לפני הזריחה. גם הזריחה והשקיעה משתנות בהתעלות.  במצב לוח עמודי הוראה, הזמן הזה מחושב על ידי מציאת מספר הדקות שבין הזריחה ל-72 דקות כמות מעלות (16.04) לפני הזריחה ביום שווה עם הזריחה והשקיעה מוגדרים בתקופה של 12 שעות. לאחר מכן, אנחנו מעבירים את הדקות האלו לזמניות על פי הגר\"א ומחסרים אותו מהזמן של העלות השחר. זה על פי הלכה ברורה ועל המרצים לבצע זאת רק מחוץ לישראל באזורים צפוניים או דרומיים יותר."
            } else {
                return """
Dawn begins the halachic day, signified by the visibility of the sun's rays in the illuminated eastern sky. (Rosh, Berakhoth 4:1; Rambam Pirush Mishnayoth Yoma 3:1; Shulḥan Arukh O.Ḥ. 89:1). In Hebrew, this time is either called עלות השחר (as used in Genesis 32:25; Variant of וכמו השחר עלה is used in Genesis 19:15) or עמוד השחר (as used in משנה ברכות א:א). It's the moment that transitions from the night's commandments (examples: תיקון רחל, קריאת שמע של ערבית & תפילת ערבית) to the days commandments (like not eating before prayer; S"A O"Ḥ 89:5), even if not a full-proof perfect one. This is because there are cases where the night's commandments (קריאת שמע בלי ברכת השכיבנו) could still be done into the day, and practically, one should still not perform positive commandments (such as prayer) until sunrise (unless there is a pressing circumstance. Also, one who erroneously did any commndment before sunrise is exempt post-facto).

---

These Halachic times are determined not through what our eyes see (whether the sky correlates to the astronomical description of Dawn above), but rather through measurements. On the average day (where there are 12 hours of day and 12 hours of night), one could measure the length of the day from sunrise to sunset, break them up into smaller units called "mil" - each spanning 18 minutes (ש"ע או"ח תנט:ב), and use 4 of those mil (as held by R' Yehuda, פסחים בבלי צד) to get to a Dawn time that takes place 72 minutes before sunrise.

The codification of this law from our authorities views the context of the Talmud (Israel on the spring equinox - Erev Pesaḥ) as a means to create an astronomical parralel of where the sun is below the horizon (16.04 degrees) to the passage of time; however, when the parameters change (such as the different days of the calendar or different locations than Israel), we maintain the time length of twilight would also accommodate.

Recreating the context of the Gemara is as easy as applying the sun's position ("degree") below the horizon on the equinox day at those minutes to the respective location. [Halacha Berurah (intro to siman 261 halacha 13), based on Minḥath Kohen (2 4), Pri Ḥadash (Kuntres DeBey Shimshey 8) & Bet David (104). Although R David writes one should only be stringent and increase, the logic of using it for leniencies by regular seasonal minutes also apply by these adjusted-seasonal minutes] One could then measure the time that this astronomical event takes place until sunrise to get the length of twilight fitting for that location. To fit it with the normative Sepharadic custom of using minutes based on how long the sun is above the horizon, this twilight period is then lengthened/shortened accordingly. (see further: מנחת כהן (מבוא השמש מאמר ב פרק ג) על שו"ת פאר הדור 44. זה פסק של מרן עובדיה, והביא ראיה מבא"ח (שנא ראשונה - וארא ה, ויקהל ד, צב ח; שנא שניא - נח ז; רב פעלים ב:ב), וכן הסכים הילקוט יוסף (נ"ח:ג))

The calendar times generated using our formula may result in either a leniency or a stringency, dependent on the scenario & the other time used in the comparsion. Due to the nature of how reliant we are on our time, *any* other formula that would generate more comfortable/lenient times may **not** be used to supersede our "stringencies", considering they use premises not adopted by our authorities. See י"י (מהדורת תשפ"א) עמוד תעה סימן פט:יב for further information.
                """
            }
        }
        if title == zmanimNames.getTalitTefilinString() {
            if Locale.isHebrewLocale() {
                return "\"משייכיר\" (במשמעות הלמידי \"כאשר אתה מכיר\") הוא הזמן בו אדם יכול להבחין בין כחול ללבן. הגמרא (ברכות ט) מסבירה שכאשר אדם יכול להבחין בין החוטים הכחולים (תכלת) והחוטים הלבנים שבציציתו, זהו הזמן המוקדם ביותר בו אדם יכול ללבוש את הטלית והתפילין לשחרית.  זהו גם הזמן המוקדם ביותר בו אפשר לקרוא את שמע לפי הלכה לכתחילה.  הזמן הזה מחושב כ-6 דקות זמניות (על פי הגר\"א) לאחר \"עלות השחר\".  הערה: הזמן הזה הוא רק לאנשים שצריכים לצאת לעבודה או לנסוע בשעות הראשונות של הבוקר, אך בדרך כלל אדם צריך ללבוש את הטלית והתפילין שעה רגילה ובחורף 50 דקות רגילות לפני הזריחה.  במצב של \"לוח עמודי הוראה\", הזמן הזה מחושב על ידי מציאת מספר הדקות שבין הזריחה ל-72 דקות כמויות מעלות (16.04) לפני הזריחה ביום שווה עם הזריחה והשקיעה מוגדרות במרחק כשעתיים זמן ממוצע זה משתנה מדי. לאחר מכן, אנחנו ממירים את הדקות האלו לזמניות על פי הגר\"א ומחסרים 5/6 מהזמן הזה מהזמן של הזריחה כדי לקבוע את הזמן של \"משייכיר\". זה נעשה על פי הלכה ברורה ויש לעשות זאת רק מחוץ לישראל באזורים צפוניים או דרומיים יותר. כלולים בחישובים אלו לא הם התנועה של השמש."
            } else {
                return """
Misheyakir (literally "when you recognize") is the time where there is enough light in the sky for one to distinguish between the colors of white & "Techelet" (blue - משנה תורה ב:א & מגיד משרים פרשת קרח). Mitzvot that depend on recongition can be done now (Berakhot 9b), such as:

- Wearing ציצית (Braitah in Menachot 43b quoting the verse in Bamidbar 15:39 - וראיתם אותו)
- Wearing תפילין (Rabbenu Yona quoting the verse in Devarim 28:10 - וְרָאוּ֙ כׇּל־עַמֵּ֣י הָאָ֔רֶץ כִּ֛י שֵׁ֥ם יְהֹוָ֖ה נִקְרָ֣א עָלֶ֑יךָ)
- Reciting Shema (MG"A on Orach Hayim 58:6 in the name of the Ramban - The way to fulfil ובקומך is when people get up, and most people get it when they can see someone who they are somewhat familiar with 4 אמות away).

Although each of these actions are based on different forms of recognition, the Bet Yosef says that they are really all in the same time.

---

Although earlier authorities did not assign any type of measurement to this time (leaving it to be determined on a practical level), later authorities used measurements relative to the time of Dawn. Without restating how to calculate Dawn, Misheyakir according to the letter of the law happens after 1/12th's of the time passed from Dawn until sunrise ("six zemaniyot/seasonal minutes"). However, that time is the letter-of-the-law, for those who need to go to work or leave early in the morning to travel; people should ideally wait until 1/6th's** of the time passed instead, which is the 12 seasonal minute opinion we default to showing.

(Source for seasonal minutes: Halacha Berura pg. 227)
"""
            }
        }
        if title.contains(zmanimNames.getHaNetzString()) {
            if Locale.isHebrewLocale() {
                return "זהו הזמן המוקדם ביותר בו מותר לבצע את כל המצוות שחייבות להתבצע בזמן היום לפי הלכה לכתחילה. הזריחה ההלכתית מוגדרת כרגע שקף השמש העליון מופיע על האופק בעת זריחתה. הזריחה ההלכתית היא נקראת \"זריחת הים\" (מישור) והרבים מהיהודים סומכים עליה בעת תפילת הנץ.  מובן מאליו, יש לשים לב שבשולחן ערוך כתוב באורח חיים, הלכות תפילה סימן פ\"ט, \"מצוות שחרית מתחילין בנץ, שנאמר \'יראוך עם שמש\'\". בהתבסס על זה, פוסקי ההלכה כותבים שאדם צריך לחכות עד שהשמש נראית כדי לומר את שחרית. בישראל, לוח אור החיים משתמש בטבלה של זמני זריחה מתוך \'לוח ביכורי יוסף\' מדי שנה. הזמנים אלו נוצרו על ידי חיים קלר, יוצר האתר ChaiTables. לפי המלצת ההלכה, יש להוריד את זמני הזריחה הנראים מאתרו באמצעות האפליקציה באפשרות שמתגיה כאן למטה. אם לא הורדת את הזמנים, תראה את זמן זריחה במישור."
            } else {
                return """
Sunrise ("Hanetz") is the ideal beginning of the new Halachic day, where one can now perform any day-dependent Mitzvot (Shofar, Lulav, Megillah) in an optimal fashion. The time period itself is also the proper time to be saying the Tefilah of Shacharit, based on the verse (Tehilim 72:5) "יִֽירָא֥וּךָ עִם־שָׁ֣מֶשׁ"; "They will fear you with the sun". Many take extra precision to ensure they start by the sunrise minute (as adviced by R Yitzhak Yosef, Yalkut Yosef 5781 edition, pg. 440), although Maran zt"l himself wasn't as time-precise (see Orḥot Maran I 7:5).

---

Internally, we determine this time (elevation-included, for those in Eretz Yisrael) as the moment the sun's sphere's uppermost edge peeks above the eastern horizon (Yalkut Yosef - new edition, siman 89 page 460), for the exact latitude & longitude as the user. Nevertheless, when displaying this time, we try to match a "Visible Sunrise" as closely as possible (Eshel Avraham Botchach, Oraḥ Ḥayim 89; Yalkut Yosef, new edition, siman 89 page 51), which is "when the sun starts shining on the hilltops" (תלמדי רבינו יונה על ברכות ד: בדפי הריף). As such, we provide users with a way to use these times generated from the ChaiTables website (provided by Rabbi Chaim Keller), with a fallback of displaying the standard sunrise time (without elevation) when these generated times are not downloaded.
"""
            }
        }
        if title == zmanimNames.getAchilatChametzString() {
            if Locale.isHebrewLocale() {
                return "זהו הזמן האחרון בו ניתן לאכול חמץ.  הזמן הזה מחושב כ-4 שעות זמניות, על פי המגן אברהם, לאחר זמן \"עלות השחר\" עם גובה. מאחר וחמץ הוא מצוות מן התורה, אנחנו מחמירים ואנחנו משתמשים בזמן של המגן אברהם כדי לחשב את הזמן האחרון שבו ניתן לאכול חמץ.  במצב \"לוח עמודי הוראה\", הזמן הזה מחושב באותו הדרך כמו שנמצא למעלה, רק שיש בשימוש בזמן המשולש של עלות/צאת בלוח עמודי הוראה, ואין כלל תפקוד גובה בחישובים."
            } else {
                return """
Passover Eve in the Biblical time was spent traveling to the Temple Mount during the time of בן הערבים (starts after the end of the 6th hour) to offer the קרבן פסח. Once the offering is brought, it is forbidden to own or derive benefit (including eating) from חמץ, as said in Exodus 34:25 - "לֹֽא־תִשְׁחַ֥ט עַל־חָמֵ֖ץ דַּם־זִבְחִ֑י". In specific, violating this prohibition transgresses a negative commandment, which is learned out from the *Asmakhta* of "וְזָבַ֥חְתָּ פֶּ֛סַח לַיהֹוָ֥ה אֱלֹהֶ֖יךָ...לֹא־תֹאכַ֤ל עָלָיו֙ חָמֵ֔ץ" (Deuteronomy 16:2-3. Codification began from Rabbi Yehuda, Pesaḥim Bavli 28b; later codified in two foremost authorities [רמב"ם הלכות חמץ ומצה א':ח'; רא"ש פסחים סוף ב':ד' - "וכן נראה לי"] and other Rishonim [רב יצחק אבן גיאת ז"ל בשם הרא"ש ומגיד משנה]). During the times where one is unable to bring the offering, the verse is reinterpreted as referring to the prohibition time-wise - "זְמַן שְׁחִיטָה אָמַר רַחֲמָנָא" (Pesaḥim Bavli 5b).

As a separate identity from the קרבן פסח, there is a separate status tied to the day of ערב חג הפסח itself; from the verse of אַ֚ךְ בַּיּ֣וֹם הָרִאשׁ֔וֹן תַּשְׁבִּ֥יתוּ שְּׂאֹ֖ר מִבָּתֵּיכֶ֑ם (Exodus 12:15), the Talmud (Pesaḥim Bavli 5a) questions how one can perform תשביתו on the first day when there is already a prohibition to own their Ḥametz (בל יראה ובל ימצא). To resolve the contradiction, the Talmud explains that the ה in הראשון is meant to allude to the day *before* the first, which is ערב חג. Then, we use the word "אך" from the verse to divide the day in half, where the first half is dedicated for the מצוה of תשביתו and the second half is the time for the prohibition.

Due to concerns about potentially mistaking this time on a cloudy day, there is an additional rabbinic safeguard to refrain from all activities by the *beginning* of the 6th hour. Additionally, Rabbi Yehuda further restricted eating חמץ by the beginning of the 5th hour (Mishna Pesaḥim 1:4; Pesaḥim Bavli 12b; Rambam Hilchot Hametz Umatzah 1:9).

---

These hours are calculated by dividing the time from Dawn until Nightfall into 12 timeframes, called "seasonal hours". Although the usual method of calculating seasonal hours is from sunrise until sunset, we are stringent on חמץ to consider these two Rabbinic times through the seasonal hours normally reserved for Biblical times (as recorded in the Pri Ḥadash, beginning of Siman 443 & Ḥazon Ovadia II pg. 37), such as Keriath Shema.
- Ḥazon Ovadia - Pesach I pg. 60 & Yalkut Yosef on Pesach (5775 edition) pg. 652 record a leniency for children to use the seasonal hours from sunrise->sunset if they still want to eat Hametz. This time would match what we report for "Sof Zeman Berakhoth Shema"
- To calculate as such in a synchronized fashion (so that the midpoint of both sunrise->sunset + Dawn->Nightfall line up), one would need to measure Tzet Hakokhavim by Rabbenu Tam's time; otherwise, there is a missing 58.5 minutes between the time of the Geonic Tzet Hakokhavim and Rabbenu Tam's (counterpoint would be the Ben Ish Ḥai's calculations, which are indeed shifted by that time).
"""
            }
        }
        if title == zmanimNames.getBiurChametzString() {
            if Locale.isHebrewLocale() {
                return "זהו הזמן האחרון בו ניתן לביעור חמץ לפני שהפסח מתחיל. יש להיפטר מכל חמץ שנמצא ברשותך עד לפני הזמן הזה.  הזמן הזה מחושב כ-5 שעות זמניות, על פי המגן אברהם, לאחר \"עלות השחר\" עם גובה.  במצב \"לוח עמודי הוראה\", הזמן הזה מחושב באותו הדרך כמו שנמצא למעלה, רק שיש בשימוש בזמן המשולש של עלות/צאת בלוח עמודי הוראה, ואין כלל תפקוד גובה בחישובים."
            } else {
                return """
Passover Eve in the Biblical time was spent traveling to the Temple Mount during the time of בן הערבים (starts after the end of the 6th hour) to offer the קרבן פסח. Once the offering is brought, it is forbidden to own or derive benefit (including eating) from חמץ, as said in Exodus 34:25 - "לֹֽא־תִשְׁחַ֥ט עַל־חָמֵ֖ץ דַּם־זִבְחִ֑י". In specific, violating this prohibition transgresses a negative commandment, which is learned out from the *Asmakhta* of "וְזָבַ֥חְתָּ פֶּ֛סַח לַיהֹוָ֥ה אֱלֹהֶ֖יךָ...לֹא־תֹאכַ֤ל עָלָיו֙ חָמֵ֔ץ" (Deuteronomy 16:2-3. Codification began from Rabbi Yehuda, Pesaḥim Bavli 28b; later codified in two foremost authorities [רמב"ם הלכות חמץ ומצה א':ח'; רא"ש פסחים סוף ב':ד' - "וכן נראה לי"] and other Rishonim [רב יצחק אבן גיאת ז"ל בשם הרא"ש ומגיד משנה]). During the times where one is unable to bring the offering, the verse is reinterpreted as referring to the prohibition time-wise - "זְמַן שְׁחִיטָה אָמַר רַחֲמָנָא" (Pesaḥim Bavli 5b).

As a separate identity from the קרבן פסח, there is a separate status tied to the day of ערב חג הפסח itself; from the verse of אַ֚ךְ בַּיּ֣וֹם הָרִאשׁ֔וֹן תַּשְׁבִּ֥יתוּ שְּׂאֹ֖ר מִבָּתֵּיכֶ֑ם (Exodus 12:15), the Talmud (Pesaḥim Bavli 5a) questions how one can perform תשביתו on the first day when there is already a prohibition to own their Ḥametz (בל יראה ובל ימצא). To resolve the contradiction, the Talmud explains that the ה in הראשון is meant to allude to the day *before* the first, which is ערב חג. Then, we use the word "אך" from the verse to divide the day in half, where the first half is dedicated for the מצוה of תשביתו and the second half is the time for the prohibition.

Due to concerns about potentially mistaking this time on a cloudy day, there is an additional rabbinic safeguard to refrain from all activities by the *beginning* of the 6th hour. Additionally, Rabbi Yehuda further restricted eating חמץ by the beginning of the 5th hour (Mishna Pesaḥim 1:4; Pesaḥim Bavli 12b; Rambam Hilchot Hametz Umatzah 1:9).

---

These hours are calculated by dividing the time from Dawn until *Nightfall* into 12 timeframes, called "seasonal hours". Although the usual method of calculating seasonal hours is from sunrise until sunset, we are stringent on חמץ to consider these two Rabbinic times through the seasonal hours normally reserved for Biblical times (as recorded in the Pri Ḥadash, beginning of Siman 443 & Ḥazon Ovadia II pg. 37), such as Keriath Shema.
- Ḥazon Ovadia - Pesach I pg. 60 & Yalkut Yosef on Pesach (5775 edition) pg. 652 record a leniency for children to use the seasonal hours from sunrise->sunset if they still want to eat Hametz. This time would match what we report for "Sof Zeman Berakhoth Shema"
- To calculate as such in a synchronized fashion (so that the midpoint of both sunrise->sunset + Dawn->Nightfall line up), one would need to measure Tzet Hakokhavim by Rabbenu Tam's time; otherwise, there is a missing 58.5 minutes between the time of the Geonic Tzet Hakokhavim and Rabbenu Tam's (counterpoint would be the Ben Ish Ḥai's calculations, which are indeed shifted by that time).
"""
            }
        }
        if title == zmanimNames.getShmaMgaString() {
            if Locale.isHebrewLocale() {
                return "זהו הזמן האחרון בו ניתן למלא את חובת קריאת שמע בכל יום, על פי המגן אברהם.  המגן אברהם/תרומת הדשן מחשבים את הזמן הזה כ-3 שעות זמניות לאחר \"עלות השחר\". הם מחלקים את הזמן בין עלות השחר וצאת הכוכבים של רבנו תם ל-12 חלקים שווים, וכך מתקבלת שעה זמנית אחת.  במצב \"לוח עמודי הוראה\", הזמן הזה מחושב באותו הדרך כמו שנמצא למעלה, רק שיש בשימוש בזמן המשולש של עלות/צאת בלוח עמודי הוראה, ואין כלל תפקוד גובה בחישובים."
            } else {
                return """
This time is the third halachic hour of the day, by when people of luxury would arise in the morning. The תנאים (Tanaic Sages) codified this time to have one completely read קריאת שמע (Kriat Shema) before then (R' Yehoshua in Mishnah Berakhoth 1:2, Shemuel in Talmud Bavli 10b), based on the word ובקומך (as one rises).

---

To calculate this time, one would need to know how long a seasonal hour is and when to start counting from (the time you start measuring the length of a seasonal hour will also determine when the seasonal hour starts). A majority of Poskim understand the day's seasonal hour length to be determined by dividing the length of time between *sunrise* and *sunset* into 12 timeframes (called "seasonal hours"), of which include the Rambam (Kriat Shema 1:11), Rav Sa'adia Gaon (Siddur, page 12) and the Vilna Gaon (reflected in Biur HaGra on Oraḥ Ḥayim, 459:2).

However, some are stringent to measure the day's seasonal hour length by dividing the length of time from *Alot Hashachar* until *Tzet Hakokhavim* into 12 timeframes (called "seasonal hours"), of which include the Ḥida (Shu"t Ḥayim Sha-al II 38:70), Ben Ish Ḥai (Rav Pa'alim 2:2 & BI"Ḥ Vayakhel 4), Kaf Hachaim (58:4) & Terumat Hadeshen. To calculate as such in a symmetric fashion (so that the midpoint of both sunrise->sunset + alot->tzet line up), one would need to measure Tzet Hakochavim by Rabbenu Tam's time; otherwise, there is a missing 58.5 minutes between the time of the Geonic Tzet Hakochavim and Rabbenu Tam's (counterpoint would be the Ben Ish Ḥai's calculations, which are indeed shifted by that time).
- As per the rule of Halichot Olam (v. 1 Vaera 3), one should be stringent by this opinion since this is a matter of a Biblical commandment, especially when the Maghen Avraham (58:1) interprets even the earlier Poskim quoted above to hold by this time when it comes to Shema. However, one who did not manage to fulfil this stringency in time should still aim to say Kriat Shema by the time of the "Vilna Gaon".

Within the seasonal hour, there are two time periods; the beginning of the hour or the end of the hour. Although the Geonic era of Poskim hold by the beginning of the third hour (Machzor Vitri I pg 7; Siddur Rav Amran 1:15-16), the Shulḥan Arukh (Oraḥ Ḥayim, 58:6) held like the Rambam (_ibid_) as well as other Rishonim (Chinuch 420; Tosafoth Avodah Zara 4b s.v. Betelat) who instead calculate it by the _end_ of the third hour.
"""
            }
        }
        if title == zmanimNames.getShmaGraString() {
            if Locale.isHebrewLocale() {
                return "זהו הזמן האחרון בו ניתן למלא את חובת קריאת שמע בכל יום, על פי הגר\"א (הגאון רבנו אליהו).  הגר\"א מחשב את הזמן הזה כ-3 שעות זמניות לאחר הזריחה (עם גובה בחשבונות). הגר\"א מחלק את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ל-12 חלקים שווים, וכך מתקבלת שעה זמנית אחת.  במצב \"לוח עמודי הוראה\", הזמן הזה מחושב באותו הדרך כמו שנמצא למעלה, רק שאין כלל כל תפקוד גובה בחישובים."
            } else {
                return """
This time is the third halachic hour of the day, by when people of luxury would arise in the morning. The תנאים (Tanaic Sages) codified this time to have one completely read קריאת שמע (Kriat Shema) before then (R' Yehoshua in Mishnah Berakhoth 1:2, Shemuel in Talmud Bavli 10b), based on the word ובקומך (as one rises).

---

To calculate this time, one would need to know how long a seasonal hour is and when to start counting from (the time you start measuring the length of a seasonal hour will also determine when the seasonal hour starts). A majority of Poskim understand the day's seasonal hour length to be determined by dividing the length of time between *sunrise* and *sunset* into 12 timeframes (called "seasonal hours"), of which include the Rambam (Kriat Shema 1:11), Rav Sa'adia Gaon (Siddur, page 12) and the Vilna Gaon (reflected in Biur HaGra on Oraḥ Ḥayim, 459:2).

However, some are stringent to measure the day's seasonal hour length by dividing the length of time from *Alot Hashachar* until *Tzet Hakokhavim* into 12 timeframes (called "seasonal hours"), of which include the Ḥida (Shu"t Ḥayim Sha-al II 38:70), Ben Ish Ḥai (Rav Pa'alim 2:2 & BI"Ḥ Vayakhel 4), Kaf Hachaim (58:4) & Terumat Hadeshen. To calculate as such in a symmetric fashion (so that the midpoint of both sunrise->sunset + alot->tzet line up), one would need to measure Tzet Hakochavim by Rabbenu Tam's time; otherwise, there is a missing 58.5 minutes between the time of the Geonic Tzet Hakochavim and Rabbenu Tam's (counterpoint would be the Ben Ish Ḥai's calculations, which are indeed shifted by that time).
- As per the rule of Halichot Olam (v. 1 Vaera 3), one should be stringent by this opinion since this is a matter of a Biblical commandment, especially when the Maghen Avraham (58:1) interprets even the earlier Poskim quoted above to hold by this time when it comes to Shema. However, one who did not manage to fulfil this stringency in time should still aim to say Kriat Shema by the time of the "Vilna Gaon".

Within the seasonal hour, there are two time periods; the beginning of the hour or the end of the hour. Although the Geonic era of Poskim hold by the beginning of the third hour (Machzor Vitri I pg 7; Siddur Rav Amran 1:15-16), the Shulḥan Arukh (Oraḥ Ḥayim, 58:6) held like the Rambam (_ibid_) as well as other Rishonim (Chinuch 420; Tosafoth Avodah Zara 4b s.v. Betelat) who instead calculate it by the _end_ of the third hour.
"""
            }
        }
        if title == zmanimNames.getBrachotShmaString() {
            if Locale.isHebrewLocale() {
                return "זהו הזמן האחרון בו ניתן לאומר ברכות שמע על פי הגר\"א (הגאון רבנו אליהו). בכל זאת, אדם עדיין יכול לאמר פסוקי דזמרה עד חצות.  הגר\"א מחשב את הזמן הזה כ-4 שעות זמניות לאחר הזריחה (עם גובה בחשבונות). הגר\"א מחלק את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ל-12 חלקים שווים, וכך מתקבלת שעה זמנית אחת.  במצב \"לוח עמודי הוראה\", הזמן הזה מחושב באותו הדרך כמו שנמצא למעלה, רק שאין כלל כל תפקוד גובה בחישובים."
            } else {
                return "This is the latest time a person can say the Brachot Shma according to the GR\"A. However, a person can still say " +
                "Pisukei D'Zimra until Chatzot.\n\n" +
                "The GR\"A calculates this time as 4 zmaniyot/seasonal hours after sunrise (elevation included). " +
                "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
                "divides it into 12 equal parts.\n\n" +
                "Outside Eretz Yisrael, this time is calculated the same way as above except no elevation is included."
            }
        }
        if title == zmanimNames.getChatzotString() {
            if Locale.isHebrewLocale() {
                return "זהו אמצע היום ההלכתי, כשהשמש נמצאת בדיוק באמצע השמיים ביחס לאורך היום. יש לשים לב שהשמש יכולה להיות ישירות מעל כל אדם רק בטרופי קרב ובטרופי גדי. בכל מקום אחר, השמש תהיה בזווית גם באמצע היום.  לאחר מהזמן הזה, אין ניתן לאמר עוד את עמידת שמונה עשרה של שחרית, וראוי לומר את תפילת מוסף בהעדפה לפני הזמן הזה.  הזמן הזה מחושב כ-6 שעות זמניות לאחר הזריחה. הגר\"א מחלק את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ל-12 חלקים שווים, וכך מתקבלת שעה זמנית אחת.  במצב \"לוח עמודי הוראה\", הזמן הזה מחושב באותו הדרך כמו שנמצא למעלה, רק שאין כלל כל תפקוד גובה בחישובים."
            } else {
                return "This is the middle of the halachic day, when the sun is exactly in the middle of the sky relative to the length of the" +
                " day. It should be noted, that the sun can only be directly above every person, such that they don't even have shadows, " +
                "in the Tropic of Cancer and the Tropic of Capricorn. Everywhere else, the sun will be at an angle even in the middle of " +
                "the day.\n\n" +
                "After this time, you can no longer say the Amidah prayer of Shacharit, and you should preferably say Musaf before this " +
                "time.\n\n" +
                "This time is calculated as 6 zmaniyot/seasonal hours after sunrise. " +
                "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
                "divides it into 12 equal parts.\n\n" +
                "Outside Eretz Yisrael, this time is calculated the same way as above except no elevation is included."
            }
        }
        if title == zmanimNames.getMinchaGedolaString() {
            if Locale.isHebrewLocale() {
                return "מנחה גדולה, ממשמעותה \"מנחה הגדולה\", היא הזמן המוקדם ביותר בו ניתן לאמר את תפילת מנחה. היא גם הזמן המועדף ביותר לאמר את תפילת מנחה לפי פוסקים שונים.  היא נקראת מנחה גדולה משום שישנה הרבה זמן נותר עד השקיעה.  יש להתחיל לאמר את הפסוקים של קרבנות לאחר מנחה גדולה לכתחילה.  הזמן הזה מחושב כ-30 דקות רגילות לאחר חצות. אך אם זמן זה יותר ארוך בזמניות, אנחנו משתמשים בזמן העונתי במחלוקת לחומרא. הגר\"א מחלק זמן עונתי כך: הוא לוקח את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ומחלק אותו ל-12 חלקים שווים. לאחר מכן, הוא מחלק אחד מתוך ה-12 ל-60 לקבלת דקה זמניות.  במצב \"לוח עמודי הוראה\", הזמן הזה מחושב באותו הדרך כמו שנמצא למעלה, רק שאין כלל כל תפקוד גובה בחישובים."
            } else {
                return "Mincha Gedolah, literally \"Greater Mincha\", is the earliest time a person can say Mincha. " +
                "It is also the preferred time a person should say Mincha according to some poskim.\n\n" +
                "It is called Mincha Gedolah because there is a lot of time left until sunset.\n\n" +
                "A person should ideally start saying Korbanot AFTER this time.\n\n" +
                "This time is calculated as 30 regular minutes after Chatzot (Mid-day). However, if the zmaniyot/seasonal minutes are longer," +
                " we use those minutes instead to be stringent. " +
                "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
                "divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute.\n\n" +
                "Outside Eretz Yisrael, this time is calculated the same way as above except no elevation is included."
            }
        }
        if title == zmanimNames.getMinchaKetanaString() {
            if Locale.isHebrewLocale() {
                return "מנחה קטנה, ממשמעותה \"מנחה הקטנה\", היא הזמן המועדף ביותר לאמר את תפילת מנחה לפי פוסקים שונים.  היא נקראת מנחה קטנה משום שיש בה פחות זמן נותר עד השקיעה.  הזמן הזה מחושב כ-תשע זמניות שעות וחצי לאחר זריחה. הגר\"א מחלק זמן עונתי כך: הוא לוקח את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ומחלק אותו ל-12 חלקים שווים. לאחר מכן, הוא מחלק אחד מתוך ה-12 ל-60 לקבלת דקה זמניות."
            } else {
                return "Mincha Ketana, literally \"Lesser Mincha\", is the most preferred time a person can say Mincha according to some poskim.\n\n" +
                "It is called Mincha Ketana because there is less time left until sunset.\n\n" +
                "This time is calculated as 9 and a half zmaniyot/seasonal hours after sunrise. " +
                "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
                "divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute.\n\n" +
                "Outside Eretz Yisrael, this time is calculated the same way as above except no elevation is included."
            }
        }
        if title.contains(zmanimNames.getPlagHaminchaString()) {
            if Locale.isHebrewLocale() {
                return "פלג המנחה, משמעותה \"חצי מנחה\", היא נקודת האמצע בין מנחה קטנה לשקיעה. מאחר ומנחה קטנה היא שני שעות וחצי לפני השקיעה, פלג המנחה הוא החצי שבה, כלומר שעה ורבע לפני השקיעה.  לפי ההלכה, ניתן להתחיל לאמר את תפילת ערבית לפי דברי רבי יהודה במשמעו בפלג המנחה על פי (ברכות כ\'ו ע\'א).  אדם לא יכול לקבל שבת לפני פלג המנחה.  ההלכה ברורה אומרת לחשב את הזמן הזה על ידי חיסור שעה ו-15 דקות זמניות משקיעה, אך הילקוט יוסף אומר לחשב את זמן פלג המנחה כשעה ו-15 דקות זמניות לפני צאת הכוכבים (13.5 דקות זמניות).  במצב \"לוח עמודי הוראה\", מוצגות שני הדרכים לחישוב זמן פלג המנחה. ההבדל היחיד הוא שזמן צאת הכוכבים של לוח עמודי הוראה בשימוש במקום זמן ה-13.5 דקות זמניות הרגיל. הגר\"א מחלק זמן עונתי כך: הוא לוקח את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ומחלק אותו ל-12 חלקים שווים. לאחר מכן, הוא מחלק אחד מתוך ה-12 ל-60 לקבלת דקה זמניות."
            } else {
                return """
The time from מנחה קטנה until the end of the day is divided into two halves, each lasting 1¼ seasonal hours (Berakhoth Bavli 27a, since מנחה קטנה itself lasts 2½ seasonal hours). By the second half (which we call פלג המנחה), one can start performing a select few commandments of the night, such as accepting Shabbat early (S"A O"Ḥ, 273:4), lighting Ḥanukah candles early (footnotes of Ḥazon Ovadia Hanukah pg. 89) or praying תפילת ערבית when one (preferably) already prayed Minḥa (Berakhoth 26a, Rabbi Yehuda).

---

The Mishnah (in Berakhoth 4:1) introduces the time of פלג המנחה through the contrast of "ערב", which is by definition the endpoint of the day. Since Halachic times use the day's length measured from sunrise until sunset (Halikhot Olam, vol. 1 pg. 248), it would be consistent to say that the end of the seasonal hour measurement is also the end of the day. Thereby, פלג המנחה would be 1¼ seasonal hours before _sunset_ (as held by Talmideh Rabbenu Yonah (Berakhoth Bavli 26a), Rambam in Hilkhot Tefila 3:4, Kaf Hachaim on O"Ḥ 233:7, Shilteh Hagiborim on the Mordekhi & R' Yitzḥak Yisraeli's explanation of the Meiri - Yoseh Binah pg. 105). Rabbenu Ḥananel implicitly supports this by quoting R' Yehuda's parallel between the rules of the שתי תמידים and when one can pray תפילות שחרית ומנחה; since the כבש בבוקר (which corresponds to תפילת שחרית) can only be brought from sunrise and the כבש של בין הארבים (which corresponds to תפילת המנחה) can only be brought until sunset, these hours must be measured from sunrise until sunset.

However, a majority of the authorities define ערב as nightfall. Although most assume consistency and therefore adjust everything to be proportionate (such as measuring the day's length from Dawn until Rabbenu Tam's Nightfall since that's a nightfall that is proportionate to Dawn), Plag Hamincha is **independent** of proportionality (Pri Ḥadash, Kuntress Debei Shimsha, end of ספר מים חיים) and as such, there are opinions that'll use different rulings no matter how inconsistent they are under traditional means. One of these authorities is the Ben Ish Ḥai (1<sup>st</sup> year Vayakhel VIII; see also Terumath Hadeshen siman 1 & Ohr Letzion vol. 2 pg. 147), who ruled to use both the _Geonic Nightfall_ and the seasonal time measured from sunrise to sunset (Igur, end of Siman 327). Therefore, there is a difference of 13½ seasonal minutes between the two.

For R' Ovadia & co.'s rulings, one could assume *all* would agree to the Rambam's time had there been no concern of blessings (from ערבית or candle lighting) being recited in vain. However, since every command attachable to פלג המנחה has a blessing to accompany, there is a disagreement whether one can use this earlier time:

- R' Avraham Yosef & R' Yitzhak Yosef (Yalkut Yosef new edition, siman 271, pages 139 & 144-147) quote their father (Yabia Omer vol. 2 siman 21 num. 15) to use the later time from the BI"Ḥ, concerning themselves with a potential of blessings (of ערבית and הדלקת נרות) being said in vain.
- R' David Yosef (in אוצרות יוסף תשובה ז בסוף הלכה ברורה חלק י"ד) uses the status of our custom/מנהג (to calculate the times from sunrise to sunset) as a means to negate the concern of reciting blessings in vain (as was also said by the Minḥat Kohen - Ma-amar II, end of 9<sup>th</sup> chapter. This is also applicable for סוף זמן תפילה, where we are not concerned for the MG"A seasonal hour calculation). Furthermore, even if our Geonim (of whom we established our custom on) used their nightfall, there would be a mismatch between חצות and astronomical midday (issue quoted by Shu"t Divreh Yosef Shwartz pg. 58 & R' Tukachinsky in the Sefer "Ben Hashmashot", pg. 98).
- In R' Ovadia's later writings, in the section on how to calculate שעות היום (located in the Halikhot Olam above, in the same Parasha that discusses Minḥa times), there was no distinction made between Plag Haminḥa and other times. Based on the lack of explicit exception, one can assume he changed his time from the Yabia Omer quote (ibid) and adopted the position maintained by the Halacha Berurah for all Rabbinic matters.

One could not use out-of-context lines from R' David (like in Halacha Berurah Siman 233 pg. 75) or R' Ovadia (Hazon Ovadia Ta-anit pg. 94, Halikhot Olam vol. 1 pg. 223) that tell the later time, since those sections are really talking about a way to be exempt according to both sides, without indication of which side one actually holds like. Furthermore, everyone would agree in cases of actual Biblically-binding commandments to use the Yalkut Yosef time (such as by קידוש של ליל שבת or הבדלה מוקדם ביום שבת), although the time in between the two gets quickly filled up by other commandments that would need to come before it (like ערבית).

---

Fun Fact: Authorities that hold by *Rabbenu Tam's Nightfall* typically calculate seasonal time from dawn until nightfall, since they are of equal length. However, maintaining the seasonal time from sunrise to sunset (as does the Ra'ah, Berakhoth 26b; Ritva, Berakhoth 27b; Ramban, Pesaḥim 54b - How short the walk between the two is, 33.3/2-000 vs 40/2000) while still defining the time of ערב as nightfall creates a time for פלג המנחה that only has **three minutes** of a time difference between the two. This introduces many difficulties (such as the inability to light שבת candles until then, as said by Rabbi Yaakov Emden, Prozdor Bayit 41, paragraph 28), making it impossible to follow this shita without major risk of שבת desecration according to those authorities (who we do not hold like).
"""
            }
        }
        if title.contains(zmanimNames.getCandleLightingString()) {
            if Locale.isHebrewLocale() {
                return "זהו הזמן האידיאלי להדלקת הנרות לפני שבת או חג מתחילים.  כאשר יש הדלקת נרות ביום שהוא יום טוב/שבת קודם ליום אחר שהוא יום טוב, הנרות מדליקים לאחר צאת הכוכבים. אך אם היום הבא הוא שבת, הנרות מדליקים בזמן הרגיל.  הזמן הזה מחושב כ-%c דקות רגילות לפני השקיעה (עם גובה בחשבונות).  לוח אור החיים תמיד מציג את זמן ההדלקה כ-20 דקות לפני השקיעה ו-40 דקות לפני השקיעה."
            } else {
                return "This is the ideal time for a person to light the candles before shabbat/chag starts.\n\n" +
                "When there is candle lighting on a day that is Yom tov/Shabbat before another day that is Yom tov, " +
                "the candles are lit after Tzeit/Nightfall. However, if the next day is Shabbat, the candles are lit at their usual time.\n\n" +
                "This time is calculated as %s " +
                "regular minutes before sunset (elevation included).\n\n" +
                "The Ohr HaChaim calendar always shows the candle lighting time as 20 and 40 minutes before sunset."
            }
        }
        if title == zmanimNames.getSunsetString() {
            if Locale.isHebrewLocale() {
                return "זהו הזמן ביום בו מתחיל עבר מיום ליום הבא, על פי הלכה.  השקיעה ההלכתית מוגדרת כרגע שקרקע השמש נעלם למעלה בקו האופק במהלך השקיעה (עם גובה בחשבונות).  מיד לאחר השקיעה בין השמשות מתחיל, כדאי לשים לב שזה לפי הגאונים.  אבל רבנו תם פוסקת שהשמש ממשיכה לשקוע עוד 58.5 דקות לאחר השקיעה, ורק לאחר מכן מתחיל בין השמשות לאורך עוד 13.5 דקות.  יש לשים לב כי אף על פי מרן זצ\"ל פוסק שיש לומר מנחה עד צאת הכוכבים, הרבה פוסקים, כמו המשנה ברורה, אומרים שיש לאדם לומר את תפילת מנחה לפני השקיעה ולא לפני צאת הכוכבים. רוב המצוות שחייבות להתבצע ביום כדאי לעשותן לפני זמן זה."
            } else {
                return "This is the time of the day that the day starts to transition into the next day according to halacha.\n\n" +
                "Halachic sunset is defined as the moment when the top edge of the sun disappears on the " +
                "horizon while setting (elevation included).\n\n" +
                "Immediately after the sun sets, Bein Hashmashot/twilight starts according to the Geonim, however, according to Rabbeinu Tam " +
                "the sun continues to set for another 58.5 minutes and only after that Bein Hashmashot starts for another 13.5 minutes.\n\n" +
                "It should be noted that many poskim, like the Mishna Berura, say that a person should ideally say mincha BEFORE sunset " +
                "and not before Tzeit/Nightfall.\n\n" +
                "Most mitzvot that are to be done during the day should ideally be done before this time."
            }
        }
        if title == zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString() {
            if Locale.isHebrewLocale() {
                return "זמן זה מחושב כ-20 דקות לאחר השקיעה (עם גובה בחשבונות).  זמן זה חשוב לימי צום ולקביעת הזמן לברית מילה. בערך מדובר בזמן אחרי שקיעה, אך זמן זה אינו יתר לאמירת תפילת מנחה.  זמן זה מוצג באפור בשבת וביום טוב (כפי בהוראת רבנים) כדי למנוע מאנשים לחשוב שהשבת/יום טוב מסתיימים בזמן זה.  במצב \"לוח עמודי הוראה\", הזמן הזה מחושב על ידי מציאת הכמות של דקות בין השקיעה ו-5.3 מעלות מתחת לאופק ביום שווה, ולאחר מכן אנחנו מוסיפים את מיניות הכמות ההיא לשקיעה כדי לקבוע את הזמן של צאת. אנחנו משתמשים ב-5.3 מעלות מתחת לאופק משום שזהו הזמן שבו מתוך 20 דקות לאחר השקיעה בארץ ישראל."
            } else {
                return "This time is calculated as 20 minutes after sunset (elevation included).\n\n" +
                "This time is important for fast days and deciding when to do a brit milah. Otherwise, it should not be used for anything else like the latest time for mincha.\n\n" +
                "This time is shown in gray on shabbat and yom tov (as advised by my rabbeim) in order to not let people think that shabbat/yom tov ends at this time.\n\n" +
                "In Luach Amudei Horaah mode, this time is calculated by finding out the the amount of minutes between sunset and 5.3 " +
                "degrees below the horizon on a equal day, then we add that amount of zmaniyot minutes to sunset to get the time of " +
                "Tzeit/Nightfall. We use 5.3 degrees below the horizon because that is the time when it is 20 minutes after sunset in Israel."
            }
        }
        if title == zmanimNames.getTzaitHacochavimString() {
            if Locale.isHebrewLocale() {
                return "צאת הכוכבים היא הזמן שבו מתחיל היום ההלכתי הבא לאחר שעין השמש מסתיימת.  זהו הזמן האחרון שבו ניתן לאמר את תפילת מנחה לפי דעת רב עובדיה יוסף זצ\"ל. אדם יכול להתחיל את תפילת העמידה של מנחה בכל זמן שהוא, כל עוד זה לפני זמן זה. (יביע אומר חלק ז סימן ל״ד) הזמן הזה מוצג באפור בשבת וביום טוב (כפי הוראת רבנים) כדי למנוע מאנשים לחשוב שהשבת/יום טוב מסתיימים בזמן זה.  הזמן הזה מחושב כ-13.5 דקות זמניות לאחר השקיעה (עם גובה בחשבונות).  הגר\"א מחלק זמן עונתי כך: הוא לוקח את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ומחלק אותו ל-12 חלקים שווים. לאחר מכן, הוא מחלק אחד מתוך ה-12 ל-60 לקבלת דקה זמניות.  במצב \"לוח עמודי הוראה\", הזמן הזה מחושב על ידי מציאת הכמות של דקות בין השקיעה ו-3.75 מעלות מתחת לאופק ביום שווה, ולאחר מכן אנחנו מוסיפים את מיניות הכמות ההיא לשקיעה כדי לקבוע את הזמן של צאת. אנחנו משתמשים ב-3.75 מעלות מתחת לאופק משום שזהו הזמן שבו מתוך 13.5 דקות לאחר השקיעה בארץ ישראל."
            } else {
                return "Tzeit/Nightfall is the time when the next halachic day starts after Bein Hashmashot/twilight finishes.\n\nThis is the latest time a person can start praying Minḥa according to Rav Ovadia Yosef Z\"TL. Although he previously ruled one should only do so if he could pray the majority of the Tefila before this time (matching the BI\"Ḥ - Vayakhel IX), he uses the sefer \"Bateh Knessiot\" (siman 89) to permit one to start even if the above condition won't be met (Yabia Omer VII Siman 34).\n\nThis time is shown in gray on shabbat and yom tov (as advised by my rabbeim) in order to not let people think that shabbat/yom tov ends at this time.\n\nThis time is calculated as 13 and a half zmaniyot/seasonal minutes after sunset (elevation included).\n\nThe GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute.\n\nOutside Eretz Yisrael, this numbers (of 13.5) is measured in the form of degrees below the horizon (thus being converted to 3.86 degrees) to be then applied on the equinox day, thus giving us a new number to make seasonal that reflects the local astronomy."
            }
        }
        if title == zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() {
            if Locale.isHebrewLocale() {
                return "זהו הזמן בו מסתיימת התענית.  זמן זה מחושב כ-20 דקות רגילות לאחר השקיעה (עם גובה בחשבונות).  נכתב בהלכה ברורה שבאחת מהפעמים, הרב עובדיה יוסף זצ\"ל נסע לניו יורק ואמר לבנו, הרב דוד יוסף שליט\"א, שהתענית מסתיים 13.5 דקות זמניות לאחר השקיעה. אך בספרו \"חזון עובדיה\" כתב שהתענית מסתיים כ-20 דקות לאחר השקיעה.  בלוח אור החיים כתוב שהתענית מסתיים בצאת הכוכבים. שאלתי את הרב בניזרי אם זה אומר שהתענית מסתיים 13.5 דקות זמניות לאחר השקיעה והוא אמר, \"לא בהכרח, הלוח פשוט אומר שהתענית מסתיים בצאת הכוכבים, אדם יכול לסיים את התענית 20 דקות לאחר השקיעה אם הוא רוצה להחמיר.\" אני שאלתי אותו האם ה-20 דקות הם דקות זמניות או רגילות והוא אמר, \"דקות רגילות.\"  בסיכום: אם אדם רוצה לסיים את התענית 13.5 דקות זמניות לאחר השקיעה, יש לו את הזכות לעשות זאת. אך אם אדם רוצה להחמיר, הוא יכול לסיים את התענית 20 דקות לאחר השקיעה."
            } else {
                return "This is the time that the fast/taanit ends, according to the stringent opinion reflected in Ḥazon Ovadia - Four Fasts. Maran zt\"l practiced these times and did not consider being more stringent, even in his travels through New York (as recorded in Halacha Berura XIV - Kuntress Ki Ba Hashemesh, page 213). This is also the recommendation of Rav Yitzhak Yosef (Yalkut Yosef, new edition, siman 555 page 464). Nevertheless, the letter-of-the-law opinion of 13.5 minutes is certainly available to anyone who needs.\n\n" +
                "Calculating this time in Eretz Yisrael is as easy as waiting 20 clock-minutes after elevation-sunset to break the fast. Outside Eretz Yisrael, this time is equated to \"Tzet Hakokhavim L'Ḥumra\", where one would be waiting 20 adjusted-seasonal minutes."
            }
        }
        if title.contains("Shabbat Ends") || title.contains("Chag Ends") || title.contains("Tzait Shabbat") || title.contains("Tzait Chag") || title.contains("צאת שבת/חג") || title.contains("צאת שבת") || title.contains("צאת חג") {
            if Locale.isHebrewLocale() {
                return "זהו הזמן בו מסתיימת שבת/חג.  שימו לב שישנן הרבה מנהגים לגבי מתי מסתיימת שבת, כברירת מחדל, הוא מוגדר להיות 40 דקות רגילות לאחר השקיעה (עם גובה בחשבונות) מחוץ לארץ ישראל ו-30 דקות רגילות לאחר השקיעה בתוך ארץ ישראל. השתמשתי ב-40 דקות משום שהרב מאיר גבריאל אלבז שליט\"א אמר לי שבכל מקום מחוץ לארץ ישראל, אם אדם מחכה 40 דקות רגילות לאחר השקיעה, זהו זמן מספיק לסיום שבת. באפשרותך לשנות את הזמן הזה בהגדרות כדי להתאים למנהגי הקהילה שלך.  זמן זה מחושב כ-%s דקות רגילות לאחר השקיעה (עם גובה בחשבונות).  במצב \"לוח עמודי הוראה\", הזמן הזה מחושב על ידי שימוש בזווית של 7.14 מעלות. אנו משתמשים בזווית זו משום שהרב עובדיה יוסף זצ\"ל הורה שבנוגע למוצאי שבת, הזמן המצוין צריך להיות 30 דקות קבועות לאחר השקיעה. הזווית הזו מופרשת כ-30 דקות לאחר השקיעה לכל אורך השנה בארץ ישראל."
            } else {
                return """
Although Shabbat is another day that should be over after בין השמשות, there are factors to be stringent for. For one, it is a Biblical time, meaning we require at minimum to use the most extended Ben Hashemashot opinion while still keeping within the Geonic framework (meaning we use the 20 minute Nightfall as reference instead of the 13.5 minute one; the extra two minutes in 20 is meant to accommodate רב יוסי's opinion on בין השמשות, on top of the Rambam's Nightfall opinion of 18 minutes). Secondly, the Shulḥan Arukh rules one can only take out Shabbat once all elements of doubt were clarified. We pair this warning with another concept called "תוספת שבת" (discussed in שו"ע או"ח רצ"ג:א), to extend the length of Shabbat beyond the legal end-time to accommodate other opinions. There are a few of them at play, including:

- Determining these times **astronomically**, independent of the law-based seasonal-minute calculation. Solving this would mean giving a generic time that could encompass everything or being very precise that would make the value vary weekly (through the use of degrees below the horizon)
- An accommodation for the מג'רב, adding an extra 7 minutes to the final count. This is the position represented in the בא"ח, (שנה ראשון) ויקהל ד', אור לציון א' יו"ד סימן י'. This is taken practically by Rav Yitzhak Yosef (עין יצחק חלק ג אמוד ת"ב)
- Following in the footsteps of the extremely pious individuals throughout Sepharadic history (ראה באור לציון ד' פרק כ' הערה ב) that waited until the time of Nightfall according to _Rabbenu Tam_ (as codified in Pesahim Bavli 94a) prior to doing melakha. This would make the time length of **72 seasonal minutes** long (with a limit outside Eretz Yisrael to 72 fixed minutes when the seasonal time is longer than this, as quoted in ילקוט יוסף (מהדורה חדשה) סימן רצ"ג עמוד תשכד; הלכה ברורה, הקדמת לסימן רס"א הלכה י"ט; יודעי בינה ז':ו)

Thereby, although Maran Ovadya zt"l recommended the time for Rabbenu Tam for those who could have - יביע עומר ב' סימן כ"א, he concluded a minimum time in Israel of 30 fixed minutes every week. To extend this beyond the borders of Eretz Yisrael (Yalkut Yosef - new edition, siman 261 page 755) we have measured where the sun would be below the horizon 30 minutes below the horizon on the equinox day in Eretz Yisrael, and apply that "degree count" (7.14º) everywhere. Although there is precedent to use methods that would result in even shorter times (ילקוט טהרה מכתב עז), we have used this stricter measurement to ensure one would not be more lenient than the printed Ohr Hachaim calendar when applied to Eretz Yisrael.

A minimum is enforced in cases where the astronomical time would result in a time earlier than the legal standards within the opinions of Geonic nightfall (20 seasonal minutes, 20 fixed minutes).
"""
            }
        }
        if title == zmanimNames.getRTString() {
            if Locale.isHebrewLocale() {
                return "זמן זה הוא זמן הצאת הכוכבים לפי רבינו תם.  צאת הכוכבים הוא הזמן בו מתחיל היום ההלכתי הבא לאחר הסיום של בין השמשות.  זמן זה מחושב כ-72 דקות זמניות לאחר השקיעה (עם גובה בחשבונות). לפי רבינו תם, אלו 72 דקות מורכבות משני חלקים. החלק הראשון הוא 58 וחצי דקות עד השקיעה השנייה (ראו פסחים 94א ותוספות שם). לאחר השקיעה השנייה ישנן 13.5 דקות נוספות עד הצאת הכוכבים.  הגר\"א מחשב דקה זמנית על ידי חלוקת הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ל-12 חלקים שווים. לאחר מכן אנו מחלקים את אחד מתוך 12 החלקים ל-60 דקות זמניות לצורך חישוב 72 דקות. אופן חישוב זה נעשה על מנת לחשב 72 דקות על פי השיטה הראשונה. אופן חישוב נוסף הוא על ידי חישוב מספר הדקות בין הזריחה והשקיעה, ולאחר מכן חלוקת התוצאה ב-10, והוספת התוצאה לשעת השקיעה. האפליקציה משתמשת בשיטה הראשונה.  במצב \"לוח עמודי הוראה\", זמן זה מחושב על ידי חישוב כמה דקות נמצאות בין השקיעה ל-72 דקות כמעלות (16.01) לאחר השקיעה ביום שאורך היום והלילה מוכרחים להיות שווים כאשר הזריחה והשקיעה מתרחשות בסביבות 12 שעות אחרי השעות האחרונות. לאחר מכן אנו מוסיפים את התוצאה הזו לשעת השקיעה כדי לקבוע את זמן רבינו תם. הזמן הוא על פי ההלכה בירושלים ובאזורים צפוניים או דרומיים יותר. הלכה ברורה מציינת שזו הדרך לחשב את הזמן בגלל שהיא טובה יותר על פי הטבע של העולם, אף שלא נראה שהרב עובדיה יוסף זצ\"ל או ילקוט יוסף מסכימים עם דעה זו. לא נכלל פה רמות הגובה.  שימו לב שהרב עובדיה יוסף זצ\"ל היה בעד להחמיר ולהחזיק בזמן רבינו תם בלכלל, בין אם זה היה קורה לפני או לאחר 72 דקות רגילות לאחר השקיעה. אך במצב \"לוח עמודי הוראה\", אנו משתמשים בזמן הפחות מבין השניים."
            } else {
                return "Tzet/Nightfall is the time when the next halachic day starts after Ben Hashmashot/twilight finishes. Although we normally determine that by waiting 13.5 minutes, there is a recommended (yet optional) stringency by following Rabbenu Tam's opinion, through waiting the same amount of time between Dawn until sunrise.\n\nThis time is calculated as 72 zmaniyot/seasonal minutes after sunset (elevation included, when inside Eretz Yisrael). According to Rabbeinu Tam, these 72 minutes are made up of 2 parts. The first part is 58 and a half minutes until the second sunset (see Pesachim 94a and Tosafot there). After the second sunset, there are an additional 13.5 minutes until Tzet/Nightfall.\n\nGetting the resulting time for the letter-of-the law reading is as easy as following the assertion; if Rabbenu Tam is supposed to match the time from Dawn until sunrise (only difference being one would offset from sunset), one would just measure those minutes and add onto the time of sunset. Nevertheless, there are leniencies in play that one would want to factor for; specifically, the Yalkut Yosef introduces the opportunity to use RT's Ben Hashemashot to permit melakha after Shabbat for those wanting to be stringent by his nightfall yet unable to complete it. Similarly, outside Eretz Yisrael, one may be lenient to calculate RT's opinion using fixed minutes when the seasonal minutes surpass them. Although this is against Rav Ovadia Yosef's personal rulingopinion, we rely on his son's who spelt out rulings for outside Eretz Yisrael."
            }
        }
        if title == zmanimNames.getChatzotLaylaString() {
            if Locale.isHebrewLocale() {
                return "זהו זמן אמצע הלילה ההלכתי, כאשר השמש נמצאת בדיוק באמצע השמיים מתחת לנו.  מומלץ לסיים את מלווה מלכא לפני זמן זה.  זמן זה מחושב כ-6 שעות זמניות לאחר השקיעה. הגר\"א מחשב שעה זמנית על ידי חלוקת הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ל-12 חלקים שווים."
            } else {
                return "This is the middle of the halachic night, when the sun is exactly in the middle of the sky beneath us.\n\n" +
                "It is best to have Melaveh Malka before this time.\n\n" +
                "This time is calculated as 6 zmaniyot/seasonal hours after sunset. " +
                "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
                "divides it into 12 equal parts.\n\n"
            }
        }
        if title.contains("וּלְכַפָּרַת פֶּשַׁע") {
            if Locale.isHebrewLocale() {
                return "כאשר ראש חודש חולף במהלך שנה מעוברת, אנו מוסיפים את המילים \"וּלְכַפָּרַת פֶּשַׁע\" בתוך תפילת מוסף. אנו מוסיפים את המילים הללו מחודש תשרי עד החודש השני של אדר. אך לשאר השנה ובשנים רגילות, אין אנו אומרים את המילים הללו. (חזון עובדיה חנוכה שו)"
            } else {
                return "When Rosh Chodesh happens during a leap year, we add the words, \"וּלְכַפָּרַת פֶּשַׁע\" during Musaf. We only add these words from Tishri until the second month of Adar. However, for the rest of the year and during non leap years we do not say it. (Chazon Ovadiah Chanukah 306)"
            }
        }
        if title.contains("Tekufa ".localized()) {
            if Locale.isHebrewLocale() {
                return """
                התקופות של השנה סולרית נחלקו לארבע חלקים: ניסן, תמוז, תשרי וטבת
                
                - על פי קבלה, יש למנות נשתיית מים בזמן של מתג תקופה עצמו, כמו שכתב הרמ"א (יורה דעה 116:5). למרות שהמנהג הג'רבא היה להרחיב את האזהרה הזאת לפניה ולאחריה לשעה וחצי (רמ"ך בברית כהונה - חלק אורח חיים מערכת ת' אותיות כ"א-כ"ה), מרן זצ"ל כתב (הליכות עולם, חלק שביעי, דף קפ"ג) שצריך רק שליש מזמן הזה (אז רק חצי שעה)
                - שישים יום אחר תקופת תשרי, מחליפים את הנוסח של הברכה התשעי בשמוני עשרה (ברך עלינו). בלוח השנה הגרגוריאני, זה נופל ב-December 4th או ב-December 5th
                
                ---
                
                לדעת מתי התקופה הבה, תיקח הזמן של התקופה שעבר ותסיף את עורך השנה חלקי כמות תקפות (4). לפי שמואל (בבלי ערובין נו), הערך השנה מעוגל כלפי מעלה מהערך האסטרונומי, לפי שזה קל יותר לעקוב אחריו (חזון איש, אורח חיים 138:4). לכן, כיוון שערך השנה של שמואל הוא 365.25 ימים, לפיכך, חלוקתה ב-4 נותנת לנו 91 ימים, 7 שעות ו-30 דקות.
                
                עוד מחלוקת יש בזמן עצמה: האם התקופה הראשונה התחיל מזמן השווה של 12:00 או הזמן של חצות בישראל. למרות שלוח אור חיים פסק בשעה שווה, התנובות שדה (רב אהרן ברון) מתנגד לכך בשל האופי השרירותי של שעה 12:00. לפיכך, הלוח עמודי הוראה פסק בשיטת של חצות (11:39), שרק -21 דקות שווה בהן. לחמרת הקבלה, יכולים ללך אחר שניהם אם תתחיל בזמן של הרב ברון ותסיים אם הזמן של הלוח אור החיים.
                """
            } else {
                return """
Tekufot are the Halachic equivalents of the yearly seasons, which we have four of yearly; Nissan/Spring, Tammuz/Summer, Tishri/Fall & Tevet/Winter. These are based on the solar year, due to being astronomical in nature.

- There is a Kabalistic warning not to drink water during the time of the Tekufah switch itself, as written down by the Rama (Yoreh De'ah 116:5). Although the Djerban minhag was to extend this for an hour and a half prior and following this time (רמ"ך בברית כהונה - חלק אורח חיים מערכת ת' אותיות כ"א-כ"ה), Maran zt"l writes (Halichot Olam, Chelek 7, Page 183) one need only wait one third of that time (half an hour following and prior)
- 60 days after Tekufat Tishri, outside of Israel, we switch the text of the Shemoneh Esreh's 9th Beracha (ברך עלינו). In the Gregorian calendar, this matches to December 4th or December 5th.

---

To determine when the next Tekufah is, get the known date of the previous Tekufah and add the length of the year divided by the amount of seasons (4). The length of a year, according to Shemuel in Bavli Eruvin, 56a, is a rounded up version of the astronomical length of a year, for the sake of being easier to keep track of (Hazon Ish - OC Siman 138, se’if katan 4). Thereby, since his length of a year is 365.25 days, dividing it by 4 gives us 91 days, 7 hours and 30 minutes.

A further Makhloket is whether the first Tekufah used a fixed clock time of 12:00 PM or used local Israel Hatzot. Although the Ohr Hachaim calendar uses the fixed clock time like Rav Tuchanski does in his calendar, the תנובות שדה (Rav Aharon Boron) takes issue with this due to the arbitrary nature of a 12:00 midpoint. As such, the עמודי הוראה calendar (as well with the unofficial לוח ילקוט יוסף) uses the local Israel Hatzot time of 11:39 AM, which is only a -21 minute difference. For the water warning above, it is possible to accommodate both by starting from half an hour before R Boron's time and finishing half an hour after the time listed in the Ohr Hachaim calendar.
"""
            }
        }
        if title.contains("Tachanun".localized()) || title.contains("צדקתך") {
            if Locale.isHebrewLocale() {
                return "כאן רשימת הימים בהם אין לומר תחנון:\n\nראש חודש\nכל חודש ניסן\nפסח שני (י\"ד באייר)\nל\"ג בעומר\nראש חודש סיון עד י\"ב בסיון (כולל)\nתשעה באב\nט\"ו באב\nערב ראש השנה וראש השנה\nערב יום כיפור ויום כיפור\nמיום י\"א בתשרי עד סוף תשרי\nכל חנוכה\nט\"ו בשבט\nי\"ד וט\"ו באדר א\' ובאדר ב\'\nכל שבת\nכל ערב ראש חודש\nתענית אסתר\nתשעה באב\nט\"ו בשבט\nל\"ג בעומר\nפסח שני\n\nליום ירושלים ויום העצמאות, מכיוון שיש תחומים, פשוט רק שכתבנו שישנם אומרים שאין לומר תחנון וישנם שאומרים שיש. לפי הרב מאיר גבריאל אלבז, מנהגו של הרב עובדיה זצ\"ל היה לסקוט תחנון רק ביום ירושלים. לא ביום לפניו ולא ביום העצמאות. עם זאת, לפי הרב יונתן נקסון, מותר לדלג על תחנון בשני הימים.\n\nשימו לב כי יש עוד פעמים שלא נוהגים לומר תחנון, אך רשימה זו מתייחסת רק לימים בהם אין תחנון. במקרים מסוימים יש אפשרות לדלג על תחנון אם רוב המתפללים הם אבלים או אם יש שמחה."
            } else {
                return "Here is a list of days with no tachanun:\n\nRosh Chodesh\nThe entire month of Nissan\nPesach Sheni (14th of Iyar)\nLag Ba\'Omer\nRosh Chodesh Sivan until the 12th of Sivan (12th included)\n9th of Av\n15th of Av\nErev Rosh Hashanah and Rosh Hashanah\nErev Yom Kippur and Yom Kippur\nFrom the 11th of Tishrei until the end of Tishrei\nAll of Chanukah\n15th of Shevat\n14th and 15th of Adar I and Adar II\nEvery Shabbat\nEvery Erev Rosh Chodesh\nFast of Esther\nTisha Be\'av\nTu Be\'Shvat\nLag Ba\'Omer\nPesach Sheni\n\nFor Yom Yerushalayim and Yom Ha\'atzmaut, since there is a debate, we simply wrote that some say tachanun and some don\'t. According to Rabbi Meir Gavriel Elbaz, the minhag of Rabbi Ovadiah ZT\"L was to only skip tachanun on the day of Yom Yerushalayim. Not the day before it or on Yom Ha\'atzmaut. However, according to Rabbi Yonatan Nacson, you are allowed to skip tachanun on both days.\n\nNote that there are other times you should not say tachanun, but this list is only for days with no tachanun. Sometimes you can skip tachanun if there are mourners making up majority of the minyan or if there is a simcha (joyous occasion)."
            }
        }
        if title.contains("Three Weeks".localized()) || title.contains("Nine Days".localized()) || title.contains("Shevuah Shechal Bo".localized()) {
            if Locale.isHebrewLocale() {
                return "בזמן שלושת השבועות/תשעת הימים/שבוע שחל בו יש חוקים מסוימים: \n\nשלושת השבועות:\nאסור להאזין למוזיקה.\nמומלץ לדחות את ברכת שהחיינו למקום שבו ניתן.\n\nתשעת הימים:\nאסור להאזין למוזיקה.\nמומלץ לדחות את ברכת שהחיינו למקום שבו ניתן.\nמומלץ לדחות כל פעולות בנייה.\nאסור לערוך חתונות.\nאסור לרכוש בגדים חדשים (אלא אם יש צורך גדול, לדוגמה: מבצע).\nאסור לאכול בשר או יין (אכן בראש חודש ובשבת מותר).\nאסור ללבוש בגדים חדשים לגמרי.\n\nשבוע שחל בו:\nאסור להאזין למוזיקה.\nמומלץ לדחות את ברכת שהחיינו למקום שבו ניתן.\nאסור לערוך פעולות בנייה.\nאסור לערוך חתונות.\nאסור לרכוש בגדים חדשים (אלא אם יש צורך גדול, לדוגמה: מבצע).\nאסור לאכול בשר או יין.\nאסור ללבוש בגדים חדשים לגמרי.\nאסור להסתפר או לגלח את הזקן (רק לגברים).\nאסור לשחות (במים חמים).\nאסור לרחוץ (במים חמים).\nאסור לכבס.\nאסור ללבוש בגדים שנכבסו פרט לבגדי תחתית."
            } else {
                return "During the time of the Three weeks/Nine days/Shevuah shechal bo certain restrictions apply:\n\nThree Weeks:\nNo listening to music\nBetter to delay shehechiyanu\n\nNine Days:\nNo listening to music\nBetter to delay shehechiyanu\nBetter to delay any construction\nNo weddings\nNo purchasing new clothing (unless there is great need ex: a sale)\nNo consumption of meat or wine (excludes Rosh Chodesh and Shabbat)\nNo wearing brand new clothing\n\nShevuah Shechal Bo:\nNo listening to music\nBetter to delay shehechiyanu\nNo construction\nNo weddings\nNo purchasing new clothing (unless there is great need ex: a sale)\nNo consumption of meat or wine\nNo wearing brand new clothing\nNo taking haircuts or shaving (Men Only)\nNo swimming (with hot water)\nNo showering (with hot water)\nNo laundry\nNo wearing freshly laundered clothing (excludes undergarments)\n"
            }
        }
        if title.contains("ברכת החמה") || title.contains("Birchat HaChamah") {
            if Locale.isHebrewLocale() {
                return "ברכת החמה נאמרת היום! זהו אירוע המתרחש פעם אחת בכל 28 שנה, ואדם צריך להיות זהיר כדי לברך על השמש בשעות הראשונות של הבוקר ביום זה. לפי רוב הפוסקים, אפשר לברך על השמש כל יום, אך רב עובדיה יוסף זצ\"ל כותב בחזון עובדיה ברכות כי אדם צריך לנסות לברך על השמש עד לפחות 3 שעות זמניות לאחר תחילת היום. אם הזמן הזה עובר, הוא צריך לברך על השמש בלי שם השם. לכן, מנהג עם ישראל הוא להתעורר בבוקר מוקדם ולהתפלל בנץ ביום זה, ולאחר העמידה (קדיש תתקבל), הם יוצאים החוצה כדי לברך על השמש."
            }
            return "Birchat HaChamah is said today! This occurs once every 28 years, and a person should be careful to say the beracha on the sun early in the morning on this day.\n\nAccording to many poskim, you can say the beracha on the sun all day, however, Rabbi Ovadiah Yosef ZT\"L writes in Chazon Ovadiah Berachot that a person should try to say the beracha before 3 zmaniyot hours into the day. If this time passes, he should say the beracha without hashem\'s name.\n\n Therefore, the minhag of Am Yisrael is to wake up early and pray at Netz on this day and after the Amidah (Kadish Titkabal), they go outside to say the beracha."
        }
        if title.contains("ברכת הלבנה") || title.contains("Birchat HaLevana") {
            if Locale.isHebrewLocale() {
                return "ברכת הלבנה, המכונה גם קידוש לבנה, היא ברכה שאנו אומרים פעם בחודש על הירח כמה ימים לאחר שהוא מגיע למצבו החדש. (שולחן ערוך אורח חיים סימן תכו)\n\nמומלץ לומר ברכה זו עם מנין במוצאי שבת עם חליפה נאה. (מעם לועז בראשית א:יד)\n\nזמן הברכה מתחיל 3 ימים לאחר המולד (חודש החדש), אך הרב עובדיה יוסף זצ\"ל (וספרדים בכלל) ממליצים להמתין עד 7 ימים לאחר המולד לברך. זמן זה מסתיים ביום ה-15 בכל חודש עברי לפי הרב עובדיה יוסף. (הליכות עולם חלק ה אות ט\"ז)"
            } else {
                return "Birchat Halevana, also known as Kiddush Levana and \"The blessing for the new moon\", is a beracha we say once a month on the moon a few days after it reaches it\'s new waning phase. (שולחן ערוך אורח חיים סימן תכו)\n\nIt is ideal to say this blessing with a minyan on Saturday night with a nice suit on. (מעם לועז בראשית א:יד)\n\nThe time period for this blessing starts from 3 days after the Molad (new moon), however, Rabbi Ovadiah Yosef ZT\"L (and sephardim in general) recommend to wait until 7 days after the molad to make the beracha. This time period ends on the 15th of every hebrew month according to Rabbi Ovadiah Yosef. (הליכות עולם חלק ה אות ט\"ז)"
            }
        }
        if title.contains("שמיטה") || title.contains("Shmita") {
            if Locale.isHebrewLocale() {
                return "במהלך מחזור שש השנים שלפני השמיטה, יש חובה להפריש ולתת חלקים מגידולי השדה שלכם - תבואה, פירות וירקות שגודלו בארץ ישראל - למטרות שונות (במדבר י\"ח). מפרישים תרומה גדולה, מעשר ראשון ותרומת מעשר בכל שנה, אך מעשר שני מוחלף במעשר עני בשנה השלישית והשישית (דברים י\"ד:כ\"ח)."
            }
            return "During the six-year cycle prior to shmita, there is an obligation to separate and gift portions of your field's grains, fruits, and vegetables grown in Israel to various causes (Bamidbar 18). We separate Terumah Gedolah, Maaser Rishon, and Terumat Maaser every year, however, Maaser Sheni is replaced with Maaser Ani on the 3rd and 6th years (Devarim 14:28)."
        }

        
        return ""
    }
    
}
