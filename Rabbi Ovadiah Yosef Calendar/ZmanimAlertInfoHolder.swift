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
            return "Dawn - Alot Ha'Shaḥar - עלות השחר"
        }
        if title.contains(zmanimNames.getTalitTefilinString()) {
            return "Earliest Tallit/Tefilin - טלית ותפילין"
        }
        if title.contains(zmanimNames.getHaNetzString()) {
            return "Sunrise - Ha'Netz - הנץ"
        }
        if title == zmanimNames.getAchilatChametzString() {
            return "Sof Zeman Akhilat Ḥametz - Latest time to eat Ḥametz - סוף זמן אכילת חמץ"
        }
        if title == zmanimNames.getBiurChametzString() {
            return "Latest time to burn Ḥametz - Sof Zeman Biur Ḥametz - סוף זמן ביעור חמץ"
        }
        if title == zmanimNames.getShmaMgaString() {
            return "Latest Shema MG\"A - Sof Zeman Shema MG\"A - סוף זמן שמע מג\"א"
        }
        if title == zmanimNames.getShmaGraString() {
            return "Latest Shema GR\"A - Sof Zeman Shema GR\"A - סוף זמן שמע גר\"א"
        }
        if title == zmanimNames.getBrachotShmaString() {
            return "Latest Berakhot Shema - Sof Zeman Berakhot Shema - סוף זמן ברכות שמע"
        }
        if title == zmanimNames.getChatzotString() {
            return "Mid-day - Ḥatzot - חצות"
        }
        if title == zmanimNames.getMinchaGedolaString() {
            return "Earliest Minḥa - Minḥa Gedola - מנחה גדולה"
        }
        if title == zmanimNames.getMinchaKetanaString() {
            return "Minḥa Ketana - מנחה קטנה"
        }
        if title.contains(zmanimNames.getPlagHaminchaString()) {
            return "Pelag Ha'Minḥa - פלג המנחה"
        }
        if title.contains(zmanimNames.getCandleLightingString()) {
            return "Candle Lighting - הדלקת נרות"
        }
        if title == zmanimNames.getSunsetString() {
            return "Sunset - Sheqi'a - שקיעה"
        }
        if title == zmanimNames.getTzaitHacochavimString() {
            return "Nightfall - Tzet Ha'Kokhavim - צאת הכוכבים"
        }
        if title == zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString() {
            return "Nightfall (Stringent) - Tzet Ha'Kokhavim L'Ḥumra - צאת הכוכבים לחומרא"
        }
        if title == zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() + " " + zmanimNames.getLChumraString() {
            return "Fast Ends (Stringent) - צאת תענית לחומרא"
        }
        if title == zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() {
            return "Fast Ends - צאת תענית"
        }
        if title.contains("Shabbat") || title.contains("Chag") || title.contains("\u{05E9}\u{05D1}\u{05EA}") || title.contains("\u{05D7}\u{05D2}") {
            return "Shabbat/Chag Ends - צאת \u{05E9}\u{05D1}\u{05EA}/\u{05D7}\u{05D2}"
        }
        if title == zmanimNames.getRTString() {
            return "Rabbenu Tam - רבינו תם"
        }
        if title == zmanimNames.getChatzotLaylaString() {
            return "Midnight - Ḥatzot Ha'Layla - חצות הלילה"
        }
        if title.contains("Tachanun".localized()) || title.contains("צדקתך") {
            return "Tachanun - תחנון"
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
        if title.contains("ברכת החמה") || title.contains("Birkat HaChamah") {
            return "Latest Birkat Ha'Ḥamah - סוף זמן ברכת החמה - Sof Zeman Birkat Ha'Ḥamah"
        }
        if title.contains("ברכת הלבנה") || title.contains("Birkat Halevana") {
            return "ברכת הלבנה - Birkat Halevana"
        }
        if title.contains("שמיטה") || title.contains("Shemita") {
            return "Shemita - שמיטה"
        }
        if title.contains("day of Omer") || title.contains("ימים לעומר") {
            return "Sefirat HaOmer - ספירת העומר"
        }
        
        return ""
    }
    
    func getFullMessage() -> String {
        let zmanimNames = ZmanimTimeNames(mIsZmanimInHebrew: mIsZmanimInHebrew, mIsZmanimEnglishTranslated: mIsZmanimEnglishTranslated)
        if title == zmanimNames.getAlotString() {
            if Locale.isHebrewLocale() {
                return """
                עלות השחר מתחיל את היום ההלכתי, ומסמל את הראות של קרני השמש בשמים המוארים במזרח. (רא"ש, ברכות ד:א; רמב"ם פירוש המשניות, יומא ג:א; שו"ע או"ח פ"ט:א). בשפת עברית, זמן זה נקרא עלות השחר (כפי שנמצא בבראשית ל"ב:כח; ומילולית דומה של וכמו השחר עלה נמצא בבראשית י"ט:טו) או עמוד השחר (כפי שנמצא במשנה ברכות א:א). זהו הרגע שמסמן את המעבר בין מצוות הלילה (כגון תיקון רחל, קריאת שמע של ערבית ותפילת ערבית) למצוות היום (כמו לא לאכול לפני תפילה; שו"ע או"ח פ"ט:ה), גם אם זה לא תמיד ראוי לגמרי. זאת משום שבמקרים מסוימים ניתן עדיין לקיים מצוות של הלילה (כמו קריאת שמע ללא ברכת השכיבנו) גם במהלך היום, ובמציאות, יש להימנע מלקיים מצוות חיוביות (כגון תפילה) עד זמן הזריחה (אלא אם כן יש סיבה דחופה לכך. כמו כן, מי שעשה מצווה בטעות לפני הזריחה פטור בדיעבד).

                ---

                זמנים הלכתיים אלו נקבעים לא על פי מה שאנו רואים בעינינו (האם השמים תואמים את התיאור האסטרונומי של השחר לעיל), אלא באמצעות מדידות. ביום רגיל (בו יש 12 שעות יום ו-12 שעות לילה), ניתן למדוד את אורך היום מזריחה עד שקיעה, לחלק אותו ליחידות קטנות בשם "מיל" - כל אחת באורך 18 דקות (ש"ע או"ח תנט:ב), ולחשב 4 מיל (כפי שמחייב רבי יהודה, פסחים בבלי צד) כדי להגיע לזמן עלות השחר שמתרחש 72 דקות לפני הזריחה.

                הקודיפיקציה של הלכה זו מצד פוסקי ההלכה רואה את ההקשר של התלמוד (ישראל ביום השוויון האביבי - ערב פסח) כאמצעי ליצור מקביל אסטרונומי של היכן השמש נמצאת מתחת לאופק (ב-16.04 מעלות) עד להחשת הזמן; אולם, כאשר משתנים הפרמטרים (כמו ימים שונים בלוח השנה או מיקומים שונים מישראל), יש להתאים את אורך הזמני ערב כך שיתאים.

                ---

                החזרת הקשר של הגמרא נעשית פשוטה ככל שמחשבים את מיקום השמש ("מעלות") מתחת לאופק ביום השוויון, בשעות אלו לאזור המיועד. [הלכה ברורה (הקדמה לסימן 261 הלכה 13), בהתבסס על מנחת כהן (2 4), פרי חדש (קונטרס דבאי שמשאי 8) ובית דוד (104). למרות שרבי דוד יוסף כותב כי יש להיות מחמיר ולהוסיף, ההיגיון של השימוש בו להקלות לפי דקות זמניות רגילות גם תואם לדקות זמניות מתוקנות] אז ניתן למדוד את הזמן שהאירוע האסטרונומי מתרחש עד הזריחה כדי להבטיח את הזמן העדכני לאזור זה. בהתאמה עם המנהג הספרדי הנורמטיבי שמשתמש בדקות לפי זמן הימצאות השמש מעל האופק, תקופת הזמן הזו מותאמת ומורחבת או מקוצרת בהתאם. (ראו בהמשך: מנחת כהן (מבוא השמש מאמר ב פרק ג) על שו"ת פאר הדור 44. זהו פסק של מרן עובדיה, והביא ראיה מבא"ח (שנה ראשונה - וארא ה, ויקהל ד, צב ח; שנה שניה - נח ז; רב פעלים ב:ב), וכן הסכים הילקוט יוסף (נ"ח:ג))

                הזמנים בלוח הנוצרים באמצעות הנוסחה שלנו עשויים להביא להקלה או להחמרה, תלוי בתרחיש ובזמנים אחרים שנעשה בהם שימוש להשוואה. בשל האופי של תלותנו בזמן, *כל* נוסחה אחרת שתייצר זמנים נוחים או מקלים יותר לא תוכל לשמש על מנת לעקוף את ה"חומרות" שלנו, משום שהיא משתמשת בהנחות שלא התקבלו על ידי פוסקי ההלכה שלנו. ראה י"י (מהדורת תשפ"א) עמוד תעה סימן פט:יב למידע נוסף.
                """
            } else {
                return """
                Dawn begins the halachic day, signified by the visibility of the sun's rays in the illuminated eastern sky. (Rosh, Berakhoth 4:1; Rambam Pirush Mishnayoth Yoma 3:1; Shulḥan Arukh O.Ḥ. 89:1). In Hebrew, this time is either called עלות השחר (as used in Genesis 32:25; Variant of וכמו השחר עלה is used in Genesis 19:15) or עמוד השחר (as used in משנה ברכות א:א). It's the moment that transitions from the night's commandments (examples: תיקון רחל, קריאת שמע של ערבית & תפילת ערבית) to the days commandments (like not eating before prayer; S"A O"Ḥ 89:5), even if not a full-proof perfect one. This is because there are cases where the night's commandments (קריאת שמע בלי ברכת השכיבנו) could still be done into the day, and practically, one should still not perform positive commandments (such as prayer) until sunrise (unless there is a pressing circumstance. Also, one who erroneously did any commandment before sunrise is exempt post-facto).
                
                ---
                
                These Halachic times are determined not through what our eyes see (whether the sky correlates to the astronomical description of Dawn above), but rather through measurements. On the average day (where there are 12 hours of day and 12 hours of night), one could measure the length of the day from sunrise to sunset, break them up into smaller units called "mil" - each spanning 18 minutes (ש"ע או"ח תנט:ב), and use 4 of those mil (as held by R' Yehuda, פסחים בבלי צד) to get to a Dawn time that takes place 72 minutes before sunrise.
                
                The codification of this law from our authorities views the context of the Talmud (Israel on the spring equinox - Erev Pesaḥ) as a means to create an astronomical parallel of where the sun is below the horizon (16.04 degrees) to the passage of time; however, when the parameters change (such as the different days of the calendar or different locations than Israel), we maintain the time length of twilight would also accommodate.
                
                ---
                
                Recreating the context of the Gemara is as easy as applying the sun's position ("degree") below the horizon on the equinox day at those minutes to the respective location. [Halacha Berurah (intro to siman 261 halacha 13), based on Minḥath Kohen (2 4), Pri Ḥadash (Kuntres DeBey Shimshey 8) & Bet David (104). Although R David writes one should only be stringent and increase, the logic of using it for leniencies by regular seasonal minutes also apply by these adjusted-seasonal minutes] One could then measure the time that this astronomical event takes place until sunrise to get the length of twilight fitting for that location. To fit it with the normative Sepharadic custom of using minutes based on how long the sun is above the horizon, this twilight period is then lengthened/shortened accordingly. (see further: מנחת כהן (מבוא השמש מאמר ב פרק ג) על שו"ת פאר הדור 44. זה פסק של מרן עובדיה, והביא ראיה מבא"ח (שנה ראשונה - וארא ה, ויקהל ד, צב ח; שנה שניה - נח ז; רב פעלים ב:ב), וכן הסכים הילקוט יוסף (נ"ח:ג))
                
                The calendar times generated using our formula may result in either a leniency or a stringency, dependent on the scenario & the other time used in the comparison. Due to the nature of how reliant we are on our time, *any* other formula that would generate more comfortable/lenient times may **not** be used to supersede our "stringencies", considering they use premises not adopted by our authorities. See י"י (מהדורת תשפ"א) עמוד תעה סימן פט:יב for further information.
                """
            }
        }
        if title.contains(zmanimNames.getTalitTefilinString()) {
            if Locale.isHebrewLocale() {
                return """
                **מִשֵּׁיָּכִיר** (בַּלָּעַז "כשאתה מזהה") הוא הזמן שבו יש מספיק אור בשמים כדי להבחין בין צבעי הלבן ו"תכלת" (כחול - משנה תורה ב:א ומגיד משרים פרשת קרח). מצוות שתלויות בהכרת דבר מסוים ניתנות לקיום כעת (ברכות ט:ב), כגון:

                - **לובש ציצית** (ברייתא במנחות מ"ג מצטט את הפסוק במדבר טו:לט - "וְרָאִיתֶם אֹתוֹ")
                - **לובש תפילין** (רבנו יונה מצטט את הפסוק בדברים כ"ח:י - "וְרָאוּ כָּל־עַמֵּי הָאָרֶץ כִּי שֵׁם יְהוָה נִקְרָא עָלֶיךָ")
                - **קורא את שמע** (מגן אברהם על אורח חיים 58:6 בשם הרמב"ן - הדרך לקיים "ובקומך" היא כאשר אנשים קמים, ורוב האנשים קמים כאשר הם יכולים לראות מישהו שהם מעט מכירים במרחק 4 אמות).

                למרות שכל אחת מהפעולות הללו מבוססת על סוגים שונים של הכרה, הבית יוסף כתב שכל הפעולות האלו נעשות באותו זמן.

                ---

                למרות שכתבי קודש מוקדמים לא נתנו מדד מדויק לזמן זה (והשאירו זאת לקביעת זמן מעשי), חכמים מאוחרים השתמשו במדדים יחסיים לזמן *עלות השחר*. על פי ההלכה, *משיכיר* קורה אחרי שעבר **1/12** מהזמן שבין עלות השחר לזריחה ("שישה דקות זמניות"). עם זאת, זמן זה הוא על פי דין, עבור אלו שצריכים לצאת לעבודה או לנסוע מוקדם בבוקר; בדרך כלל, יש להמתין עד שיחלוף **1/6** מהזמן. זו הסיבה שהזמן של 66 דקות מוסתר כברירת מחדל.

                (מקור לדקות זמניות: הלכה ברורה עמוד 227)
                """
            } else {
                return """
                Misheyakir (literally "when you recognize") is the time where there is enough light in the sky for one to distinguish between the colors of white & "Techelet" (blue - משנה תורה ב:א & מגיד משרים פרשת קרח). Mitzvot that depend on recognition can be done now (Berakhot 9b), such as:

                - Wearing ציצית (Braitah in Menachot 43b quoting the verse in Bamidbar 15:39 - וראיתם אותו)
                - Wearing תפילין (Rabbenu Yona quoting the verse in Devarim 28:10 - וְרָאוּ֙ כׇּל־עַמֵּ֣י הָאָ֔רֶץ כִּ֛י שֵׁ֥ם יְהֹוָ֖ה נִקְרָ֣א עָלֶ֑יךָ)
                - Reciting Shema (MG"A on Orach Hayim 58:6 in the name of the Ramban - The way to fulfil ובקומך is when people get up, and most people get up when they can see someone who they are somewhat familiar with 4 אמות away).

                Although each of these actions are based on different forms of recognition, the Bet Yosef says that they are really all in the same time.

                ---

                Although earlier authorities did not assign any type of measurement to this time (leaving it to be determined on a practical level), later authorities used measurements relative to the time of Dawn. Without restating how to calculate Dawn, Misheyakir according to the letter of the law happens after 1/12th's of the time passed from Dawn until sunrise ("six zemaniyot/seasonal minutes"). However, that time is the letter-of-the-law, for those who need to go to work or leave early in the morning to travel; people should ideally wait until 1/6th's of the time passed instead ("twelve zemaniyot/seasonal minutes"). Which is why the 66 minute time is hidden by default.

                (Source for seasonal minutes: Halacha Berura pg. 227)
                """
            }
        }
        if title.contains(zmanimNames.getHaNetzString()) {
            if Locale.isHebrewLocale() {
                return """
                הזריחה ("הנץ") היא תחילת היום ההלכתי החדשה האידיאלית, שבה ניתן לבצע את כל המצוות התלויות ביום (שופר, לולב, מגילה) בצורה אופטימלית. תקופה זו עצמה היא גם הזמן הנכון לומר את תפילת שחרית, בהתבסס על הפסוק (תהילים 72:5) "יִֽירָא֥וּךָ עִם־שָׁ֣מֶשׁ"; "ייראו אותך עם השמש". רבים מקפידים מאוד לוודא שהם מתחילים את התפילה בזמן הזריחה (כפי שמועצה רבי יצחק יוסף, ילקוט יוסף מהדורת 5781, עמוד 440), למרות שמרן זצ"ל לא היה כה מדויק בזמנים (ראו אורחות מרן, ח"ב סי' 7:5).

                ---

                בפנים, אנו קובעים את הזמן הזה (כולל גובה, עבור תושבי ארץ ישראל) כרגע שבו קצה העליון של כדור השמש מתחיל לעלות מעל לאופק המזרחי (ילקוט יוסף - מהדורה חדשה, סימן 89, עמוד 460), לפי קווי הרוחב והאורך המדויקים של המשתמש. עם זאת, כאשר אנו מציגים את הזמן הזה, אנו מנסים להתאים את "הזריחה הנראה" בצורה הקרובה ביותר (אשל אברהם בוטשאטש, אורח חיים ס"ח; ילקוט יוסף, מהדורה חדשה, סימן 89, עמוד 51), שהיא "כאשר השמש מתחילה להאיר על ראשי ההרים" (תלמידי רבינו יונה על ברכות ד: בדפי הריף). לכן, אנו מספקים למשתמשים דרך להשתמש בזמנים הנוצרים מאתר ChaiTables (סיפק את המידע רבי חיים קלר), עם גיבוי של הצגת זמן הזריחה הרגיל (ללא גובה) כאשר הזמנים הללו לא הורדו.
                """
            } else {
                return """
                Sunrise ("Hanetz") is the ideal beginning of the new Halachic day, where one can now perform any day-dependent Mitzvot (Shofar, Lulav, Megillah) in an optimal fashion. The time period itself is also the proper time to be saying the Tefilah of Shacharit, based on the verse (Tehilim 72:5) "יִֽירָא֥וּךָ עִם־שָׁ֣מֶשׁ"; "They will fear you with the sun". Many take extra precision to ensure they start by the sunrise minute (as advised by R Yitzḥak Yosef, Yalkut Yosef 5781 edition, pg. 440), although Maran zt"l himself wasn't as time-precise (see Orḥot Maran I 7:5).

                ---

                Internally, we determine this time (elevation-included, for those in Eretz Yisrael) as the moment the sun's sphere's uppermost edge peeks above the eastern horizon (Yalkut Yosef - new edition, siman 89 page 460), for the exact latitude & longitude as the user. Nevertheless, when displaying this time, we try to match a "Visible Sunrise" as closely as possible (Eshel Avraham Botchach, Oraḥ Ḥayim 89; Yalkut Yosef, new edition, siman 89 page 51), which is "when the sun starts shining on the hilltops" (תלמידי רבינו יונה על ברכות ד: בדפי הריף). As such, we provide users with a way to use these times generated from the ChaiTables website (provided by Rabbi Chaim Keller), with a fallback of displaying the standard sunrise time (without elevation) when these generated times are not downloaded.
                """
            }
        }
        if title == zmanimNames.getAchilatChametzString() {
            if Locale.isHebrewLocale() {
                return "זהו הזמן האחרון שבו אדם יכול לאכול חמץ.  זמן זה מחושב כ-4 שעות זמניות לאחר עלות השחר, לפי שיטת המגן אברהם (מג\"א), תוך התחשבות בגובה. מכיוון שאיסור חמץ הוא מצווה מהתורה, אנו מחמירים ומשתמשים בזמן של המגן אברהם לחישוב הזמן האחרון שבו ניתן לאכול חמץ. מחוץ לארץ ישראל, זמן זה מחושב באותו אופן כפי שתואר לעיל, אך תוך שימוש בעלות השחר וצאת הכוכבים על פי חישוב מותאם."
            } else {
                return "This is the latest time a person can eat chametz.\n\n" +
                "This is calculated as 4 zmaniyot/seasonal hours, according to the Magen Avraham, after Alot HaShachar (Dawn) with " +
                "elevation included. Since Chametz is a mitzvah from the torah, we are stringent and we use the Magen Avraham's time to " +
                "calculate the last time a person can eat chametz.\n\n" +
                "Outside of Israel, this time is calculated the same way as above except using a deviated Alot/Tzet."
            }
        }
        if title == zmanimNames.getBiurChametzString() {
            if Locale.isHebrewLocale() {
                return "זהו הזמן האחרון שבו אדם יכול להחזיק או לשרוף את החמץ שלו לפני תחילת פסח. יש להיפטר מכל החמץ שברשותך עד זמן זה. זמן זה מחושב כ-5 שעות זמניות לאחר עלות השחר, לפי שיטת המגן אברהם (מג\"א), תוך התחשבות בגובה. מחוץ לארץ ישראל, זמן זה מחושב באותו אופן כפי שתואר לעיל, אך תוך שימוש בעלות השחר וצאת הכוכבים על פי חישוב מותאם."
            } else {
                return "This is the latest time a person can own or burn their chametz before pesach begins. You should get rid of all chametz in your " +
                "possession by this time.\n\n" +
                "This is calculated as 5 zmaniyot/seasonal hours, according to the MG\"A, after Alot HaShachar (Dawn) with " +
                "elevation included.\n\n" +
                "Outside of Israel, this time is calculated the same way as above except using a deviated Alot/Tzet."
            }
        }
        if title == zmanimNames.getShmaMgaString() || title == zmanimNames.getShmaGraString(){
            if Locale.isHebrewLocale() {
                return """
                זמן זה הוא השעה השלישית ההלכתית של היום, שבו אנשי מותרות היו נוהגים לקום בבוקר. התנאים קבעו שזמן קריאת שמע צריך להסתיים עד שעה זו (רבי יהושע במשנה ברכות א:ב, שמואל בתלמוד בבלי י:ב), בהסתמך על הפסוק "ובקומך" (בעת קימתך).
                ---
                כדי לחשב זמן זה, יש לדעת את אורך השעה הזמנית ואת זמן תחילת החישוב (הזמן שממנו מתחילים למדוד את אורך השעה הזמנית גם יקבע מתי השעה הזמנית מתחילה). רוב הפוסקים מבינים שאורך השעה הזמנית ביום נקבע על ידי חלוקת הזמן שבין *הזריחה* ל*שקיעה* ל-12 פרקי זמן (המכונים "שעות זמניות"). שיטה זו ננקטה על ידי הרמב"ם (קריאת שמע א:י"א), רב סעדיה גאון (סידור, עמוד 12) והגר"א (משתקף בביאור הגר"א על אורח חיים, 459:2).
                עם זאת, יש מחמירים למדוד את אורך השעה הזמנית ביום על ידי חלוקת הזמן שבין *עלות השחר* ל*צאת הכוכבים* ל-12 פרקי זמן. שיטה זו נתמכת על ידי החיד"א (שו"ת חיים שאל ב' 38:70), הבן איש חי (רב פעלים ב:2 & ויקהל ד'), כף החיים (58:4) ותרומת הדשן. כדי לחשב שיטה זו באופן סימטרי (כך שאמצע הזריחה->שקיעה יתאים לעלות->צאת), יש למדוד את צאת הכוכבים לפי זמן רבנו תם. אחרת, ישנו פער של 58.5 דקות בין צאת הכוכבים הגאוני לבין של רבנו תם (נקודת נגד לכך הם חישובי הבן איש חי, המוזזים באותו פרק זמן).
                - על פי כלל הליכות עולם (חלק א, וארא ג'), יש להחמיר כדעת זו משום שמדובר במצוות עשה מן התורה, במיוחד כאשר המגן אברהם (58:1) מפרש שגם הפוסקים שהוזכרו לעיל מחזיקים בדעה זו בקריאת שמע. עם זאת, מי שלא הצליח לקיים את החומרה בזמן צריך להשתדל לומר קריאת שמע עד הזמן של "הגר"א".
                ---
                בתוך השעה הזמנית ישנם שני פרקי זמן: תחילת השעה או סופה. אף על פי שבתקופת הגאונים פסקו לפי תחילת השעה השלישית (מחזור ויטרי א עמוד 7; סידור רב עמרם גאון א:ט"ו-ט"ז), השולחן ערוך (אורח חיים, 58:6) פסק כמו הרמב"ם (_שם_) וכן ראשונים אחרים (חינוך מצווה ת"כ; תוספות עבודה זרה ד:ב ד"ה בטלת), שחישבו את הזמן לפי *סוף* השעה השלישית.
                """
            } else {
                return """
                This time is the third halachic hour of the day, by when people of luxury would arise in the morning. The תנאים (Tanaic Sages) codified this time to have one completely read קריאת שמע (Kriat Shema) before then (R' Yehoshua in Mishnah Berakhoth 1:2, Shemuel in Talmud Bavli 10b), based on the word ובקומך (as one rises).
                ---
                To calculate this time, one would need to know how long a seasonal hour is and when to start counting from (the time you start measuring the length of a seasonal hour will also determine when the seasonal hour starts). A majority of Poskim understand the day's seasonal hour length to be determined by dividing the length of time between *sunrise* and *sunset* into 12 timeframes (called "seasonal hours"), of which include the Rambam (Kriat Shema 1:11), Rav Sa'adia Gaon (Siddur, page 12) and the Vilna Gaon (reflected in Biur HaGra on Oraḥ Ḥayim, 459:2).
                However, some are stringent to measure the day's seasonal hour length by dividing the length of time from *Alot Hashachar* until *Tzet Hakokhavim* into 12 timeframes (called "seasonal hours"), of which include the Ḥida (Shu"t Ḥayim Sha-al II 38:70), Ben Ish Ḥai (Rav Pa'alim 2:2 & BI"Ḥ Vayakhel 4), Kaf Hachaim (58:4) & Terumat Hadeshen. To calculate as such in a symmetric fashion (so that the midpoint of both sunrise->sunset + alot->tzet line up), one would need to measure Tzet Hakokhavim by Rabbenu Tam's time; otherwise, there is a missing 58.5 minutes between the time of the Geonic Tzet Hakokhavim and Rabbenu Tam's (counterpoint would be the Ben Ish Ḥai's calculations, which are indeed shifted by that time).
                - As per the rule of Halichot Olam (v. 1 Vaera 3), one should be stringent by this opinion since this is a matter of a Biblical commandment, especially when the Maghen Avraham (58:1) interprets even the earlier Poskim quoted above to hold by this time when it comes to Shema. However, one who did not manage to fulfil this stringency in time should still aim to say Kriat Shema by the time of the "Vilna Gaon".
                Within the seasonal hour, there are two time periods; the beginning of the hour or the end of the hour. Although the Geonic era of Poskim hold by the beginning of the third hour (Machzor Vitri I pg 7; Siddur Rav Amran 1:15-16), the Shulḥan Arukh (Oraḥ Ḥayim, 58:6) held like the Rambam (_ibid_) as well as other Rishonim (Chinuch 420; Tosafoth Avodah Zara 4b s.v. Betelat) who instead calculate it by the _end_ of the third hour.
                """
            }
        }
        if title == zmanimNames.getBrachotShmaString() {
            if Locale.isHebrewLocale() {
                return "זהו הזמן האחרון בו ניתן לאומר ברכות שמע על פי הגר\"א (הגאון רבנו אליהו). בכל זאת, אדם עדיין יכול לאמר פסוקי דזמרה עד חצות.  הגר\"א מחשב את הזמן הזה כ-4 שעות זמניות לאחר הזריחה (עם גובה בחשבונות). הגר\"א מחלק את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ל-12 חלקים שווים, וכך מתקבלת שעה זמנית אחת."
            } else {
                return "This is the latest time a person can say the Brachot Shema according to the GR\"A. However, a person can still say " +
                "Pisukei D'Zimra until Chatzot.\n\n" +
                "The GR\"A calculates this time as 4 zmaniyot/seasonal hours after sunrise (elevation included). " +
                "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
                "divides it into 12 equal parts."
            }
        }
        if title == zmanimNames.getChatzotString() {
            if Locale.isHebrewLocale() {
                return "זהו אמצע היום ההלכתי, כשהשמש נמצאת בדיוק באמצע השמיים ביחס לאורך היום. יש לשים לב שהשמש יכולה להיות ישירות מעל כל אדם רק בטרופי קרב ובטרופי גדי. בכל מקום אחר, השמש תהיה בזווית גם באמצע היום.  לאחר מהזמן הזה, אין ניתן לאמר עוד את עמידת שמונה עשרה של שחרית, וראוי לומר את תפילת מוסף בהעדפה לפני הזמן הזה.  הזמן הזה מחושב כ-6 שעות זמניות לאחר הזריחה. הגר\"א מחלק את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ל-12 חלקים שווים, וכך מתקבלת שעה זמנית אחת."
            } else {
                return "This is the middle of the halachic day, when the sun is exactly in the middle of the sky relative to the length of the" +
                " day. It should be noted, that the sun can only be directly above every person, such that they don't even have shadows, " +
                "in the Tropic of Cancer and the Tropic of Capricorn. Everywhere else, the sun will be at an angle even in the middle of " +
                "the day.\n\n" +
                "After this time, you can no longer say the Amidah prayer of Shacharit, and you should preferably say Musaf before this " +
                "time.\n\n" +
                "This time is calculated as 6 zmaniyot/seasonal hours after sunrise. " +
                "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
                "divides it into 12 equal parts."
            }
        }
        if title == zmanimNames.getMinchaGedolaString() {
            if Locale.isHebrewLocale() {
                return "מנחה גדולה, ממשמעותה \"מנחה הגדולה\", היא הזמן המוקדם ביותר בו ניתן לאמר את תפילת מנחה. היא גם הזמן המועדף ביותר לאמר את תפילת מנחה לפי פוסקים שונים.  היא נקראת מנחה גדולה משום שישנה הרבה זמן נותר עד השקיעה.  יש להתחיל לאמר את הפסוקים של קרבנות לאחר מנחה גדולה לכתחילה.  הזמן הזה מחושב כ-30 דקות רגילות לאחר חצות. אך אם זמן זה יותר ארוך בזמניות, אנחנו משתמשים בזמן העונתי במחלוקת לחומרא. הגר\"א מחלק זמן עונתי כך: הוא לוקח את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ומחלק אותו ל-12 חלקים שווים. לאחר מכן, הוא מחלק אחד מתוך ה-12 ל-60 לקבלת דקה זמניות."
            } else {
                return "Mincha Gedolah, literally \"Greater Mincha\", is the earliest time a person can say Mincha. " +
                "It is also the preferred time a person should say Mincha according to some poskim.\n\n" +
                "It is called Mincha Gedolah because there is a lot of time left until sunset.\n\n" +
                "A person should ideally start saying Korbanot AFTER this time.\n\n" +
                "This time is calculated as 30 regular minutes after Chatzot (Mid-day). However, if the zmaniyot/seasonal minutes are longer," +
                " we use those minutes instead to be stringent. " +
                "The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and " +
                "divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute."
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
                "divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute."
            }
        }
        if title.contains(zmanimNames.getPlagHaminchaString()) {
            if Locale.isHebrewLocale() {
                return """
                זמן מנחה קטנה עד סוף היום מחולק לשני חצאים, כל אחד מהם נמשך שעה ורבע זמנית (ברכות בבבלי 27א, מאחר שמנחה קטנה עצמה נמשכת שעתיים וחצי זמניות). בחצי השני (שנקרא פלג מנחה), ניתן להתחיל לקיים מצוות מסוימות של הלילה, כמו קבלת שבת מוקדם (שולחן ערוך אורח חיים, סימן 273:4), הדלקת נרות חנוכה מוקדם (הערות של חזון עובדיה חנוכה עמ' 89) או תפילת ערבית כאשר כבר התפלל מנחה (ברכות 26א, רבי יהודה).
                ---
                המשנה (בברכות 4:1) מציגה את זמן פלג מנחה דרך ניגוד ל"ערב", שהוא הגדרת סיום היום. מאחר וזמני הלכה מודדים את אורך היום מהשמש עד שקיעה (הליכות עולם, חלק 1 עמ' 248), יהיה זה תואם לומר שסיום מדידת השעה הזמנית הוא גם סיום היום. כך, פלג מנחה יהיה שעה ורבע זמנית לפני השקיעה (כפי שמחזיקים תלמידי רבנו יונה בברכות בבבלי 26א, רמב"ם בהלכות תפילה 3:4, כף החיים על אורח חיים 233:7, שלטי הגיבורים על המרדכי ו"ר יצחק ישראלי בהסבר המאירי - יוסף בינה עמ' 105). רבנו חננאל תומך בזה באופן עקיף על ידי ציטוט דמיון של רבי יהודה בין הלכות שתי תמידים לבין זמן תפילת שחרית ומנחה; מאחר שהכבש בבוקר (שהוא מקביל לתפילת שחרית) יכול להיות מוקרב רק מהשמש והכבש של בין הערבים (המקביל לתפילת מנחה) יכול להיות מוקרב עד שקיעה, שעות אלו חייבות להימדד מהשמש ועד שקיעה.
                אולם, רוב הפוסקים מגדירים ערב כנפילת הלילה. אף על פי שברוב המקרים מניחים עקרון עקביות ומכנים את כל הדברים באופן פרופורציונלי (כגון מדידת אורך היום משחר עד ערב רבנו תם, מכיוון שזה ערב פרופורציונלי לשחר), פלג מנחה הוא **בלתי תלוי** בפרופורציונליות (פרי חדש, קונטרס דבי שמשא, סוף ספר מים חיים) ולפיכך יש דעות המשתמשות בהוראות שונות גם אם הן אינן עקביות לפי האמצעים המסורתיים. אחת מהדעות הללו היא של בן איש חי (שנה ראשונה וַיָּכֵל VIII; ראה גם תרומת הדשן סימן 1 ו"אור לציון" חלק 2 עמ' 147), שהורה להשתמש גם בערב גאוני וגם בזמן זמני הנמדד מהשמש עד השקיעה (איגור, סוף סימן 327). לכן, יש הבדל של שלוש עשרה וחצי דקות זמניות בין השניים.
                לגבי פסקי ר' עובדיה וכולי, ניתן להניח ש*כולם* היו מסכימים לזמן של הרמב"ם אם לא היה concern של ברכות (מהתפילה ערבית או הדלקת נרות) שיהיו לברך לשווא. אולם, מאחר שכל מצווה שקשורה לפלג מנחה נושאת ברכה נלווית, יש מחלוקת האם ניתן להשתמש בזמן המוקדם הזה:
                - רב אברהם יוסף (פרשת תרומה תשע"ט שיעור מ-3:55) ורב יצחק יוסף (מוצאי שבת פסח תשע"ט שיעור מ-37, מוצאי שבת וַיֵּשׁי תשע"ח שיעור מ-25, ילקוט יוסף מהדורה חדשה, סימן 271, עמודים 139 ו-144-147) מצטטים את אביהם (יביע אומר חלק 2 סימן 21 מספר 15) להשתמש בזמן המאוחר מהב"ח, ודואגים של ברכות (ערבית והדלקת נרות) לבטלות.
                - ר' דוד יוסף (ב"אוצרות יוסף תשובה ז בסוף הלכה ברורה חלק י"ד) משתמש במעמד המנהג שלנו (לחשב את הזמנים מהשמש עד השקיעה) כאמצעי לנפילת החשש לברך לשווא (כמו שנאמר גם במנחת כהן - מאמר II, סוף פרק 9). עוד אמר, שאפילו אם הגאונים שלנו (עליהם הוספנו את המנהג) השתמשו בערב שלהם, היה מדובר בחוסר התאמה בין חצות לבין חצות אסטרונומיים (נושא שהוזכר בשו"ת דברי יוסף שוורץ עמ' 58 ו"ר' טוקצ'ינסקי בספר "בין השמשות", עמ' 98).
                - בספרי ר' עובדיה מאוחר יותר, בסעיף אודות חישוב שעות היום (הממוקם בהליכות עולם למעלה, באותו פרשה שעוסקת בזמני מנחה), לא נעשתה הבחנה בין פלג מנחה לבין שאר הזמנים. לאור חוסר החרגה מפורשת, ניתן להניח שהוא שינה את זמנו מהציטוט מיביע אומר (שם) ואימץ את העמדה שנשמרה בהלכה ברורה לכל ענייני הלכה. עם זאת, עדיין מומלץ מאוד להשתמש בזמן המאוחר כאשר אפשר.
                לא ניתן להשתמש בציטוטים מחוץ להקשר של ר' דוד (כמו בהלכה ברורה סימן 233 עמ' 75) או ר' עובדיה (חזון עובדיה תענית עמ' 94, הליכות עולם חלק 1 עמ' 223) שמציינים את הזמן המאוחר, שכן הסעיפים הללו מתייחסים באמת לפתרון פסקי הלכה בכל הצדדים, מבלי להצביע על עמדת מי מהם יש למכור.
                ---
                עובדה מעניינת: פוסקים שמחזיקים בערב רבנו תם מחשבים זמן עונתי משחר עד ערב, מאחר שהם שווים באורכם. עם זאת, שמירה על הזמן העונתי מהשמש עד שקיעה (כפי שעושה הרא"ה, ברכות 26ב; ריטב"א, ברכות 27ב; רמב"ן, פסחים 54ב - כמה קצרה ההליכה בין השניים, 33.3/2-000 לעומת 40/2000) תוך הגדרת זמן ערב כנפילת הלילה יוצרת זמן לפלג מנחה שמבדיל רק **שלוש דקות** בין השניים. הדבר יוצר קשיים רבים (כגון חוסר אפשרות להדליק נרות שבת עד אז, כפי שאמר רבי יעקב עמדן, פרוזדור בית 41, פסקה 28), מה שמקשה מאוד על קיום שיטה זו ללא סיכון חמור לחלול שבת לפי הפוסקים הללו (שאנחנו לא פוסקים כמותם).
                """
            } else {
                return """
                The time from מנחה קטנה until the end of the day is divided into two halves, each lasting 1¼ seasonal hours (Berakhoth Bavli 27a, since מנחה קטנה itself lasts 2½ seasonal hours). By the second half (which we call פלג המנחה), one can start performing a select few commandments of the night, such as accepting Shabbat early (S"A O"Ḥ, 273:4), lighting Ḥanukah candles early (footnotes of Ḥazon Ovadia Ḥanukah pg. 89) or praying תפילת ערבית when one (preferably) already prayed Minḥa (Berakhoth 26a, Rabbi Yehuda).
                ---
                The Mishnah (in Berakhoth 4:1) introduces the time of פלג המנחה through the contrast of "ערב", which is by definition the endpoint of the day. Since Halachic times use the day's length measured from sunrise until sunset (Halikhot Olam, vol. 1 pg. 248), it would be consistent to say that the end of the seasonal hour measurement is also the end of the day. Thereby, פלג המנחה would be 1¼ seasonal hours before _sunset_ (as held by Talmideh Rabbenu Yonah (Berakhoth Bavli 26a), Rambam in Hilkhot Tefila 3:4, Kaf Hachaim on O"Ḥ 233:7, Shilteh Hagiborim on the Mordekhi & R' Yitzḥak Yisraeli's explanation of the Meiri - Yoseh Binah pg. 105). Rabbenu Ḥananel implicitly supports this by quoting R' Yehuda's parallel between the rules of the שתי תמידים and when one can pray תפילות שחרית ומנחה; since the כבש בבוקר (which corresponds to תפילת שחרית) can only be brought from sunrise and the כבש של בין הערבים (which corresponds to תפילת המנחה) can only be brought until sunset, these hours must be measured from sunrise until sunset.
                However, a majority of the authorities define ערב as nightfall. Although most assume consistency and therefore adjust everything to be proportionate (such as measuring the day's length from Dawn until Rabbenu Tam's Nightfall since that's a nightfall that is proportionate to Dawn), Plag Hamincha is **independent** of proportionality (Pri Ḥadash, Kuntress Debei Shimsha, end of ספר מים חיים) and as such, there are opinions that'll use different rulings no matter how inconsistent they are under traditional means. One of these authorities is the Ben Ish Ḥai (1<sup>st</sup> year Vayakhel VIII; see also Terumath Hadeshen siman 1 & Ohr Letzion vol. 2 pg. 147), who ruled to use both the _Geonic Nightfall_ and the seasonal time measured from sunrise to sunset (Igur, end of Siman 327). Therefore, there is a difference of 13½ seasonal minutes between the two.
                For R' Ovadia & co.'s rulings, one could assume *all* would agree to the Rambam's time had there been no concern of blessings (from ערבית or candle lighting) being recited in vain. However, since every command attachable to פלג המנחה has a blessing to accompany, there is a disagreement whether one can use this earlier time:
                - R' Avraham Yosef ([Parashat Terumah 5779 shiur min 3:55](https://torahanytime.com/lectures/76371)) & R' Yitzḥak Yosef ([Motzei Shabbat Pesach 5779 shiur min 37](https://torahanytime.com/lectures/81670), [Motzei Shabbat Bo 5778 shiur min 25](https://torahanytime.com/lectures/55391), Yalkut Yosef new edition, siman 271, pages 139 & 144-147) quote their father (Yabia Omer vol. 2 siman 21 num. 15) to use the later time from the BI"Ḥ, concerning themselves with a potential of blessings (of ערבית and הדלקת נרות) being said in vain.
                - R' David Yosef (in אוצרות יוסף תשובה ז בסוף הלכה ברורה חלק י"ד) uses the status of our custom/מנהג (to calculate the times from sunrise to sunset) as a means to negate the concern of reciting blessings in vain (as was also said by the Minḥat Kohen - Ma-amar II, end of 9<sup>th</sup> chapter. This is also applicable for סוף זמן תפילה, where we are not concerned for the MG"A seasonal hour calculation). Furthermore, even if our Geonim (of whom we established our custom on) used their nightfall, there would be a mismatch between חצות and astronomical midday (issue quoted by Shu"t Divreh Yosef Shwartz pg. 58 & R' Tukachinsky in the Sefer "Ben Hashmashot", pg. 98).
                - In R' Ovadia's later writings, in the section on how to calculate שעות היום (located in the Halikhot Olam above, in the same Parasha that discusses Minḥa times), there was no distinction made between Plag Haminḥa and other times. Based on the lack of explicit exception, one can assume he changed his time from the Yabia Omer quote (ibid) and adopted the position maintained by the Halacha Berurah for all Rabbinic matters. Nevertheless, it is still highly recommended to use the later time when possible.
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
                return "This is the ideal time for a person to light the candles before shabbat/chag starts.\n\nIf it is Shabbat going into a Yom Tov that has candle lighting, the candles are lit after Tzeit/Nightfall. However, if the next day is Shabbat, the candles are lit at their usual time before sunset.\n\nYou have this time set to be calculated as %c regular minutes before sunset (elevation included).\n\nThe Ohr HaChaim calendar always shows the candle lighting time as 20 and 40 minutes before sunset."
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
                return "זמן זה מחושב כ-20 דקות לאחר שקיעת החמה (כולל השפעת הגובה).  זמן זה חשוב עבור תעניות והכרעה מתי לעשות ברית מילה. מלבד זאת, אין להשתמש בו לשום דבר אחר, כמו הזמן האחרון למנחה. זמן זה מוצג באפור בשבת וביום טוב (בהתאם להמלצת רבותיי) כדי שלא לגרום לאנשים לחשוב ששבת או יום טוב מסתיימים בזמן זה. מחוץ לארץ ישראל, זמן זה מחושב על ידי מציאת מספר הדקות שבין השקיעה לבין 5.3 מעלות מתחת לאופק ביום שבו הזריחה והשקיעה שוות, ולאחר מכן מוסיפים את מספר הדקות הזמניות הזה לשקיעה כדי לקבל את זמן צאת הכוכבים. אנו משתמשים ב-5.3 מעלות מתחת לאופק משום שזה הזמן שבו עוברות 20 דקות לאחר השקיעה בארץ ישראל."
            } else {
                return "This time is calculated as 20 minutes after sunset (elevation included).\n\n" +
                "This time is important for fast days and deciding when to do a brit milah. Otherwise, it should not be used for anything else like the latest time for mincha.\n\n" +
                "This time is shown in gray on shabbat and yom tov (as advised by my rabbeim) in order to not let people think that shabbat/yom tov ends at this time.\n\n" +
                "Outside of Israel, this time is calculated by finding out the the amount of minutes between sunset and 5.3 " +
                "degrees below the horizon on a equal day, then we add that amount of zmaniyot minutes to sunset to get the time of " +
                "Tzeit/Nightfall. We use 5.3 degrees below the horizon because that is the time when it is 20 minutes after sunset in Israel."
            }
        }
        if title == zmanimNames.getTzaitHacochavimString() {
            if Locale.isHebrewLocale() {
                return "צאת הכוכבים הוא הזמן שבו היום ההלכתי הבא מתחיל לאחר סיום בין השמשות.  זהו הזמן המאוחר ביותר שבו אדם יכול להתפלל מנחה לפי דעת רב עובדיה יוסף זצ\"ל. ניתן להתחיל את תפילת העמידה של מנחה בכל זמן שהוא לפני זמן זה. (יביע אומר ז' סימן ל\"ד) זמן זה מוצג באפור בשבת וביום טוב (בהתאם להמלצת רבותיי) כדי שלא לגרום לאנשים לחשוב ששבת או יום טוב מסתיימים בזמן זה. זמן זה מחושב כ-13 וחצי דקות זמניות לאחר שקיעת החמה (כולל השפעת הגובה). הגר\"א מחשב שעה זמנית על ידי לקיחת הזמן שבין זריחת החמה לשקיעתה (כולל השפעת הגובה) וחלוקתו ל-12 חלקים שווים. לאחר מכן מחלקים כל חלק כזה ל-60 כדי לקבל דקה זמנית.  מחוץ לארץ ישראל, זמן זה מחושב על ידי מציאת מספר הדקות שבין השקיעה לבין 3.75 מעלות מתחת לאופק ביום שבו הזריחה והשקיעה שוות, ולאחר מכן מוסיפים את מספר הדקות הזמניות הזה לשקיעה כדי לקבל את זמן צאת הכוכבים. אנו משתמשים ב-3.75 מעלות מתחת לאופק משום שזה הזמן שבו עוברות 13.5 דקות לאחר השקיעה בארץ ישראל."
            } else {
                return "Tzeit/Nightfall is the time when the next halachic day starts after Bein Hashmashot/twilight finishes.\n\nThis is the latest time a person can say Mincha according Rav Ovadiah Yosef Z\"TL. A person could start the amidah of mincha at any time that is at least before this time. (Yabia Omer 7 Siman 34)\n\nThis time is shown in gray on shabbat and yom tov (as advised by my rabbeim) in order to not let people think that shabbat/yom tov ends at this time.\n\nThis time is calculated as 13 and a half zmaniyot/seasonal minutes after sunset (elevation included).\n\nThe GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute.\n\nOutside of Israel, this time is calculated by finding out the amount of minutes between sunset and 3.75 degrees below the horizon on a equal day, then we add that amount of zmaniyot minutes to sunset to get the time of Tzeit/Nightfall. We use 3.75 degrees below the horizon because that is the time when it is 13.5 minutes after sunset in Israel."
            }
        }
        if title == zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() {
            if Locale.isHebrewLocale() {
                return "זמן זה מחושב כ-20 דקות רגילות (מחוץ לישראל, 20 דקות זמניות מותאמות) לאחר השקיעה (כולל גובה פני הים).\n\nמובא בהלכה ברורה (חלק י\"ד, באוצרות יוסף [קונטרס כי בא השמש]) כי מרן הרב עובדיה יוסף זצ\"ל, כאשר נסע פעם בניו יורק, אמר לבנו, הרב דוד יוסף שליט\"א, שהצום מסתיים בצאת גאונים (13.5 דקות זמניות לאחר השקיעה). עם זאת, בספרו חזון עובדיה, הוא כותב שהצום מסתיים כ-20 דקות לאחר השקיעה.\n\nבלוח אור החיים נכתב שהצום מסתיים בצאת הכוכבים. שאלתי את הרב בניזרי (מחבר הלוח) האם הכוונה היא ל-13.5 או 20 דקות לאחר השקיעה, והוא השיב: \"הלוח פשוט אומר שהצום מסתיים בצאת הכוכבים, אדם יכול לסיים את הצום 20 דקות לאחר השקיעה אם הוא רוצה להחמיר.\"\n\nלסיכום: מי שרוצה לסיים את הצום ב-13.5 דקות זמניות לאחר השקיעה, רשאי לעשות כן. אך אם ירצה להחמיר, יוכל להמתין עד 20 דקות לאחר השקיעה."
            } else {
                return "This time is calculated as 20 regular minutes (outside of Israel, 20 adjusted zmaniyot minutes) after sunset (elevation included).\n\nIt is brought down in Halacha Berurah (vol. 14, in Otzrot Yosef [Kuntrus Ki Ba Hashemesh]) that Rabbi Ovadiah Yosef Z\"TL was once traveling in New York and he said to his son, Rabbi David Yosef Shlita, that the fast ends at tzeit geonim (13.5 zmaniyot minutes after sunset). However, in his sefer Chazon Ovadiah, he writes that the fast ends around 20 minutes after sunset.\n\nIn the Ohr HaChaim calendar, they write that the fast ends at Tzait Hacochavim. I asked Rabbi Benizri (author of the calendar) if this meant that the fast ends at 13.5 or 20 minutes after sunset, and he said, \"The calendar just says that the fast ends at Tzait Hacochavim, a person can end the fast at 20 minutes after sunset if he wants to be stringent.\"\n\nTo summarize: If a person wants to end the fast at 13.5 zmaniyot minutes after sunset, he has the right to do so. However, if a person wants to be stringent, he can end the fast at 20 minutes after sunset."
            }
        }
        if title.contains("Shabbat Ends") || title.contains("Chag Ends") || title.contains("Tzait Shabbat") || title.contains("Tzait Chag") || title.contains("צאת שבת/חג") || title.contains("צאת שבת") || title.contains("צאת חג") {
            if Locale.isHebrewLocale() {
                return """
                למרות ששבת הוא יום נוסף שצריך להסתיים לאחר בין השמשות, ישנם גורמים שדורשים להחמיר בהם. ראשית, מדובר בזמן מקראי, כלומר יש דרישה לפחות להשתמש בדעה הרחבה ביותר של בין השמשות תוך שמירה במסגרת הגאונית (כלומר, יש להשתמש בזמני ערב של 20 דקות במקום בזמני ערב של 13.5 דקות; ה-2 דקות הנוספות ב-20 דקות נועדו להקל עם דעת רבי יוסי על בין השמשות, בנוסף לדעת הרמב"ם על ערב של 18 דקות). שנית, השולחן ערוך פוסק שניתן לצאת משבת רק לאחר שכל מרכיבי הספק הובהרו. אנו מצמידים אזהרה זו עם מושג נוסף שנקרא "תוספת שבת" (שדן בשולחן ערוך אורח חיים רצ"ג:א), להאריך את משך השבת מעבר לזמן הסיום ההלכתי כדי להתאים לדעות אחרות. ישנן כמה דעות שקשורות לזה, כולל:
                - קביעת זמנים אלו **אסטרונומית**, באופן עצמאי מחישוב הזמן העונתי לפי הלכה. פתרון לכך יהיה להעניק זמן גנרי שיכלול הכל או להיות מדויק מאוד, דבר שיגרום לזמן להשתנות מדי שבוע (באמצעות זוויות מתחת לאופק).
                - התאמה עבור המג'רב, הוספת 7 דקות לחשבון הסופי. זו העמדה שמיוצגת בבא"ח, (שנה ראשונה) וַיָּכֵל ד', אור לציון א' יו"ד סימן י'. זה מתבצע למעשה על ידי הרב יצחק יוסף (עין יצחק חלק ג עמוד ת"ב).
                - הליכה בעקבות האנשים המפרשים בכל הדורות הספרדיים (ראה באור לציון ד' פרק כ' הערה ב) שהמתינו עד זמן ערב לפי _רבנו תם_ (כפי שמקודד בפסחים בבבלי 94א) לפני עשיית מלאכה. זמן זה יאריך **72 דקות זמניות** (עם גבול מחוץ לארץ ישראל של 72 דקות קבועות כאשר הזמן העונתי ארוך יותר מכך, כפי שצוטט ביילקוט יוסף (מהדורה חדשה) סימן רצ"ג עמוד תשכד; הלכה ברורה, הקדמת לסימן רס"א הלכה י"ט; יודעי בינה ז':ו).
                לכן, למרות שגדול הדור הרב עובדיה זצ"ל המליץ על זמן רבנו תם לאנשים שיכולים לכך - יביע עומר ב' סימן כ"א, הוא סיכם זמן מינימום בישראל של 30 דקות קבועות כל שבוע. להאריך זאת מעבר לגבולות ארץ ישראל (ילקוט יוסף - מהדורה חדשה, סימן 261 עמוד 755) מדדנו היכן השמש תהיה מתחת לאופק 30 דקות ביום השוויון בארץ ישראל, ומיישמים את "ספירת המעלות" הזו (7.14º) בכל מקום. למרות שיש תקדים להשתמש בשיטות שיביאו לזמנים קצרים יותר (ילקוט טהרה מכתב עז), השתמשנו במדידה המחמירה הזו כדי להבטיח שלא יהיה יותר מקלים מהלוח המודפס של אור החיים כשמתייחסים לארץ ישראל.
                יש לקבוע מינימום במקרים בהם הזמן האסטרונומי יביא לזמן מוקדם יותר מהסטנדרטים ההלכתיים לפי דעות ערב גאוניות (20 דקות זמניות, 20 דקות קבועות).
                """
            } else {
                return """
                Although Shabbat is another day that should be over after בין השמשות, there are factors to be stringent for. For one, it is a Biblical time, meaning we require at minimum to use the most extended Ben Hashemashot opinion while still keeping within the Geonic framework (meaning we use the 20 minute Nightfall as reference instead of the 13.5 minute one; the extra two minutes in 20 is meant to accommodate רב יוסי's opinion on בין השמשות, on top of the Rambam's Nightfall opinion of 18 minutes). Secondly, the Shulḥan Arukh rules one can only take out Shabbat once all elements of doubt were clarified. We pair this warning with another concept called "תוספת שבת" (discussed in שו"ע או"ח רצ"ג:א), to extend the length of Shabbat beyond the legal end-time to accommodate other opinions. There are a few of them at play, including:
                - Determining these times **astronomically**, independent of the law-based seasonal-minute calculation. Solving this would mean giving a generic time that could encompass everything or being very precise that would make the value vary weekly (through the use of degrees below the horizon)
                - An accommodation for the מג'רב, adding an extra 7 minutes to the final count. This is the position represented in the בא"ח, (שנה ראשון) ויקהל ד', אור לציון א' יו"ד סימן י'. This is taken practically by Rav Yitzḥak Yosef (עין יצחק חלק ג עמוד ת"ב)
                - Following in the footsteps of the extremely pious individuals throughout Sepharadic history (ראה באור לציון ד' פרק כ' הערה ב) that waited until the time of Nightfall according to _Rabbenu Tam_ (as codified in Pesahim Bavli 94a) prior to doing melakha. This would make the time length of **72 seasonal minutes** long (with a limit outside Eretz Yisrael to 72 fixed minutes when the seasonal time is longer than this, as quoted in ילקוט יוסף (מהדורה חדשה) סימן רצ"ג עמוד תשכד; הלכה ברורה, הקדמת לסימן רס"א הלכה י"ט; יודעי בינה ז':ו)
                Thereby, although Maran Ovadya zt"l recommended the time for Rabbenu Tam for those who could have - יביע עומר ב' סימן כ"א, he concluded a minimum time in Israel of 30 fixed minutes every week. To extend this beyond the borders of Eretz Yisrael (Yalkut Yosef - new edition, siman 261 page 755) we have measured where the sun would be below the horizon 30 minutes below the horizon on the equinox day in Eretz Yisrael, and apply that "degree count" (7.14º) everywhere. Although there is precedent to use methods that would result in even shorter times (ילקוט טהרה מכתב עז), we have used this stricter measurement to ensure one would not be more lenient than the printed Ohr Hachaim calendar when applied to Eretz Yisrael.
                A minimum is enforced in cases where the astronomical time would result in a time earlier than the legal standards within the opinions of Geonic nightfall (20 seasonal minutes, 20 fixed minutes).
                """
            }
        }
        if title == zmanimNames.getRTString() {
            if Locale.isHebrewLocale() {
                return "זמן זה הוא זמן צאת הכוכבים לפי שיטת רבנו תם. צאת הכוכבים הוא הזמן שבו מתחיל היום ההלכתי הבא לאחר סיום בין השמשות. זמן זה מחושב כ-72 דקות זמניות לאחר שקיעת החמה (כולל השפעת הגובה). לפי רבנו תם, 72 הדקות הללו מתחלקות לשני חלקים: 58 וחצי דקות עד לשקיעה השנייה (ראה פסחים צ\"ד ע\"א ותוספות שם), ולאחר השקיעה השנייה יש עוד 13.5 דקות עד צאת הכוכבים. הגאון מווילנא (הגר\"א) מחשב שעה זמנית על ידי לקיחת הזמן שבין זריחת החמה לשקיעתה (כולל השפעת הגובה) וחלוקתו ל-12 חלקים שווים. לאחר מכן מחלקים כל חלק כזה ל-60 כדי לקבל דקה זמנית, ובכך ניתן לחשב 72 דקות זמניות. דרך נוספת לחישוב זמן זה היא לקחת את מספר הדקות הכולל שבין זריחה לשקיעה, לחלק אותו ב-10 ולהוסיף את התוצאה לשעת השקיעה. האפליקציה משתמשת בשיטה הראשונה.  מחוץ לארץ ישראל, זמן זה מחושב על ידי קביעת מספר הדקות שבין השקיעה ועד 72 דקות במעלות (16.01) לאחר השקיעה ביום שבו הזריחה והשקיעה שוות ומרוחקות כ-12 שעות זו מזו. לאחר מכן ממירים את הזמן הזה לדקות זמניות לפי חישוב הגר\"א, ומוסיפים את הזמן לשקיעה כדי לקבל את זמן צאת הכוכבים לפי רבנו תם.  ראוי לציין שרבנו עובדיה יוסף זצ\"ל סבר כי יש לשמור על הזמן הזמני של רבנו תם, בין אם הוא יוצא לפני ובין אם אחרי 72 דקות רגילות לאחר השקיעה. עם זאת, מחוץ לארץ ישראל נוהגים לקחת את הזמן הקצר מבין השניים."
            } else {
                return "This time is Tzeit/Nightfall according to Rabbeinu Tam.\n\nTzeit/Nightfall is the time when the next halachic day starts after Bein Hashmashot/twilight finishes.\n\nThis time is calculated as 72 zmaniyot/seasonal minutes after sunset (elevation included). According to Rabbeinu Tam, these 72 minutes are made up of 2 parts. The first part is 58 and a half minutes until the second sunset (see Pesachim 94a and Tosafot there). After the second sunset, there are an additional 13.5 minutes until Tzeit/Nightfall.\n\nThe GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation included) and divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute in order to calculate 72 minutes. Another way of calculating this time is by calculating how many minutes are between sunrise and sunset. Take that number and divide it by 10, and then add the result to sunset. The app uses the first method.\n\nOutside of Israel, this time is calculated by finding out how many minutes are between sunset and 72 minutes as degrees (16.01) after sunset on a equal day with sunrise and sunset set around 12 hours apart. Then we take those minutes and make them zmaniyot according to the GR\"A and we add that time to sunset to get the time for Rabbeinu Tam.\n\nIt should be noted that Rabbi Ovadiah Yosef ZT\"L was of the opinion to keep the zmaniyot zman of rabbeinu tam whether or not it fell out before or after 72 regular minutes after sunset. However, outside of Israel, we use the lesser of the two times."
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
                "divides it into 12 equal parts."
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
        if title.contains("ברכת החמה") || title.contains("Birkat Ha'Ḥamah") {
            if Locale.isHebrewLocale() {
                return "ברכת החמה נאמרת היום! זהו אירוע המתרחש פעם אחת בכל 28 שנה, ואדם צריך להיות זהיר כדי לברך על השמש בשעות הראשונות של הבוקר ביום זה. לפי רוב הפוסקים, אפשר לברך על השמש כל יום, אך רב עובדיה יוסף זצ\"ל כותב בחזון עובדיה ברכות כי אדם צריך לנסות לברך על השמש עד לפחות 3 שעות זמניות לאחר תחילת היום. אם הזמן הזה עובר, הוא צריך לברך על השמש בלי שם השם. לכן, מנהג עם ישראל הוא להתעורר בבוקר מוקדם ולהתפלל בנץ ביום זה, ולאחר העמידה (קדיש תתקבל), הם יוצאים החוצה כדי לברך על השמש."
            }
            return "Birkat HaChamah is said today! This occurs once every 28 years, and a person should be careful to say the beracha on the sun early in the morning on this day.\n\nAccording to many poskim, you can say the beracha on the sun all day, however, Rabbi Ovadiah Yosef ZT\"L writes in Chazon Ovadiah Berachot that a person should try to say the beracha before 3 zmaniyot hours into the day. If this time passes, he should say the beracha without hashem\'s name.\n\nTherefore, the minhag of Am Yisrael is to wake up early and pray at Netz on this day and after the Amidah (Kadish Titkabal), they go outside to say the beracha."
        }
        if title.contains("ברכת הלבנה") || title.contains("Birkat Halevana") {
            if Locale.isHebrewLocale() {
                return "ברכת הלבנה, המכונה גם קידוש לבנה, היא ברכה שאנו אומרים פעם בחודש על הירח כמה ימים לאחר שהוא מגיע למצבו החדש. (שולחן ערוך אורח חיים סימן תכו)\n\nמומלץ לומר ברכה זו עם מנין במוצאי שבת עם חליפה נאה. (מעם לועז בראשית א:יד)\n\nזמן הברכה מתחיל 3 ימים לאחר המולד (חודש החדש), אך הרב עובדיה יוסף זצ\"ל (וספרדים בכלל) ממליצים להמתין עד 7 ימים לאחר המולד לברך. זמן זה מסתיים ביום ה-15 בכל חודש עברי לפי הרב עובדיה יוסף. (הליכות עולם חלק ה אות ט\"ז)"
            } else {
                return "Birkat Halevana, also known as Kiddush Levana and \"The blessing for the new moon\", is a beracha we say once a month on the moon a few days after it reaches it\'s new waning phase. (שולחן ערוך אורח חיים סימן תכו)\n\nIt is ideal to say this blessing with a minyan on Saturday night with a nice suit on. (מעם לועז בראשית א:יד)\n\nThe time period for this blessing starts from 3 days after the Molad (new moon), however, Rabbi Ovadiah Yosef ZT\"L (and sephardim in general) recommend to wait until 7 days after the molad to make the beracha. This time period ends on the 15th of every hebrew month according to Rabbi Ovadiah Yosef. (הליכות עולם חלק ה אות ט\"ז)"
            }
        }
        if title.contains("שמיטה") || title.contains("Shemita") {
            if Locale.isHebrewLocale() {
                return "במהלך מחזור שש השנים שלפני השמיטה, יש חובה להפריש ולתת חלקים מגידולי השדה שלכם - תבואה, פירות וירקות שגודלו בארץ ישראל - למטרות שונות (במדבר י\"ח). מפרישים תרומה גדולה, מעשר ראשון ותרומת מעשר בכל שנה, אך מעשר שני מוחלף במעשר עני בשנה השלישית והשישית (דברים י\"ד:כ\"ח)."
            }
            return "During the six-year cycle prior to Shemita, there is an obligation to separate and gift portions of your field's grains, fruits, and vegetables grown in Israel to various causes (Bamidbar 18). We separate Terumah Gedolah, Maaser Rishon, and Terumat Maaser every year, however, Maaser Sheni is replaced with Maaser Ani on the 3rd and 6th years (Devarim 14:28)."
        }
        if title.contains("day of Omer") || title.contains("ימים לעומר") {
            if Locale.isHebrewLocale() {
                return "בכל לילה בעומר אנו אומרים ברכה על עשיית מצוה ואז אומרים את הספירה המובילה אותנו מפסח לשבועות, מקציר השעורה לקציר החיטה ובסופו של דבר, למנחה הראשונה בשבועות עצמו של חיטה מהקציר החדש, בצורת 12 לחמים. בזמן ספירת העומר היו מכניסים שעורה מכל שבוע לבית המקדש ומנופפים כמנחה, ממש כתפילה שהקציר יגיע בהצלחה.\n\nכל יום בין תחילת פסח לשבועות נספר, 49 ימים בסך הכל, 7 שבועות של שבעה ימים. זה הופך את תקופת העומר לגרסה מיניאטורית של מחזור שמיטה ויובל (יובל) של 7 מחזורים של שבע שנים.\n\nספירת העומר מתבצעת החל ממוצאי כל יום - כאשר הספירה מתרחשת בלילה הברכה מברכת וכאשר הספירה מתרחשת בשעות היום, הברכה אינה נאמרת. לאחר הברכה סופרים את היום לפי המספר המוחלט ולפי מספרו בתוך כל שבוע, כלומר, \"היום הוא יום השלושים ושלושה לעומר, שהוא ארבעה שבועות וחמישה ימים\" - זה ל\"ג בעומר.\n\nהאתגר הגדול ביותר של ספירת העומר הוא שישנם פוסקים (בה\"ג) שגורסים שמדובר במצווה אחת ארוכה שנמשכת 49 יום, בעוד שאחרים (רמב\"ם) גורסים שכל יום הוא מצווה נפרדת. אף על פי שהשולחן ערוך אומר שעדיין אפשר לספור (בלי הברכה) אם הולכים לילה ויום שלם בלי ספירה, המנהג הוא לא לומר יותר את הברכה בגלל ספק ברכות להקל."
            }
            return "Every night during the Omer we say a blessing for doing a mitzvah and then say the count which leads us from Passover to Shavuot, from the barley harvest to the wheat harvest and, ultimately, to the first offering on Shavuot itself of wheat from the new harvest, in the form of 12 loaves. During the time the Omer was counted, barley from each week would be brought into the Temple and waved as an offering, really as a prayer that the harvest would come in successfully.\n\nEach day between the beginning of Passover and Shavuot gets counted, 49 days in all, 7 weeks of seven days. That makes the Omer period a miniature version of the Shmitah and Yovel (Jubilee) cycle of 7 cycles of seven years.\n\nThe Omer count is made starting the evening of each day – when the count happens at night the blessing is said and when the count happens during the daytime the blessing is not said. After the blessing the day is counted by absolute number and by its number within each week, i.e., “Today is the thirty-third day of the Omer, which is four weeks and five days” – that’s Lag Ba’omer (lamed plus gimel, ל + ג = 33).\n\nThe biggest challenge of counting the Omer is that there are some poskim (Baha\"g) that hold that it is one long mitzvah lasting 49 days, while others (Rambam) hold that each day is a separate mitzvah. Even though the Shulchan Aruch holds that each day is a separate mitzvah, the practice is if you go one whole night and day without counting you no longer say the blessing because of Safek Berachot LeHakel."
        }
        
        return ""
    }
    
}
