//
//  ZmanimAlertInfoHolder.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 4/30/23.
//

import Foundation
import UIKit
import KosherSwift

struct ZmanimAlertInfoHolder {
    
    var type: ZmanListEntryType = .unspecified
    var jewishMonth: Int = 0
    
    func getFullTitle() -> String {
        switch type {
        case .fastStartsTishaBavZman, .fastStartsNonTishaBavZman:
            return "Fast Starts - תענית מתחיל"
            
        case .alotHashacharZman:
            return "Dawn - Alot Ha'Shaḥar - עלות השחר"
            
        case .misheyakir66Zman, .misheyakir60Zman:
            return "Earliest Tallit/Tefilin - טלית ותפילין"
            
        case .hanetzZman:
            return "Sunrise - Ha'Netz - הנץ"
            
        case .sofZmanAchilatChametzZman:
            return "Sof Zeman Akhilat Ḥametz - Latest time to eat Ḥametz - סוף זמן אכילת חמץ"
            
        case .sofZmanBiurChametzZman:
            return "Latest time to burn Ḥametz - Sof Zeman Biur Ḥametz - סוף זמן ביעור חמץ"
            
        case .sofZmanShmaMGAZman:
            return "Latest Shema MG\"A - Sof Zeman Shema MG\"A - סוף זמן שמע מג\"א"
            
        case .sofZmanShmaGRAZman:
            return "Latest Shema GR\"A - Sof Zeman Shema GR\"A - סוף זמן שמע גר\"א"
            
        case .sofZmanBerachotShmaZman:
            return "Latest Berakhot Shema - Sof Zeman Berakhot Shema - סוף זמן ברכות שמע"
            
        case .chatzotZman:
            return "Mid-day - Ḥatzot - חצות"
            
        case .minchaGedolahZman:
            return "Earliest Minḥa - Minḥa Gedola - מנחה גדולה"
            
        case .minchaKetanaZman:
            return "Minḥa Ketana - מנחה קטנה"
            
        case .plagHaminchaHBZman, .plagHaminchaYYZman:
            return "Pelag Ha'Minḥa - פלג המנחה"
            
        case .candlelightingZman:
            return "Candle Lighting - הדלקת נרות"
            
        case .sunsetZman:
            return "Sunset - Sheqi'a - שקיעה"
            
        case .tzetHakokhavimZman:
            return "Nightfall - Tzet Ha'Kokhavim - צאת הכוכבים"
            
        case .tzetHakokhavimLChumraZman:
            return "Nightfall (Stringent) - Tzet Ha'Kokhavim L'Ḥumra - צאת הכוכבים לחומרא"
            
        case .fastEndsZman:
            return "Fast Ends - צאת תענית"
            
        case .shabbatChagEndsZman:
            return "Shabbat/Chag Ends - צאת שבת/חג"
            
        case .rabbenuTamZman:
            return "Rabbenu Tam - רבינו תם"
            
        case .chatzotLaylaZman:
            return "Midnight - Ḥatzot Ha'Layla - חצות הלילה"
            
        case .tachanun:
            return "Tachanun - תחנון"
            
        case .ulchaparatPesha:
            return "וּלְכַפָּרַת פֶּשַׁע"
            
        case .tekufaTime, .tekufaLength:
            return "Tekufa - Season"
            
        case .threeWeeks:
            return "The Three Weeks - בין המצרים"
            
        case .nineDays:
            return "The Nine Days - תשעת הימים"
            
        case .shevuaShechalBo:
            return "The Week of Tisha B'Av - שבוע שחל בו תשעה באב"
            
        case .birkatHachamah, .birkatHachmahZman:
            return "Latest Birkat Ha'Ḥamah - סוף זמן ברכת החמה - Sof Zeman Birkat Ha'Ḥamah"
            
        case .birchatHalevana:
            return "ברכת הלבנה - Birkat Halevana"
            
        case .shmitaYear:
            return "Shemita - שמיטה"
            
        case .dayOfOmer:
            return "Sefirat HaOmer - ספירת העומר"
            
        case .jewishMonth:
            return monthTitle()
            
        default:
            return ""
        }
    }
    
    func getFullMessage() -> String {
        switch type {
        case .fastStartsTishaBavZman, .fastStartsNonTishaBavZman:
            if Locale.isHebrewLocale() {
                return "בתשעה באב וביום הכיפורים, מפני חומרתם, מתחיל הצום כבר בשקיעת החמה של היום שלפניו. שאר הצומות — שבעה עשר בתמוז, צום גדליה, עשרה בטבת ותענית אסתר — מתחילים בעלות השחר ביום הצום (שולחן ערוך, סימן תק״נ).\n\nאם מתכננים לקום לפני עלות השחר כדי לאכול לפני תחילת הצום, יש להתנות לפני השינה שיקומו לפני תחילת הצום כדי לאכול (יביע אומר, חלק ה׳, סימן כ״ב, אות ה׳)."
            }
            return "On Tisha B'Av and Yom Kippur, due to their stringency, the fast starts at sunset the day before. Every other fast (The 17th of Tammuz, Tzom Gedalya, 10th of Tevet, and Taanit Ester) starts at Alot HaShachar (Dawn) on the day of the fast. (Shulchan Aruch Siman 550)\n\nIf you plan to wake up before Dawn in order to eat something before the fast, you are required to set a 'condition' before going to sleep that you will wake up before the fast begins in order to eat something. (Yabia Omer 5 Siman 22:5)"
        case .alotHashacharZman:
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
                    Dawn begins the halachic day, signified by the visibility of the sun's rays in the illuminated eastern sky. (Rosh, Berakhoth 4:1; Rambam Pirush Mishnayoth Yoma 3:1; Shulḥan Arukh O.Ḥ. 89:1). In Hebrew, this time is either called עלות השחר (as used in Genesis 32:25; Variant of וכמו השחר עלה is used in Genesis 19:15) or עמוד השחר (as used in משנה ברכות א:א). It's the moment that transitions from the night's commandments (examples: תיקון רחל, קריאת שמע של ערבית & תפילת ערבית) to the day's commandments (like not eating before prayer; S"A O"Ḥ 89:5), even if not a full-proof perfect one. This is because there are cases where the night's commandments (קריאת שמע בלי ברכת השכיבנו) could still be done into the day, and practically, one should still not perform positive commandments (such as prayer) until sunrise (unless there is a pressing circumstance. Also, one who erroneously did any commandment before sunrise is exempt post-facto).
                    ---
                    These Halachic times are determined not through what our eyes see (whether the sky correlates to the astronomical description of Dawn above), but rather through measurements. On the average day (where there are 12 hours of day and 12 hours of night), one could measure the length of the day from sunrise to sunset, break them up into smaller units called "mil" - each spanning 18 minutes (ש"ע או"ח תנט:ב), and use 4 of those mil (as held by R' Yehuda, פסחים בבלי צד) to get to a Dawn time that takes place 72 minutes before sunrise.
                    The codification of this law from our authorities views the context of the Talmud (Israel on the spring equinox - Erev Pesaḥ) as a means to create an astronomical parallel of where the sun is below the horizon (16.04 degrees) to the passage of time; however, when the parameters change (such as the different days of the calendar or different locations than Israel), we maintain the time length of twilight would also accommodate.
                    ---
                    Recreating the context of the Gemara is as easy as applying the sun's position ("degree") below the horizon on the equinox day at those minutes to the respective location. [Halacha Berurah (intro to siman 261 halacha 13), based on Minḥath Kohen (2 4), Pri Ḥadash (Kuntres DeBey Shimshey 8) & Bet David (104). Although R David writes one should only be stringent and increase, the logic of using it for leniencies by regular seasonal minutes also apply by these adjusted-seasonal minutes] One could then measure the time that this astronomical event takes place until sunrise to get the length of twilight fitting for that location. To fit it with the normative Sepharadic custom of using minutes based on how long the sun is above the horizon, this twilight period is then lengthened/shortened accordingly. (see further: מנחת כהן (מבוא השמש מאמר ב פרק ג) על שו"ת פאר הדור 44. זה פסק של מרן עובדיה, והביא ראיה מבא"ח (שנה ראשונה - וארא ה, ויקהל ד, צב ח; שנה שניה - נח ז; רב פעלים ב:ב), וכן הסכים הילקוט יוסף (נ"ח:ג))
                    The calendar times generated using our formula may result in either a leniency or a stringency, dependent on the scenario & the other time used in the comparison. Due to the nature of how reliant we are on our time, *any* other formula that would generate more comfortable/lenient times may **not** be used to supersede our "stringencies", considering they use premises not adopted by our authorities. See י"י (מהדורת תשפ"א) עמוד תעה סימן פט:יב for further information.
                    """
            }
        case .misheyakir66Zman, .misheyakir60Zman:
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
                    Although earlier authorities did not assign any type of measurement to this time (leaving it to be determined on a practical level), later authorities used measurements relative to the time of Dawn. Without restating how to calculate Dawn, Misheyakir according to the letter of the law happens after 1/12th's of the time passed from Dawn until sunrise ("six zemaniyot/seasonal minutes"). However, that time is the letter-of-the-law, for those who need to go to work or leave early in the morning to travel; people should ideally wait until 1/6th's of the time passed instead ("twelve zemaniyot/seasonal minutes"). Which is why the 66-minute time is hidden by default.
                    (Source for seasonal minutes: Halacha Berura pg. 227)
                    """
            }
        case .hanetzZman:
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
        case .sofZmanAchilatChametzZman:
            if Locale.isHebrewLocale() {
                return "זהו הזמן האחרון שבו מותר לאדם לאכול חמץ לפני תחילת פסח.\n\nזמן זה מחושב כ־4 שעות זמניות לפי שיטת המגן אברהם, לאחר עלות השחר (שמשתנה לפי הגובה). מכיוון שאיסור חמץ הוא מצווה מהתורה, נוהגים להחמיר ולחשב את הזמן לפי המגן אברהם, שמביא לזמן מוקדם יותר.\n\nמחוץ לארץ ישראל, זמן זה מחושב באותה דרך, אלא שמשתמשים בעלות/צאת המתוקנים של לוח עמודי ההוראה, המבוססים על המרחק מקו המשווה.\n\nאם ערב פסח חל בשבת — זמן זה הוא המועד האחרון שבו ניתן לקיים את סעודת היום עם חמץ."
            } else {
                return "This is the latest time a person can eat Chametz before Pesach begins.\n\nThis is calculated as 4 zmaniyot/seasonal hours, according to the Magen Avraham, after Alot HaShachar (Dawn) (elevation affects this time). Since Chametz is a mitzvah from the torah, we are stringent and we use the Magen Avraham's time to calculate the last time a person can eat chametz since it results in an earlier time.\n\nOutside of Israel, this time is calculated the same way as above except using the adjusted Alot/Tzet from the Amudeh Horaah calendar that is based on the distance from the equator.\n\nIf Erev Pesach falls out on Shabbat, this zman represents the latest time a person can have the day meal with chametz."
            }
        case .sofZmanBiurChametzZman:
            if Locale.isHebrewLocale() {
                return "זהו הזמן האחרון שבו אדם יכול להחזיק בבעלותו חמץ לפני תחילת פסח. יש לבער ולהיפטר מכל החמץ שברשותך עד זמן זה.\n\nזמן זה מחושב כ־5 שעות זמניות לפי שיטת ה־מג״א, לאחר עלות השחר (שמשתנה לפי הגובה).\n\nמחוץ לארץ ישראל, זמן זה מחושב באותה צורה, אלא שמשתמשים בעלות/צאת המתוקנים של לוח עמודי ההוראה, המבוססים על המרחק מקו המשווה.\n\nאם ערב פסח חל בשבת, למרות שאי אפשר לשרוף חמץ בשבת, זמן זה קובע את המועד האחרון שבו מותר להחזיק חמץ בשבת. יש לבער/להשמיד את החמץ לפני זמן זה."
            } else {
                return "This is the latest time a person can own Chametz before Pesach begins. You should get rid of all Chametz in your possession by this time.\n\nThis is calculated as 5 zmaniyot/seasonal hours, according to the MG\"A, after Alot HaShachar (Dawn) (elevation affects this time).\n\nOutside of Israel, this time is calculated the same way as above except using the adjusted Alot/Tzet from the Amudeh Horaah calendar that is based on the distance from the equator.\n\nIf Erev Pesach falls out on Shabbat, even though you can not burn chametz, this time represents the latest time a person can own Chametz on Shabbat. You would still need to get rid of it/destroy it before this time."
            }
        case .sofZmanShmaMGAZman, .sofZmanShmaGRAZman:
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
        case .sofZmanBerachotShmaZman:
            if Locale.isHebrewLocale() {
                return " זהו הזמן האחרון בו ניתן לאומר ברכות שמע על פי הגר\"א (הגאון רבנו אליהו). בכל זאת, אדם עדיין יכול לאמר פסוקי דזמרה (וגם את העמידה אם עבר או טעה) עד חצות.  הגר\"א מחשב את הזמן הזה כ-4 שעות זמניות לאחר הזריחה (שמשתנה לפי הגובה). הגר\"א מחלק את הזמן בין הזריחה והשקיעה (שמשתנה לפי הגובה) ל-12 חלקים שווים, וכך מתקבלת שעה זמנית אחת."
            } else {
                return "This is the latest time a person can say the Brachot Shma according to the GR\"A. However, a person can still say Pisukei D'Zimra (and the Amidah if one missed the time or made a mistake) until Chatzot.\n\nThe GR\"A calculates this time as 4 zmaniyot/seasonal hours (based on sunrise to sunset) after sunrise (elevation affects this time)."
            }
        case .chatzotZman:
            if Locale.isHebrewLocale() {
                return "זהו אמצע היום ההלכתי, כשהשמש נמצאת בדיוק באמצע השמיים ביחס לאורך היום. יש לשים לב שהשמש יכולה להיות ישירות מעל כל אדם רק בטרופי קרב ובטרופי גדי. בכל מקום אחר, השמש תהיה בזווית גם באמצע היום.  לאחר מהזמן הזה, אין ניתן לאמר עוד את עמידת שמונה עשרה של שחרית, וראוי לומר את תפילת מוסף בהעדפה לפני הזמן הזה.  הזמן הזה מחושב כ-6 שעות זמניות לאחר הזריחה. הגר\"א מחלק את הזמן בין הזריחה והשקיעה ל-12 חלקים שווים, וכך מתקבלת שעה זמנית אחת."
            } else {
                return "This is the middle of the halachic day, when the sun is exactly in the middle of the sky relative to the length of the day. It should be noted, that the sun can only be directly above every person, such that they don't even have shadows, in the Tropic of Cancer and the Tropic of Capricorn. Everywhere else, the sun will be at an angle even in the middle of the day.\n\nAfter this time, you can no longer say the Amidah prayer of Shacharit, and you should preferably say Musaf before this time.\n\nThis time is calculated as 6 zmaniyot/seasonal hours after sunrise. The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset and divides it into 12 equal parts."
            }
        case .minchaGedolahZman:
            if Locale.isHebrewLocale() {
                return "מנחה גדולה, ממשמעותה \"מנחה הגדולה\", היא הזמן המוקדם ביותר בו ניתן לאמר את תפילת מנחה. היא גם הזמן המועדף ביותר לאמר את תפילת מנחה לפי פוסקים שונים.  היא נקראת מנחה גדולה משום שישנה הרבה זמן נותר עד השקיעה.  יש להתחיל לאמר את הפסוקים של קרבנות לאחר מנחה גדולה לכתחילה.  הזמן הזה מחושב כ-30 דקות רגילות לאחר חצות. אך אם זמן זה יותר ארוך בזמניות, אנחנו משתמשים בזמן העונתי במחלוקת לחומרא. הגר\"א מחלק זמן עונתי כך: הוא לוקח את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ומחלק אותו ל-12 חלקים שווים. לאחר מכן, הוא מחלק אחד מתוך ה-12 ל-60 לקבלת דקה זמניות."
            } else {
                return "Mincha Gedolah, literally \"Greater Mincha\", is the earliest time a person can say Mincha. It is also the preferred time a person should say Mincha according to some poskim.\n\nIt is called Mincha Gedolah because there is a lot of time left until sunset.\n\nA person should ideally start saying Korbanot AFTER this time.\n\nThis time is calculated as 30 regular minutes after Chatzot (Mid-day). However, if the zmaniyot/seasonal minutes are longer, we use those minutes instead to be stringent. The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation affects this time) and divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute."
            }
        case .minchaKetanaZman:
            if Locale.isHebrewLocale() {
                return "מנחה קטנה, ממשמעותה \"מנחה הקטנה\", היא הזמן המועדף ביותר לאמר את תפילת מנחה לפי פוסקים שונים (רמב״ם, שולחן ערוך).  היא נקראת מנחה קטנה משום שיש בה פחות זמן נותר עד השקיעה.  הזמן הזה מחושב כ-תשע זמניות שעות וחצי לאחר זריחה. הגר\"א מחלק זמן עונתי כך: הוא לוקח את הזמן בין הזריחה והשקיעה (עם גובה בחשבונות) ומחלק אותו ל-12 חלקים שווים. לאחר מכן, הוא מחלק אחד מתוך ה-12 ל-60 לקבלת דקה זמניות."
            } else {
                return "Mincha Ketana, literally \"Lesser Mincha\", is the most preferred time a person can say Mincha according to some poskim (Rambam, Shulchan Aruch).\n\nIt is called Mincha Ketana because there is less time left until sunset.\n\nThis time is calculated as 9 and a half zmaniyot/seasonal hours after sunrise. The GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation affects this time) and divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute."
            }
        case .plagHaminchaHBZman, .plagHaminchaYYZman:
            if Locale.isHebrewLocale() {
                return """
                פלג המנחה מוגדר כחציו השני של משך הזמן שבין מנחה קטנה ועד סוף היום (ערב), ומתרחש לאחר 10¾ שעות ביום (ברכות כו:). מאחר שמנחה קטנה מתחילה לאחר 9½ שעות ביום, נשארים רק שעה ורבע זמניות מתחילת חצי זה ועד סוף זמן המנחה. בזמן זה ניתן להתחיל לקיים כמה מצוות של הלילה, כגון לקבל את השבת מוקדם (שולחן ערוך או"ח רסג:ד), להדליק נרות חנוכה מוקדם (הערות חזון עובדיה חנוכה עמוד פט), או להתפלל תפילת ערבית כאשר כבר התפלל מנחה (ברכות כו:, רבי יהודה).

                ---

                עיקר דיון הגמרא הוא האם "החצי" נמדד ממנחה גדולה או ממנחה קטנה; לאחר שהברייתא מבררת שמדובר במנחה קטנה, הגמרא מחשבת את משך היום כ־12 שעות, ופלג המנחה נמצא בתוך אותן 12 שעות. היא מזהה שמנחה קטנה היא בשעה התשיעית וחצי, ומכאן פלג המנחה מתחיל ב־"אחת עשרה חסר רביע שעה". מכך יוצא ששני חצאים שווים למנחה קטנה, והערב הוא בשעה ה־12 — לאחר ששני החצאים עברו. אך הגמרא אינה מגדירה במפורש מהו "ערב", ומשאירה זאת לראשונים לקשרו או לשקיעה או לצאת הכוכבים.

                חישוב השעות הזמניות מזריחה ועד שקיעה מתאים לסדר הקרבת התמיד, במיוחד כבש של בין הערבים, המקביל לתפילת מנחה. כך מוכיח רבנו חננאל (מציין לדברי ר' יהודה המקביל בין קרבן התמיד לבין זמני התפילות). לפיכך, פלג המנחה הוא שעה ורבע זמניות לפני השקיעה (תלמידי רבנו יונה, ברכות כו:, רמב"ם הלכות תפילה ג:ד, שלטי הגיבורים על המרדכי, פירוש ר' יצחק הישראלי להמאירי — יוסף בינה עמוד קה).

                לעומת זאת, פוסקים אחרים הגדירו את היום כמתחיל מעלות השחר ונגמר בצאת הכוכבים, ולכן ערב הוא הלילה (כפי שכתב הרא"ש ברכות א:א; ד:ו, תוספות הרא"ש ברכות כז:, רשב"א ברכות ב:). השאלות לגבי יישום הגדרה זו נובעות ממסכת פסחים צד:, שם היום הוגדר בפרופורציה — 4 מילים להתחלה ו־4 מילים לסוף.

                * יש מי שסובר שהשעות הזמניות מתארכות בהתאם (תרומת הדשן סימן א; שו"ת דברי יוסף שוורץ עמוד נח; ר' טוקצ'ינסקי בספר "בין השמשות" עמוד צח). אך פלג המנחה אינו תלוי בפרופורציות (פרי חדש, קונטרס דבי שמשא, סוף ספר מים חיים).
                * לפי שיטה אחרת, מתעלמים מהארכת השעות אך נשארים עם צאת הכוכבים פרופורציונלי (72 דקות בכל כיוון), כך שהשולחן ערוך והרמב"ן יצרו זמן לפלג סמוך לשקיעה (רמב"ן פסחים נד:, או"ח רלג; או"ח רסא).
                * פוסקים בני זמננו האריכו את כל שעה זמנית, אך הגדירו את צאת הכוכבים לפי 13.5 דקות זמניות בלבד, ולא 72 (בן איש חי, שנה א, ויקהל ח; אור לציון ח"ב עמוד קמז; מאמר מרדכי ח"ד סימן יב).

                על בסיס זה, יביע אומר (חלק או"ח מג:כ) ובניו — הרב אברהם יוסף (פרשת תרומה תשע"ט דקה 3:55) והרב יצחק יוסף (מוצ"ש פסח תשע"ט דקה 37, מוצ"ש בא תשע"ח דקה 25; ילקוט יוסף מהדורה חדשה סימן רעא עמודים 139, 144–147) — סוברים שיש למדוד פלג המנחה לפי צאת הכוכבים הגאוני, לחומרא ולקולא כאחד.

                מנגד, הרב דוד יוסף (אוצרות יוסף תשובה ז, סוף הלכה ברורה חלק יד) מצדד להחזיר את ההגדרה המקורית — שעה ורבע זמניות לפני השקיעה, כמסורת ספרדית קדומה.

                כל דעה מביאה עימה חומרות אך גם קולות. לכן, יש המציגים את שתי השיטות כשוות במשקלן, אך ממליצים להחמיר במצוות דאורייתא עם ברכות לפי פלג המאוחר יותר (הליכות עולם א:248).
                """
            } else {
                return """
                Pelag Ha'Minḥa is defined as the latter half of the time span between מנחה קטנה until the end of the day (ערב), occurring at 10¾ hours into the day (Berakhot Bavli 26b). Since מנחה קטנה begins at 9½ hours into the day, this leaves only 1¼ seasonal hours from the start of this half until the end of the מנחה. It is during this time that one may start performing a select few commandments of the night, such as accepting Shabbat early (Shulḥan Arukh O"Ḥ, 273:4), lighting Ḥanukah candles early (footnotes of Ḥazon Ovadia Ḥanukah pg. 89) or praying תפילת ערבית when one (preferably) already prayed Minḥa (Berakhoth 26a, Rabbi Yehuda).

                ---

                The Gemara's central inquiry concerns whether the "half" is measured from מנחה גדולה or מנחה קטנה; once the _beraita_ clarifies it is the latter, the Gemara proceeds to calculate the day's span assuming a 12-hour daytime period, and פלג המנחה happening within those 12-hours. It identifies that מנחה קטנה is the 9½'th hour of the day, then leaving this "half" (פלג המנחה) to start at "11 minus a quarter hours". This implies that the two halves of מנחה קטנה are equal, placing ערב at the 12th hour—after both halves have elapsed. However, the Gemara does not explicitly define ערב, leaving it to the Rishonim to associate it either with sunset or nightfall.

                The calculation of seasonal hours from sunrise to sunset aligns with the sacrificial schedule, particularly the כבש של בין הערבים (afternoon lamb offering), which parallels the מנחה prayer. This is per the proof of Rabbenu Ḥananel (citing R' Yehuda's parallel's between the rules of the שתי תמידים and when one can pray the two daytime prayers). Thus, פלג המנחה is placed 1¼ seasonal hours before sunset (as held by Talmideh Rabbenu Yonah, Berakhoth Bavli 26a; Rambam, Laws of Prayer, 3:4; Shilteh Hagiborim on the Mordekhi; R' Yitzḥak Yisraeli's explanation of the Meiri - Yoseh Binah pg. 105).

                However, other authorities defined the day as starting from Dawn and ending by Nightfall, thus defining ערב (being the end-time of מנחה) as Nightfall (as writes the Rosh on Berakhot 1:1 & 4:6; Tosafot Ha'Rosh on Berakhot 27a; Rashba on Berakhot 2a). The questions on the specific implementations comes from the origin of said definition (Pesaḥim Bavli 94a) and how it's structured there:

                - The Gemara in Pesaḥim extended the day proportionally, where the same 4 mil that was used to start the day is the same 4 mil that was used to end the day. One approach is to assume the seasonal hours get extended to match this new length (as ruled by the Terumat Ha'Deshen; see siman 1), thus keeping halachic midday corresponding with the sun's midpoint in its traversal (as explicitly outlined by Shu"t Divreh Yosef Shwartz pg. 58 & R' Tukachinsky in the Sefer "Ben Hashmashot", pg. 98). Nevertheless, Pelag Ha'Minḥa is independent from proportionality (as discussed in Pri Ḥadash, Kuntress Debei Shimsha, end of ספר מים חיים), hence allowing either one of those rules to be broken. This opened the door for two preceding interpretations:
                - By ignoring the extended length of a seasonal hour but still keeping a proportionate Nightfall (thus being 72 minutes in both directions), the S"A & Ramban (in addition to Ra'ah, Berakhoth 26b; Ritva, Berakhoth 27b; Rabbi Yaakov Emden, Prozdor Bayit 41, paragraph 28 explicitly linking this to Shabbat's Candle Lighting) created a time for פלג המנחה that was close enough to sunset to make both terms used interchangeably (see the Ramban, Pesaḥim 54b; as for the S"A, see O"Ḥ 233 for Nightfall being the end time of מנחה as well as O"Ḥ 261 describing what Nightfall is, and the connection between sunset for Tosefet Shabbat to פלג המנחה, as the Rama implicitly outlines).
                - Contemporary authorities, however, extended the length of each seasonal hour but defined Nightfall using the 13.5 seasonal minutes measurements, disproportionate to the 72 seasonal minutes added for Dawn (see the Ben Ish Ḥai, Year I, Vayakhel VIII; see also Ohr Letzion vol. 2 pg. 147 & the responsas of the Ma'amar Mordechai vol. 4 siman 12). This meant that the 6<sup>th</sup> seasonal hour no longer corresponded to the midpoint of the sun's traversal.

                This is all a build up to the opinions of Yabi'a Omer (handwritten notes on Yabi'a Omer I O"Ḥ 43:20) and his two sons - R' Avraham Yosef in his [Parashat Terumah 5779 shiur min 3:55](https://torahanytime.com/lectures/76371) as well as R Yitzḥak Yosef in multiple shiurim ([Motzei Shabbat Pesach 5779 shiur min 37](https://torahanytime.com/lectures/81670), [Motzei Shabbat Bo 5778 shiur min 25](https://torahanytime.com/lectures/55391)) & his Yalkut Yosef (new edition, siman 271, pages 139 & 144-147) - to use the Geonic Nightfall as an offset for Pelag, in both stringencies (such as by blessings in vain regarding ערבית and הדלקת נרות), but _also in its leniencies_ (such as the last time to eat _Seudat Shelishit_ on Erev Pesaḥ - see Ḥ"'O Pesaḥ pg. 67 & pg. 199). This is also reflected in later writings of Maran zt'l himself (Ḥazon 'Ovadia Ta'anit pg. 94; Halikhot 'Olam vol. 1 pg. 223), even if he's not made mention of it by earlier sections of how seasonal hours work (Halikhot Olam, vol. 1 pg. 248). The questions on this position do not come from its specifications in the books, since the Sefarim were vague in terms of a resulting time; rather, the questions come from the implementation in the Ohr Hachaim calendar, which fills in blanks that the sefarim did not specify (often times from the direction of Hakham Ovadia himself). In that calendar, they ignore _both_ the proportionality of the day when defining Nightfall _and_ the use of those extended seasonal minutes. Furthermore, this calculation is _isolated_ to פלג המנחה; other zemanim in the calendar are all consistent with the time range from sunrise to sunset. Nevertheless, we've used the implementation of the Ohr Hachaim calendar when representing the "Yalkut Yosef" opinion, due to its authoritative status in representing the calculations from the sefarim.

                In contrast, R' David Yosef (אוצרות יוסף תשובה ז בסוף הלכה ברורה חלק י"ד) advocates restoring פלג המנחה's definition as 1¼ seasonal hours before sunset, as per the original Sepharadic tradition. In addition to the questions raised on the Yabi'a Omer's position above, there is no concern about going against the stricter ruling for matters of blessings (effectively being everything that can be done from פלג המנחה), since precedents in a blessing override concerns about them (source: מנחת כהן, מעמר ב, בסוף פרק ט. This is also applicable for the latest time to say the blessings of קריאת שמע, where we are not concerned for the MG"A seasonal hour calculation). However, the Halacha Berura also allows praying מנחה after sunset; although this would be fine if it was reserved as a בדיעבד ruling, the Halacha Berura relies on this time enough that one should prefer this time for minyan instead of praying alone before sunset, even though he wouldn't use it as a reliability for the calculation of פלג המנחה.

                Each of the differing opinions introduce its stringencies, but also leniencies. Combining that reason with a general concern of either adhering to the text or intellectual honesty with the structure for the day (both brothers respectively) introduces the two opinions without any room for compromising (irrespective of Halacha Berurah Siman 233 pg. 75 saying the Yalkut Yosef opinion). Therefore, we've presented both opinions with equal weight. However, by knowing the stringencies, one can adhere to both opinions, especially by restricting Biblical obligations with its blessings (such as קידוש בליל שבת or הבדלה מוקדם ביום שבת) to the stricter/later פלג המנחה, based on the Halikhot 'Olam (vol. 1 pg. 248) who attributed Biblical matters to the extended seasonal hours.
                - There are opinions that would argue that ערבית, what they assert as the first prayer of "the day", would fulfill the Biblical obligation to prayer and thus be subject to the same recommendation. Nevertheless, the Kaf Ha'Ḥayyim (O"Ḥ 233:7) asserts that we are lenient regarding prayer to use the time represented in our calendar as the Halacha Berura time (which we can thus extend to anything needing a blessing - the "stringency" of this ruling - based the position of the מנחת כהן), even if he rules in other cases would indicate that פלג המנחה should be based on Nightfall (O"Ḥ 692:29). As for the second concern, there are others who assume שחרית is the Biblically-mandated prayer (ראה בפרי מגדים סי' ד' מש"ז ס"ק טס), especially in light of the opinion that ערבית is a תפילת רשות in the Gemara's perspective.
                - The "later time" for the Rabbinic/Biblical divide above would depend on whether you demand proportionality (as the Halacha Berura does) or don't (as the Yalkut Yosef does). However, interesting to note that the only authority that considered the Nightfall position (the Yalkut Yosef) is also the one that doesn't demand proportionality. Thus, one could use the ילקוט יוסף time above to be exempt according to both opinions; should it prove to be too strict (which may happen in northern countries), one should calculate the seasonal hours from Dawn to the Geonic Nightfall and use the 10.75<sup>th</sup> hour instead of our listed time, which should result in a time closer to the Halacha Berura time. As for the difference of "צאת הכוכבים" between this implementation of the MG"A hours and the morning ones (those being by קריאת שמע and both times for חמץ בערב פסח), perhaps we're not concerned about proportionality since this form of calculation is already a stringency for us, and the proportionate time would increase the stringency on the assumption (that Nightfall is 72 minutes) we do not rule by.

                ---

                Fun fact: Under Biblical Hebrew rules of "קטל", the proper pronunciation of פלג המנחה should transliterate to "Peleg Ha'Minḥa". Nevertheless, we've kept it "Pelag" to adhere to Hakham Ovadia's pronunciation style.
                """
            }
        case .candlelightingZman:
            if Locale.isHebrewLocale() {
                return "זהו הזמן האידיאלי להדלקת נרות לפני כניסת שבת או חג. אולם, בדיעבד, ניתן להדליק את הנרות עד חמש דקות לפני השקיעה אם לא הצליחו להדליק בזמן הראוי.\n\nאם מדובר בשבת שממשיכה ליום טוב שבו מדליקים נרות, מדליקים את הנרות לאחר צאת הכוכבים/לילה. עם זאת, אם היום הבא הוא שבת, מדליקים את הנרות בזמן הרגיל, לפני שקיעת החמה. זמן זה מחושב כ-%c דקות רגילות לפני שקיעת החמה (כולל השפעת הגובה).\n\nלוח אור החיים תמיד מציג את זמן הדלקת הנרות כ-20 ו-40 דקות לפני שקיעת החמה."
            } else {
                return "This is the ideal time for a person to light the candles before shabbat/chag starts. However, bediavad, a person can light the candles as late as five minutes before sunset if they were not able to light it at the appropriate time.\n\nIf it is Shabbat going into a Yom Tov that has candle lighting, the candles are lit after Tzeit/Nightfall. However, if the next day is Shabbat, the candles are lit at their usual time before sunset.\n\nYou have this time set to be calculated as %c regular minutes before sunset (elevation affects this time).\n\nThe Ohr HaChaim calendar always shows the candle lighting times for 20 and 40 minutes before sunset."
            }
        case .sunsetZman:
            if Locale.isHebrewLocale() {
                return "זהו הזמן ביום בו מתחיל עבר מיום ליום הבא, על פי הלכה.  השקיעה ההלכתית מוגדרת כרגע שקרקע השמש נעלם למעלה בקו האופק במהלך השקיעה (שמשתנה לפי הגובה).  מיד לאחר השקיעה בין השמשות מתחיל, כדאי לשים לב שזה לפי הגאונים.  אבל רבנו תם פוסקת שהשמש ממשיכה לשקוע עוד 58.5 דקות לאחר השקיעה, ורק לאחר מכן מתחיל בין השמשות לאורך עוד 13.5 דקות.  יש לשים לב כי אף על פי מרן זצ\"ל פוסק שיש לומר מנחה עד צאת הכוכבים, הרבה פוסקים, כמו המשנה ברורה, אומרים שיש לאדם לומר את תפילת מנחה לפני השקיעה ולא לפני צאת הכוכבים. רוב המצוות שחייבות להתבצע ביום כדאי לעשותן לפני זמן זה."
            } else {
                return "This is the time of the day that the day starts to transition into the next day according to halacha.\n\nHalachic sunset is defined as the moment when the top edge of the sun disappears on the horizon while setting (elevation affects this time).\n\nImmediately after the sun sets, Bein Hashmashot/twilight starts according to the Geonim, however, according to Rabbenu Tam the sun continues to set for another 58.5 minutes and only after that Bein Hashmashot starts for another 13.5 minutes.\n\nIt should be noted that even though Rabbi Ovadia says that you can say mincha until nightfall, many poskim, like the Mishna Berura, say that a person should ideally say mincha BEFORE sunset and not before Tzeit/Nightfall.\n\nMost mitzvot that are to be done during the day should ideally be done before this time."
            }
        case .tzetHakokhavimLChumraZman:
            if Locale.isHebrewLocale() {
                return "זמן זה מחושב כעשרים דקות זמניות אחר שקיעה (וגובה המקום משפיע על זמן זה) (ילקוט יוסף סימן רס״א:ב).\n\nזמן זה חשוב לעניין תעניות ולקביעת זמן קיום ברית מילה, אך מלבד זאת אין להשתמש בו לכל דבר אחר, כגון סוף זמן מנחה.\n\nזמן זה מוצג בצבע אפור בשבתות ויום טוב (בהוראת רבותינו) כדי שלא יבואו לחשוב שזמן זה הוא זמן יציאת שבת או יום טוב.\n\nמחוץ לארץ ישראל, זמן זה מחושב על־ידי בירור מספר הדקות שבין שקיעה לבין ירידת החמה ל-5.075 מעלות מתחת לאופק ביום השוויון (שבו י\"ב שעות בין נץ לשקיעה). לאחר מכן מוסיפים מספר דקות זמניות זה לשעת השקיעה במשך כל ימות השנה לקבלת זמן צאת הכוכבים לחומרא. משתמשים במעלה זו משום שבארץ ישראל זמן זה הוא עשרים דקות אחר שקיעה."
            } else {
                return "This time is calculated as 20 seasonal minutes after sunset (elevation affects this time) (Yalkut Yosef Siman 261:2).\n\nThis time is important for fast days and deciding when to do a brit milah. Otherwise, it should not be used for anything else like the latest time for mincha.\n\nThis time is shown in gray on shabbat and yom tov (as advised by our rabbeim) in order to not let people think that shabbat/yom tov ends at this time.\n\nOutside of Israel, this time is calculated by finding out the amount of minutes between sunset and 5.075 degrees below the horizon on the equinox (12 hours between sunrise and sunset), then we add that amount of zmaniyot minutes to sunset all year round to get the time of Tzeit/Nightfall L'Chumra. We use 5.075 degrees below the horizon because that is the time when it is 20 minutes after sunset in Israel."
            }
        case .tzetHakokhavimZman:
            if Locale.isHebrewLocale() {
                return "צאת הכוכבים הוא הזמן שבו היום ההלכתי הבא מתחיל, לאחר סיום זמן בין השמשות.\n\nזהו הזמן המאוחר ביותר שבו אדם יכול לומר מנחה לפי דעת הרב עובדיה יוסף זצ״ל. ניתן להתחיל את עמידת מנחה בכל זמן שהוא לפני זמן זה. (יביע אומר חלק ז׳ סימן ל״ד)\n\nזמן זה מוצג בצבע אפור בשבת ויום טוב (בהוראת רבותינו) כדי שלא יבואו לטעות ולחשוב ששבת/יום טוב מסתיימים בזמן זה.\n\nזמן צאת הכוכבים זה מחושב כ־י\"ג וחצי דקות זמניות לאחר השקיעה (הגובה משפיע על זמן זה).\n\nהגר״א מחשב שעה זמנית על ידי חלוקת הזמן שבין הנץ החמה לשקיעה (גם כאן הגובה משפיע) ל־12 חלקים שווים. לאחר מכן מחלקים כל אחד מהחלקים ל־60 כדי לקבל דקה זמנית לצורך חישוב י״ג וחצי דקות.\n\nמחוץ לארץ ישראל, זמן זה מחושב לפי כמות הדקות שבין שקיעה לבין הרגע שבו השמש נמצאת 3.7 מעלות מתחת לאופק ביום השוויון (כאשר יש 12 שעות בין זריחה לשקיעה). לאחר שמוצאים ערך זה, מוסיפים את הדקות הזמניות הללו לשקיעה במשך כל השנה כדי לקבל את זמן צאת הכוכבים.\n\nאנו משתמשים ב־3.7 מעלות מתחת לאופק משום שבישראל זהו הזמן התואם ל־13.5 דקות לאחר השקיעה."
            } else {
                return "Tzeit/Nightfall is the time when the next halachic day starts after Bein Hashmashot/twilight finishes.\n\nThis is the latest time a person can say Mincha according Rav Ovadiah Yosef Z\"TL. A person could start the amidah of mincha at any time that is at least before this time. (Yabia Omer 7 Siman 34)\n\nThis time is shown in gray on shabbat and yom tov (as advised by our rabbeim) in order to not let people think that shabbat/yom tov ends at this time.\n\nThis time is calculated as 13 and a half zmaniyot/seasonal minutes after sunset (elevation affects this time).\n\nThe GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation affects this time) and divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute.\n\nOutside of Israel, this time is calculated by finding out the amount of minutes between sunset and when the sun is 3.7 degrees below the horizon on the equinox (12 hours between sunrise and sunset), then we add that amount of zmaniyot minutes to sunset all year round to get the time of Tzeit/Nightfall. We use 3.7 degrees below the horizon because that is the time when it is 13.5 minutes after sunset in Israel."
            }
        case .fastEndsZman:
            if Locale.isHebrewLocale() {
                return "זמן זה מחושב כעשרים דקות זמניות (מחוץ לארץ ישראל, עשרים דקות זמניות מותאמות על פי המרחק מקו המשווה) לאחר השקיעה (שמשתנה לפי הגובה) (ילקוט יוסף סימן רס״א:ב).\n\nנכתב בהלכה ברורה (חלק יד, באוצרות יוסף [קונטרס כי בא השמש]) כי הרב עובדיה יוסף זצ״ל היה נוסע בניו יורק בתשעה באב ואמר לבנו, הרב דוד יוסף שליט״א, שהתענית מסתיימת בצאת הגאונים (שלוש עשרה וחצי דקות זמניות לאחר השקיעה). אולם, בספרו חזון עובדיה (ארבע תעניות עמוד 12), הוא כותב שהתענית מסתיימת סביב עשרים דקות לאחר השקיעה.\n\nבלוח אור החיים נכתב שהתענית מסתיימת בצאת הכוכבים. הרב בניזרי (מחבר הלוח) מסביר שמדובר או בשלוש עשרה וחצי דקות לאחר השקיעה או בעשרים דקות, ואמר: \"הלוח פשוט מציין שהתענית מסתיימת בצאת הכוכבים; אדם יכול לסיים את התענית בעשרים דקות לאחר השקיעה אם הוא רוצה להחמיר.\"\n\nקבענו את זמן סיום התענית על פי עשרים הדקות משום שחזון עובדיה הנ״ל מחמיר בענייני תעניות, אך מי שרוצה לסיים את התענית לאחר שלוש עשרה וחצי דקות רשאי לעשות כן."
            } else {
                return "This time is calculated as 20 seasonal minutes (outside of Israel, 20 seasonal minutes adjusted based on the distance from the equator) after sunset (elevation affects this time) (Yalkut Yosef Siman 261:2).\n\nIt is brought down in Halacha Berurah (vol. 14, in Otzrot Yosef [Kuntrus Ki Ba Hashemesh]) that Rabbi Ovadiah Yosef Z\"TL was once traveling in New York on Tisha Beav and he said to his son, Rabbi David Yosef Shlita, that the fast ends at tzeit geonim (13.5 zmaniyot minutes after sunset). However, in his sefer Chazon Ovadiah (Arba Taaniyot Page 12), he writes that the fast ends around 20 minutes after sunset.\n\nIn the Ohr HaChaim calendar, they write that the fast ends at Tzait Hacochavim. Rabbi Benizri (author of the calendar) explains that it refers to either 13.5 or 20 minutes after sunset, and he said, \"The calendar just says that the fast ends at Tzait Hacochavim, a person can end the fast at 20 minutes after sunset if he wants to be stringent.\"\n\nWe have set the end time of the fast to be at the 20 minute time because the Chazon Ovadia quoted above is stringent for fasts, however, someone who wants to end the fast at the 13.5 minute time has the right to do so."
            }
        case .shabbatChagEndsZman:
            if Locale.isHebrewLocale() {
                return """
                    למרות ששבת הוא יום נוסף שצריך להסתיים לאחר בין השמשות, ישנם גורמים שדורשים להחמיר בהם. ראשית, מדובר בזמן מקראי, כלומר יש דרישה לפחות להשתמש בדעה הרחבה ביותר של בין השמשות תוך שמירה במסגרת הגאונית (כלומר, יש להשתמש בזמני ערב של 20 דקות במקום בזמני ערב של 13.5 דקות; ה-2 דקות הנוספות ב-20 דקות נועדו להקל עם דעת רבי יוסי על בין השמשות, בנוסף לדעת הרמב"ם על ערב של 18 דקות). שנית, השולחן ערוך פוסק שניתן לצאת משבת רק לאחר שכל מרכיבי הספק הובהרו. אנו מצמידים אזהרה זו עם מושג נוסף שנקרא "תוספת שבת" (שדן בשולחן ערוך אורח חיים רצ"ג:א), להאריך את משך השבת מעבר לזמן הסיום ההלכתי כדי להתאים לדעות אחרות. ישנן כמה דעות שקשורות לזה, כולל:
                    - קביעת זמנים אלו **אסטרונומית**, באופן עצמאי מחישוב הזמן העונתי לפי הלכה. פתרון לכך יהיה להעניק זמן גנרי שיכלול הכל או להיות מדויק מאוד, דבר שיגרום לזמן להשתנות מדי שבוע (באמצעות זוויות מתחת לאופק).
                    - התאמה עבור המג'רב, הוספת 7 דקות לחשבון הסופי. זו העמדה שמיוצגת בבא"ח, (שנה ראשונה) וַיָּכֵל ד', אור לציון א' יו"ד סימן י'. זה מתבצע למעשה על ידי הרב יצחק יוסף (עין יצחק חלק ג עמוד ת"ב).
                    - הליכה בעקבות האנשים המפרשים בכל הדורות הספרדיים (ראה באור לציון ד' פרק כ' הערה ב) שהמתינו עד זמן ערב לפי _רבנו תם_ (כפי שמקודד בפסחים בבבלי 94א) לפני עשיית מלאכה. זמן זה יאריך **72 דקות זמניות** (עם גבול מחוץ לארץ ישראל של 72 דקות קבועות כאשר הזמן העונתי ארוך יותר מכך, כפי שצוטט ביילקוט יוסף (מהדורה חדשה) סימן רצ"ג עמוד תשכד; הלכה ברורה, הקדמת לסימן רס"א הלכה י"ט; יודעי בינה ז':ו).
                    לכן, למרות שגדול הדור הרב עובדיה זצ"ל המליץ על זמן רבנו תם לאנשים שיכולים לכך - יביע עומר ב' סימן כ"א, הוא סיכם זמן מינימום בישראל של 30 דקות קבועות כל שבוע. (יש לציין שהרב יצחק יוסף כותב כי מרן רבנו עובדיה יוסף זצ"ל אמר לעורכי לוח אור החיים לקבוע את זמן צאת השבת כ־20 דקות לאחר השקיעה בכל שבוע [בישראל]. אולם כאשר עשו כן, היו רבים שלא קנו את הלוח כיוון שראו בכך קולא מיותרת. לכן פנו לרב בבקשה לשנות ל־30 דקות לאחר השקיעה, ולבסוף הוא הסכים לכך). להאריך זאת מעבר לגבולות ארץ ישראל (ילקוט יוסף - מהדורה חדשה, סימן 261 עמוד 755) מדדנו היכן השמש תהיה מתחת לאופק 30 דקות ביום השוויון בארץ ישראל, ומיישמים את "ספירת המעלות" הזו (7.165º) בכל מקום. למרות שיש תקדים להשתמש בשיטות שיביאו לזמנים קצרים יותר (ילקוט טהרה מכתב עז), השתמשנו במדידה המחמירה הזו כדי להבטיח שלא יהיה יותר מקלים מהלוח המודפס של אור החיים כשמתייחסים לארץ ישראל.
                    יש לקבוע מינימום במקרים בהם הזמן האסטרונומי יביא לזמן מוקדם יותר מהסטנדרטים ההלכתיים לפי דעות ערב גאוניות (20 דקות זמניות, 20 דקות קבועות).
                    """
            } else {
                return """
                    Although Shabbat is another day that should be over after בין השמשות, there are factors to be stringent for. For one, it is a Biblical time, meaning we require at minimum to use the most extended Ben Hashemashot opinion while still keeping within the Geonic framework (meaning we use the 20 minute Nightfall as reference instead of the 13.5 minute one; the extra two minutes in 20 is meant to accommodate רב יוסי's opinion on בין השמשות (twilight), on top of the Rambam's Nightfall opinion of 18 minutes). Secondly, the Shulḥan Arukh rules one can only take out Shabbat once all elements of doubt were clarified. We pair this warning with another concept called "תוספת שבת" (discussed in שו"ע או"ח רצ"ג:א), to extend the length of Shabbat beyond the legal end-time to accommodate other opinions. There are a few of them at play, including:
                    - Determining these times **astronomically**, independent of the law-based seasonal-minute calculation. Solving this would mean giving a generic time that could encompass everything or being very precise that would make the value vary weekly (through the use of degrees below the horizon)
                    - An accommodation for the מג'רב, adding an extra 7 minutes to the final count. This is the position represented in the בא"ח, (שנה ראשון) ויקהל ד', אור לציון א' יו"ד סימן י'. This is taken practically by Rav Yitzḥak Yosef (עין יצחק חלק ג עמוד ת"ב)
                    - Following in the footsteps of the extremely pious individuals throughout Sepharadic history (ראה באור לציון ד' פרק כ' הערה ב) that waited until the time of Nightfall according to _Rabbenu Tam_ (as codified in Pesahim Bavli 94a) prior to doing melakha. This would make the time length of **72 seasonal minutes** long (with a limit outside Eretz Yisrael to 72 fixed minutes when the seasonal time is longer than this, as quoted in ילקוט יוסף (מהדורה חדשה) סימן רצ"ג עמוד תשכד; הלכה ברורה, הקדמת לסימן רס"א הלכה י"ט; יודעי בינה ז':ו)
                    Thereby, although Maran Ovadya zt"l recommended the time for Rabbenu Tam for those who could have - יביע עומר ב' סימן כ"א, he concluded a minimum time in Israel of 30 fixed minutes every week. (It should be noted that Rav Yitzḥak Yosef writes that Rabbi Ovadia Yosef ZT"L told the makers of the Ohr Hachaim calendar to put 20 minutes after sunset for when Shabbat ends every week [in Israel]. However, when they did, there were many people that would not buy the calendar because they saw it as an extra leniency. So they pleaded with the rav to change it to 30 minutes after sunset, and he eventually gave his consent). To extend this beyond the borders of Eretz Yisrael (Yalkut Yosef - new edition, siman 261 page 755) we have measured where the sun would be below the horizon 30 minutes below the horizon on the equinox day in Eretz Yisrael, and apply that "degree count" (7.165º) everywhere. Although there is precedent to use methods that would result in even shorter times (ילקוט טהרה מכתב עז), we have used this stricter measurement to ensure one would not be more lenient than the printed Ohr Hachaim calendar when applied to Eretz Yisrael.
                    A minimum is enforced in cases where the astronomical time would result in a time earlier than the legal standards within the opinions of Geonic nightfall (20 seasonal minutes, 20 fixed minutes).
                    """
            }
        case .rabbenuTamZman:
            if Locale.isHebrewLocale() {
                return "זמן זה הוא צאת הכוכבים לפי רבנו תם.\n\nצאת הכוכבים הוא הזמן שבו מתחיל היום ההלכתי הבא, לאחר שמסתיים בין השמשות.\n\nלפי רבנו תם, 72 דקות אלו מורכבות משני חלקים: החלק הראשון הוא 58.5 דקות עד לשקיעה השנייה (ראה פסחים צד ע\"א ותוספות שם). לאחר השקיעה השנייה, ישנן 13.5 דקות נוספות עד צאת הכוכבים.\n\nילקוט יוסף (סימן רל״ה) כתב שכשם שאדם צריך להחמיר לקרוא קריאת שמע של שחרית לפני זמן מגן אברהם, כך גם עליו להחמיר ולחזור ולקרוא קריאת שמע לאחר זמן רבנו תם, אם קרא קריאת שמע מוקדם.\n\nהרב עובדיה יוסף כותב (הליכות עולם, חלק א, עמוד ר\"נ, הלכה ב, וילקוט יוסף סימן רס\"א:א) שראוי להמתין עד שיעבור זמן רבנו תם לעניינים דאורייתא (מן התורה), כגון שבת ויום הכיפורים. הרב דוד יוסף (הלכה ברורה סימן רצ\"ג) כולל בתוך חומרה זו גם את יום טוב. עם זאת, יש לציין כי ימי טובה שניים של גלויות אינם דאורייתא, ולכן אין צורך בחומרה זו.\n\nזמן זה מחושב כ72 דקות זמניות לאחר השקיעה (שמשתנה לפי הגובה). עם זאת, מחוץ לארץ ישראל, זמן זה מחושב על ידי מציאת מספר הדקות שבין השקיעה לבין הרגע שבו השמש נמצאת 16.04 מעלות מתחת לאופק ביום השוויון (כשיש 12 שעות בין זריחה לשקיעה), והוספת מספר זה של דקות זמניות לזמן השקיעה לאורך כל השנה. במקומות צפוניים יותר בעולם, התאמה זו תגרום לזמן רבנו תם להיות מאוחר ביותר, ולכן אנו מגבילים את זמן המקסימום ל-72 דקות רגילות. זאת בהתבסס על ילקוט יוסף סימן רצ\"ג:ו והלכה ברורה ט\"ו עמוד מ\"ב. עם זאת, עיין אורחות מרן חלק ג׳, עמוד 326.\n\nהגר\"א מחשב שעה זמנית על ידי לקיחת הזמן שבין הזריחה לשקיעה (שמשתנה לפי הגובה) ומחלק אותו ל-12 חלקים שווים. לאחר מכן אנו מחלקים אחד מתוך 12 החלקים האלה ל-60 כדי לקבל דקה זמנית, על מנת לחשב 72 דקות."
            } else {
                return "This time is Tzeit/Nightfall according to Rabbenu Tam.\n\nTzeit/Nightfall is the time when the next halachic day starts after Bein Hashmashot/twilight finishes.\n\nAccording to Rabbeinu Tam, these 72 minutes are made up of 2 parts. The first part is 58 and a half minutes until the second sunset (see Pesachim 94a and Tosafot there). After the second sunset, there are an additional 13.5 minutes until Tzeit/Nightfall.\n\nYalkut Yosef (Siman 235) writes how just as a person should be stringent to say Shema in the morning before the time of the Magen Avraham, so too, they should be stringent to repeat Shema after the time of Rabbenu Tam if they said Shema early.\n\nRabbi Ovadia writes (Halichot Olam, Chelek 1, Page 250, Halacha 2 and Yalkut Yosef Siman 261:1) that it is proper to wait until the time of Rabbenu Tam has passed for biblical matters like Shabbat and Yom Kippur. Rabbi David Yosef (Halacha Berura Siman 293) includes Yom Tov into this stringency. However, it should be noted that second day Yamim Tovim are not biblical and therefore do not need this stringency.\n\nThis time is calculated as 72 zmaniyot/seasonal minutes after sunset (elevation affects this time). However, outside of Israel, this time is calculated by finding out the amount of minutes between sunset and when the sun is 16.04 degrees below the horizon on the equinox (when there is 12 hours between sunrise and sunset) and adding that amount of zmaniyot minutes to sunset all year round. In more northern places in the world, this adjustment will make the time for Rabbenu Tam extremely late, therefore, we limit the maximum time limit for Rabbenu Tam to 72 regular minutes. This is based on Yalkut Yosef Siman 293:6 and Halacha Berurah 15 Page 42. See however, Orchot Maran Vol. 3, Page 326.\n\nThe GR\"A calculates a zmaniyot/seasonal hour by taking the time between sunrise and sunset (elevation affects this time) and divides it into 12 equal parts. Then we divide one of those 12 parts into 60 to get a zmaniyot/seasonal minute in order to calculate 72 minutes."
            }
        case .chatzotLaylaZman:
            if Locale.isHebrewLocale() {
                return "זהו חצות הלילה ההלכתי, כאשר השמש נמצאת בדיוק במרכז המעבר הסולארי שלה בקו הרקיע (מרידיאן השמימי) לאחר ששקעה. יש לציין כי השמש יכולה להיות ישירות מתחתנו רק בטרופי קרב ובטרופי גדי. בכל מקום אחר, השמש תהיה בזווית, אפילו באמצע הלילה.\n\nרצוי לקיים את סעודת מלווה מלכה לפני זמן זה.\n\nזמן זה מחושב כ6 שעות זמניות (בהתבסס על שקיעת היום הנוכחי וזריחת היום הבא) לאחר השקיעה."
            } else {
                return "This is the middle of the halachic night, when the sun is exactly in the middle of it's solar transit of the celestial meridian after it sets. It should be noted, that the sun can only be directly underneath in the Tropic of Cancer and the Tropic of Capricorn. Everywhere else, the sun will be at an angle even in the middle of the night.\n\nIt is ideal to have Melaveh Malka before this time.\n\nThis time is calculated as 6 zmaniyot/seasonal hours (based on sunset of today and sunrise of the next day) after sunset."
            }
        case .ulchaparatPesha:
            if Locale.isHebrewLocale() {
                return "כאשר ראש חודש חולף במהלך שנה מעוברת, אנו מוסיפים את המילים \"וּלְכַפָּרַת פֶּשַׁע\" בתוך תפילת מוסף. אנו מוסיפים את המילים הללו מחודש תשרי עד החודש השני של אדר. אך לשאר השנה ובשנים רגילות, אין אנו אומרים את המילים הללו. (חזון עובדיה חנוכה שו)"
            } else {
                return "When Rosh Chodesh happens during a leap year, we add the words, \"וּלְכַפָּרַת פֶּשַׁע\" during Musaf. We only add these words from Tishri until the second month of Adar. However, for the rest of the year and during non leap years we do not say it. (Chazon Ovadiah Chanukah 306)"
            }
        case .tekufaTime, .tekufaLength:
            if Locale.isHebrewLocale() {
                return """
                התקופות של השנה סולרית נחלקו לארבע חלקים: ניסן, תמוז, תשרי וטבת
                
                - על פי קבלה, יש למנות נשתיית מים בזמן של מתג תקופה עצמו, כמו שכתב הרמ"א (יורה דעה קיז:ה, ראה מעם לועז בראשית ט:ז). למרות שהמנהג הג'רבא היה להרחיב את האזהרה הזאת לפניה ולאחריה לשעה וחצי (רמ"ך בברית כהונה - חלק אורח חיים מערכת ת' אותיות כ"א-כ"ה), מרן זצ"ל כתב (הליכות עולם, חלק שביעי, דף קפ"ג) שצריך רק שליש מזמן הזה (אז רק חצי שעה)
                - שישים יום אחר תקופת תשרי, מחליפים את הנוסח של הברכה התשעי בשמוני עשרה (ברך עלינו). בלוח השנה הגרגוריאני, זה נופל ב-December 4th או ב-December 5th
                
                ---
                
                לדעת מתי התקופה הבה, תיקח הזמן של התקופה שעבר ותסיף את עורך השנה חלקי כמות תקפות (4). לפי שמואל (בבלי ערובין נו), הערך השנה מעוגל כלפי מעלה מהערך האסטרונומי, לפי שזה קל יותר לעקוב אחריו (חזון איש, אורח חיים 138:4). לכן, כיוון שערך השנה של שמואל הוא 365.25 ימים, לפיכך, חלוקתה ב-4 נותנת לנו 91 ימים, 7 שעות ו-30 דקות.
                
                עוד מחלוקת יש בזמן עצמה: האם התקופה הראשונה התחיל מזמן השווה של 12:00 או הזמן של חצות בישראל. למרות שלוח אור חיים פסק בשעה שווה, התנובות שדה (רב אהרן ברון) מתנגד לכך בשל האופי השרירותי של שעה 12:00. לפיכך, הלוח עמודי הוראה פסק בשיטת של חצות (11:39), שרק -21 דקות שווה בהן. לחמרת הקבלה, יכולים ללך אחר שניהם אם תתחיל בזמן של הרב ברון ותסיים אם הזמן של הלוח אור החיים.
                """
            } else {
                return """
Tekufot are the Halachic equivalents of the yearly seasons, which we have four of yearly; Nissan/Spring, Tammuz/Summer, Tishri/Fall & Tevet/Winter. These are based on the solar year, due to being astronomical in nature.

- There is a Kabalistic warning not to drink water during the time of the Tekufah switch itself, as written down by the Rama (Yoreh De'ah 116:5, see Meam Loez Genesis 9:7). Although the Djerban minhag was to extend this for an hour and a half prior and following this time (רמ"ך בברית כהונה - חלק אורח חיים מערכת ת' אותיות כ"א-כ"ה), Maran zt"l writes (Halichot Olam, Chelek 7, Page 183) one need only wait one third of that time (half an hour following and prior)
- 60 days after Tekufat Tishri, outside of Israel, we switch the text of the Shemoneh Esreh's 9th Beracha (ברך עלינו). In the Gregorian calendar, this matches to December 4th or December 5th.

---

To determine when the next Tekufah is, get the known date of the previous Tekufah and add the length of the year divided by the amount of seasons (4). The length of a year, according to Shemuel in Bavli Eruvin, 56a, is a rounded up version of the astronomical length of a year, for the sake of being easier to keep track of (Hazon Ish - OC Siman 138, se’if katan 4). Thereby, since his length of a year is 365.25 days, dividing it by 4 gives us 91 days, 7 hours and 30 minutes.

A further Makhloket is whether the first Tekufah used a fixed clock time of 12:00 PM or used local Israel Ḥatzot. Although the Ohr Hachaim calendar uses the fixed clock time like Rav Tuchanski does in his calendar, the תנובות שדה (Rav Aharon Boron) takes issue with this due to the arbitrary nature of a 12:00 midpoint. As such, the עמודי הוראה calendar (as well with the unofficial לוח ילקוט יוסף) uses the local Israel Hatzot time of 11:39 AM, which is only a -21 minute difference. For the water warning above, it is possible to accommodate both by starting from half an hour before R Boron's time and finishing half an hour after the time listed in the Ohr Hachaim calendar.
"""
            }
        case .tachanun:
            if Locale.isHebrewLocale() {
                return "הנה רשימת הימים שבהם אין אומרים תחנון:\n\nכל ראש חודש\nכל שבת\nכל יום טוב\nחול המועד\nאסרו חג (היום שלאחר החג)\nכל חודש ניסן\nפסח שני (י״ד באייר)\nל״ג בעומר\nמראש חודש סיון ועד י״ב בסיון (כולל)\nתשעה באב\nט״ו באב\nערב ראש השנה וראש השנה\nערב יום כיפור ויום כיפור\nמי״א בתשרי (היום שלאחר יום כיפור) ועד סוף חודש תשרי\nכל ימי חנוכה\nט״ו בשבט\nי״ד וט״ו באדר א׳ ובאדר ב׳\nפורים משולש (גם בערים המסופקות)\n\nבכל המקרים הללו אין אומרים תחנון, וכן אין אומרים תחנון במנחה שלפניהם.\n\nהחריגים לכלל זה הם ערב ראש השנה וערב יום כיפור – שכבר נכללים בימים שלפניהם.\n\nלגבי יום ירושלים ויום העצמאות – מאחר שיש בכך מחלוקת, נכתב כי יש הנמנעים מאמירת תחנון.\n\nלדברי הרב מאיר גבריאל אלבז, מנהג מרן הרב עובדיה יוסף זצ״ל (כפי שנהגו בישיבת/כולל יחוה דעת) היה שלא לומר תחנון רק ביום ירושלים עצמו, ולומר תחנון במנחה שלפניו, וכן לומר ביום העצמאות.\n\nעם זאת, הרב יונתן נקשון כותב שמותר להימנע מאמירת תחנון בשני הימים.\n\nיש לשים לב כי קיימים עוד מקרים שבהם אין אומרים תחנון, אך רשימה זו מתייחסת רק לימים קבועים בלוח השנה.\n\nישנם מקרים נוספים שבהם ניתן לדלג על תחנון – כגון כאשר האבלים מרכיבים את רוב המניין, כאשר יש שמחה (ברית מילה, בר מצווה, סיום מסכת), אם כבר עבר זמן צאת הכוכבים, ועוד."
            } else {
                return "Here is a list of days with no tachanun:\n\nEvery Rosh Chodesh\nEvery Shabbat\nEvery Yom Tov\nChol HaMoed\nIsru Chag (day after chag)\nThe entire month of Nissan\nPesach Sheni (14th of Iyar)\nLag Ba'Omer\nRosh Chodesh Sivan until the 12th of Sivan (7 days after Shavuot and the 12th is included)\n9th of Av\n15th of Av\nErev Rosh Hashanah and Rosh Hashanah\nErev Yom Kippur and Yom Kippur\nFrom the 11th of Tishri (day after Yom Kippur) until the end of Tishri\nEvery day of Chanukah\n15th of Shevat\n14th and 15th of Adar I and Adar II\nPurim Meshulash for walled cities (safek included)\nTu Be'Shvat\n\nIn all of these cases tachanun is not said as well as for mincha the day before them. The exclusion to this rule is Erev Rosh Hashana and Erev Yom Kippur which are already before their respective days.\n\nFor Yom Yerushalayim and Yom Ha'atzmaut, since there is a debate, we simply wrote that some say tachanun. According to Rabbi Meir Gavriel Elbaz, the minhag of Rabbi Ovadiah ZT\"L (as they did in the Yechave Da'at Yeshiva/Kollel) was to only skip tachanun on the day of Yom Yerushalayim. Not the day before it or on Yom Ha'atzmaut. However, Rabbi Yonatan Nacson writes that you are allowed to skip tachanun on both days.\n\nNote that there are other times you should not say tachanun, but this list is only for calendar days with no tachanun. There are multiple other cases where you can skip tachanun. For example: if there are mourners making up majority of the minyan, if there is a simcha (joyous occasion like a Brit Milah, Bar Mitzva, or Siyum Masechet), if tzet hacochavim/nightfall already passed, and many more cases."
            }
        case .threeWeeks, .nineDays, .shevuaShechalBo:
            if Locale.isHebrewLocale() {
                return "בזמן שלושת השבועות/תשעת הימים/שבוע שחל בו יש חוקים מסוימים: \n\nשלושת השבועות:\nאסור להאזין למוזיקה.\nמומלץ לדחות את ברכת שהחיינו למקום שבו ניתן.\n\nתשעת הימים:\nאסור להאזין למוזיקה.\nמומלץ לדחות את ברכת שהחיינו למקום שבו ניתן.\nמומלץ לדחות כל פעולות בנייה.\nאסור לערוך חתונות.\nאסור לרכוש בגדים חדשים (אלא אם יש צורך גדול, לדוגמה: מבצע).\nאסור לאכול בשר או יין (אכן בראש חודש ובשבת מותר).\nאסור ללבוש בגדים חדשים לגמרי.\n\nשבוע שחל בו:\nאסור להאזין למוזיקה.\nמומלץ לדחות את ברכת שהחיינו למקום שבו ניתן.\nאסור לערוך פעולות בנייה.\nאסור לערוך חתונות.\nאסור לרכוש בגדים חדשים (אלא אם יש צורך גדול, לדוגמה: מבצע).\nאסור לאכול בשר או יין.\nאסור ללבוש בגדים חדשים לגמרי.\nאסור להסתפר או לגלח את הזקן (רק לגברים).\nאסור לשחות (במים חמים).\nאסור לרחוץ (במים חמים).\nאסור לכבס.\nאסור ללבוש בגדים שנכבסו פרט לבגדי תחתית."
            } else {
                return "During the time of the Three weeks/Nine days/Shevuah shechal bo certain restrictions apply:\n\nThree Weeks:\nNo listening to music\nBetter to delay shehechiyanu\n\nNine Days:\nNo listening to music\nBetter to delay shehechiyanu\nBetter to delay any construction\nNo weddings\nNo purchasing new clothing (unless there is great need ex: a sale)\nNo consumption of meat or wine (excludes Rosh Chodesh and Shabbat)\nNo wearing brand new clothing\n\nShevuah Shechal Bo:\nNo listening to music\nBetter to delay shehechiyanu\nNo construction\nNo weddings\nNo purchasing new clothing (unless there is great need ex: a sale)\nNo consumption of meat or wine\nNo wearing brand new clothing\nNo taking haircuts or shaving (Men Only)\nNo swimming (with hot water)\nNo showering (with hot water)\nNo laundry\nNo wearing freshly laundered clothing (excludes undergarments)\n"
            }
        case .birkatHachamah, .birkatHachmahZman:
            if Locale.isHebrewLocale() {
                return "ברכת החמה נאמרת היום! זהו אירוע המתרחש פעם אחת בכל 28 שנה, ואדם צריך להיות זהיר כדי לברך על השמש בשעות הראשונות של הבוקר ביום זה. לפי רוב הפוסקים, אפשר לברך על השמש כל יום, אך רב עובדיה יוסף זצ\"ל כותב בחזון עובדיה ברכות כי אדם צריך לנסות לברך על השמש עד לפחות 3 שעות זמניות לאחר תחילת היום. אם הזמן הזה עובר, הוא צריך לברך על השמש בלי שם השם. לכן, מנהג עם ישראל הוא להתעורר בבוקר מוקדם ולהתפלל בנץ ביום זה, ולאחר העמידה (קדיש תתקבל), הם יוצאים החוצה כדי לברך על השמש."
            }
            return "Birkat HaChamah is said today! This occurs once every 28 years, and a person should be careful to say the beracha on the sun early in the morning on this day.\n\nAccording to many poskim, you can say the beracha on the sun all day, however, Rabbi Ovadiah Yosef ZT\"L writes in Chazon Ovadiah Berachot that a person should try to say the beracha before 3 zmaniyot hours into the day. If this time passes, he should say the beracha without hashem's name.\n\nTherefore, the minhag of Am Yisrael is to wake up early and pray at Netz on this day and after the Amidah (Kadish Titkabal), they go outside to say the beracha."
        case .birchatHalevana:
            if Locale.isHebrewLocale() {
                return "ברכת הלבנה, המכונה גם קידוש לבנה, היא ברכה שאנו אומרים פעם בחודש על הירח כמה ימים לאחר שהוא מגיע למצבו החדש. (שולחן ערוך אורח חיים סימן תכו)\n\nמומלץ לומר ברכה זו עם מנין במוצאי שבת עם חליפה נאה. (מעם לועז בראשית א:יד)\n\nזמן הברכה מתחיל 3 ימים לאחר המולד (חודש החדש), אך הרב עובדיה יוסף זצ\"ל (וספרדים בכלל) ממליצים להמתין עד 7 ימים לאחר המולד לברך. זמן זה מסתיים ביום ה-15 בכל חודש עברי לפי הרב עובדיה יוסף. (הליכות עולם חלק ה אות ט\"ז)"
            } else {
                return "Birkat Halevana, also known as Kiddush Levana and \"The blessing for the new moon\", is a beracha we say once a month on the moon a few days after it reaches it's new waxing phase. (שולחן ערוך אורח חיים סימן תכו)\n\nIt is ideal to say this blessing with a minyan on Saturday night with a nice suit on. (מעם לועז בראשית א:יד)\n\nThe time period for this blessing starts from 3 days after the Molad (new moon), however, Rabbi Ovadiah Yosef ZT\"L (and sephardim in general) recommend to wait until 7 days after the molad to make the beracha. This time period ends on the 15th of every hebrew month according to Rabbi Ovadiah Yosef. (הליכות עולם חלק ה אות ט\"ז)"
            }
        case .shmitaYear:
            if Locale.isHebrewLocale() {
                return "במהלך מחזור שש השנים שלפני השמיטה, יש חובה להפריש ולתת חלקים מגידולי השדה שלכם - תבואה, פירות וירקות שגודלו בארץ ישראל - למטרות שונות (במדבר י\"ח). מפרישים תרומה גדולה, מעשר ראשון ותרומת מעשר בכל שנה, אך מעשר שני מוחלף במעשר עני בשנה השלישית והשישית (דברים י\"ד:כ\"ח)."
                
            }
            return "During the six-year cycle prior to Shemita, there is an obligation to separate and gift portions of your field's grains, fruits, and vegetables grown in Israel to various causes (Bamidbar 18). We separate Terumah Gedolah, Maaser Rishon, and Terumat Maaser every year, however, Maaser Sheni is replaced with Maaser Ani on the 3rd and 6th years (Devarim 14:28)."
        case .dayOfOmer:
            if Locale.isHebrewLocale() {
                return "בכל לילה בעומר אנו אומרים ברכה על עשיית מצוה ואז אומרים את הספירה המובילה אותנו מפסח לשבועות, מקציר השעורה לקציר החיטה ובסופו של דבר, למנחה הראשונה בשבועות עצמו של חיטה מהקציר החדש, בצורת 12 לחמים. בזמן ספירת העומר היו מכניסים שעורה מכל שבוע לבית המקדש ומנופפים כמנחה, ממש כתפילה שהקציר יגיע בהצלחה.\n\nכל יום בין תחילת פסח לשבועות נספר, 49 ימים בסך הכל, 7 שבועות של שבעה ימים. זה הופך את תקופת העומר לגרסה מיניאטורית של מחזור שמיטה ויובל (יובל) של 7 מחזורים של שבע שנים.\n\nספירת העומר מתבצעת החל ממוצאי כל יום - כאשר הספירה מתרחשת בלילה הברכה מברכת וכאשר הספירה מתרחשת בשעות היום, הברכה אינה נאמרת. לאחר הברכה סופרים את היום לפי המספר המוחלט ולפי מספרו בתוך כל שבוע, כלומר, \"היום הוא יום השלושים ושלושה לעומר, שהוא ארבעה שבועות וחמישה ימים\" - זה ל\"ג בעומר.\n\nהאתגר הגדול ביותר של ספירת העומר הוא שישנם פוסקים (בה\"ג) שגורסים שמדובר במצווה אחת ארוכה שנמשכת 49 יום, בעוד שאחרים (רמב\"ם) גורסים שכל יום הוא מצווה נפרדת. אף על פי שהשולחן ערוך אומר שעדיין אפשר לספור (בלי הברכה) אם הולכים לילה ויום שלם בלי ספירה, המנהג הוא לא לומר יותר את הברכה בגלל ספק ברכות להקל."
            }
            return "Every night during the Omer we say a blessing for doing a mitzvah and then say the count which leads us from Passover to Shavuot, from the barley harvest to the wheat harvest and, ultimately, to the first offering on Shavuot itself of wheat from the new harvest, in the form of 12 loaves. During the time the Omer was counted, barley from each week would be brought into the Temple and waved as an offering, really as a prayer that the harvest would come in successfully.\n\nEach day between the beginning of Passover and Shavuot gets counted, 49 days in all, 7 weeks of seven days. That makes the Omer period a miniature version of the Shmitah and Yovel (Jubilee) cycle of 7 cycles of seven years.\n\nThe Omer count is made starting the evening of each day – when the count happens at night the blessing is said and when the count happens during the daytime the blessing is not said. After the blessing the day is counted by absolute number and by its number within each week, i.e., “Today is the thirty-third day of the Omer, which is four weeks and five days” – that’s Lag Ba’omer (lamed plus gimel, ל + ג = 33).\n\nThe biggest challenge of counting the Omer is that there are some poskim (Baha\"g) that hold that it is one long mitzvah lasting 49 days, while others (Rambam) hold that each day is a separate mitzvah. Even though the Shulchan Aruch holds that each day is a separate mitzvah, the practice is if you go one whole night and day without counting you no longer say the blessing because of Safek Berachot LeHakel."
        case .jewishMonth:
            return monthMessage()
        default:
            return ""
        }
    }
    
    func monthTitle() -> String {
        switch jewishMonth {
        case JewishCalendar.NISSAN: return "Nissan - ניסן"
        case JewishCalendar.IYAR: return "Iyar - אייר"
        case JewishCalendar.SIVAN: return "Sivan - סיוון"
        case JewishCalendar.TAMMUZ: return "Tammuz - תמוז"
        case JewishCalendar.AV: return "Av - אב"
        case JewishCalendar.ELUL: return "Elul - אלול"
        case JewishCalendar.TISHREI: return "Tishrei - תשרי"
        case JewishCalendar.CHESHVAN: return "Ḥeshvan - חשוון"
        case JewishCalendar.KISLEV: return "Kislev - כסלו"
        case JewishCalendar.TEVES: return "Tevet - טבת"
        case JewishCalendar.SHEVAT: return "Shevat - שבט"
        case JewishCalendar.ADAR: return "Adar - אדר"
        case JewishCalendar.ADAR_II: return "Adar II - אדר ב׳"
        default: return ""
        }
    }

    private func monthMessage() -> String {
        let isHebrew = Locale.isHebrewLocale()
        switch jewishMonth {
        case JewishCalendar.NISSAN:
            if isHebrew {
                return """
                    הַחֹ֧דֶשׁ הַזֶּ֛ה לָכֶ֖ם רֹ֣אשׁ חֳדָשִׁ֑ים רִאשׁ֥וֹן הוּא֙ לָכֶ֔ם לְחָדְשֵׁ֖י הַשָּׁנָֽה:
                    (שמות י"ב:ב')

                    ניסן מציין את גאולת האומה ואת הגאולה השלמה העתידית (ראש השנה בבלי י"א ע"ב). חודש זה ידוע כראשון בלוח השנה היהודי, וכתחילת עונת האביב, ומכאן שמו התנכ"י 'חודש האביב'. שני הרעיונות הללו מתמזגים בשורש האכדי של חודש זה – Nisānu, ה[תבואה] הראשונה. שנות מלכות נמנו גם הן מחודש זה.

                    ב-10 בניסן (שחל בשבת), הצטוו היהודים לקשור שה למיטתם, ואז לשחוט אותו ולמרוח את דמו על משקופי הדלתות ב-14 בחודש. באותו הלילה הכה ה' בבכורות מצרים, ופרעה - בכור בעצמו - שילח את היהודים. שלושה ימים לתוך המדבר, הם שבו על עקבותיהם לכיוון מצרים, ופרעה יצא ללכדם בשפת הים ב-21 בחודש. ה' נשב ברוח עזה כדי לקרוע את הים, אפשר ליהודים לחצות, והטביע את המצרים. אירועים אלו מצוינים על ידי שבת הגדול ופסח.

                    המעבר מיציאת מצרים ו-40 שנות הנדודים במדבר לווה בהנהגתו של יהושע, החל מ-30 יום לאחר מות משה רבנו בחודש הקודם. הוא שלח שני מרגלים ליריחו ב-7 בניסן, ולאחר מכן נכנס לארץ ב-10 בחודש.
                    """
            } else {
                return """
                    הַחֹ֧דֶשׁ הַזֶּ֛ה לָכֶ֖ם רֹ֣אשׁ חֳדָשִׁ֑ים רִאשׁ֥וֹן הוּא֙ לָכֶ֔ם לְחָדְשֵׁ֖י הַשָּׁנָֽה:
                    This month shall be to you the head of the months; to you it shall be the first of the months of the year.
                    Exodus 12:2

                    Nisan marks the nation's redemption and the future final redemption (Rosh Hashana Bavli 11b). This month is known as the first of the Jewish calendar, and the start of the spring season, hence its Tanakh name of חודש האביב. Both of these ideas are merged in the Akkadian root word for this month - Nisānu, the first [produce]. Royal reigns are also dated from this month.

                    On the 10th of Nisan (a שבת), the Jews were commanded to tie a lamb to their bedpost, then slaughter it and paint its blood on the doorposts on the 14th. That night God struck Egypt's firstborn, and Pharaoh - himself a firstborn - sent the Jews out. Three days into the desert, they turned back toward Egypt, and Pharaoh moved to recapture them at the sea on the 21st. God blew a great wind to split the sea, letting the Jews cross and drowning the Egyptians. These events are marked by Shabbat HaGadol and פסח (Passover).

                    Transitioning from the Exodus and 40 years of desert wandering was the leadership of יהושע, starting 30 days after the death of Moshe Rabbenu in the previous month. He sent two spies to יריחו on the 7th of Nisan, and then followed into the land on the 10th.
                    """
            }
        case JewishCalendar.IYAR:
            if isHebrew {
                return """
                    חודש אייר מגיע לאחר חודש ניסן הקודם לו, ומזוהה באופן מסורתי עם פריחה. בסיס לכך נמצא בשמו האכדי, ajjāru, שפירושו 'פרח' או 'שושנה', כמו גם בשמו המקראי 'זיו', שמשמעותו 'חודש הפריחה'.

                    חודש זה מוכר גם בשל ההזנה וההזדמנות שבו – בשנה השנייה לנדודים במדבר, ה-14 בחודש זה נקבע כדי לתת ליהודים הזדמנות נוספת להקריב את קרבן הפסח (פסח שני) אם נבצר מהם בחודש הקודם. ההזנה סופקה בדמות המן, שירד לאחר שהיהודים התלוננו על המחסור במזון ב-15 באייר. ייתכן שיש לנו מעין רמז להזנה זו בחודש זה, שכן תבואת השנה שעברה הופכת ל'ישן' ב-16 בניסן, מה שמותיר עודף של תבואה להנות ממנו במשך חודשים (כאשר אייר הוא החודש המלא הראשון של תבואת הישן).

                    מבחינה היסטורית, אנו יודעים גם שחודש זה אחראי לתחילת בנייתו של הבית הראשון על ידי שלמה המלך.
                    """
            } else {
                return """
                    The month of Iyar follows the previous month of Nisan, and is traditionally associated with blossoming. This has its basis in its Akkadian name, ajjāru, which refers to a 'blossom' or 'rosette', as well as its biblical name Ziv, meaning 'month of bloom'.

                    This month may be known also for its sustenance and opportunity – in the second year of wandering the desert, the 14th of this month was designated to give Jews another opportunity to offer the Korban Pesaḥ if they couldn't the month before. The sustenance provided came in the form of the Manna, which fell after the Jews complained about the lack of food on the 15th of Iyar. Perhaps we have somewhat of a hint of said substance this month, as the previous year's grain becomes Yashan on the 16th of Nissan, leaving a surplus of grain for months to benefit from (with Iyar being the first full month of the Yashan grain).

                    Historically, we also know that this month is responsible for the beginning of Shelomo Ha'Melekh's construction of the first Bet HaMikdash.
                    """
            }
        case JewishCalendar.SIVAN:
            if isHebrew {
                return """
                    סיוון משמעותו *עונה* (מהאכדית simānu) — עונת הקציר. הדבר מתבטא לא בחודש עצמו, אלא בחג השבועות, כפי שמתואר בתנ"ך. ההבחנה בין החודש לבין החג נובעת מכך שלחג אין תאריך קבוע, אלא הוא נחגג לאחר ספירה של 50 יום מפסח דרך ספירת העומר. במקור, זה הותיר את התאריך גמיש בין ה-5 ל-7 בסיוון (על פי קידוש החודש בראיית עדים) - אך עם לוח השנה של הלל, התאריך קבוע כעת ל-6 בסיוון.

                    סיוון קשור לאירועי מפתח מיציאת מצרים. ב-7 בסיוון, משה בן השלושה חודשים הונח ביאור על ידי הוריו ונמצא על ידי בתיה. בדיוק 80 שנה מאוחר יותר, באותו התאריך, ניתנה התורה בהר סיני (לאחר שהגיעו לשם ב-1 בסיוון). יש לציין כי זה שונה מהתאריך שבו אנו חוגגים את שבועות — עובדה מפתיעה, שכן רוב הליטורגיה המודרנית ממקדת את שבועות במתן תורה (שינוי מתקופת שלאחר חורבן הבית). הפער מוסבר על ידי שינוי באופן ספירת הימים: לפני מתן תורה, הימים החלו בזריחה (והלילה השתייך ליום הקודם). עם זאת, מרגע שהיהודים קיבלו את התורה, אנו מתחילים כעת את היום בשקיעה/צאת הכוכבים. בשימוש בשתי שיטות הספירה בהתאמה לתקופתן, אנו מבינים כעת כיצד אותה ספירה של 50 יום מקבילה לתאריכים שונים בלוח השנה, מה שמביא לכך שאותו אירוע של מתן תורה נחגג בתאריך שונה מזה שבו חישבו אותו אז.
                    """
            } else {
                return """
                    Sivan means *season* (from Akkadian *simānu*) — the season of harvest. This is shown not by the month itself, but by Shavu'ot, as described in Tanakh. The distinction between the month and the holiday comes from the holiday having no fixed date, instead following a 50-day count from פסח via the עומר. Originally, this left the date flexible between the 5th–7th of Sivan (calendar by witnesses) - with Hillel's calendar, though, this is now fixed for the 6th of Sivan.

                    Sivan is tied to key events from יציאת מצרים. On the 7th of Sivan, three-month-old Moshe was placed in the river by his parents and found by Batya. Exactly 80 years later, on that same date, the Torah was given at Har Sinai (having arrived there on the 1st of Sivan). Notably, this differs from the date we celebrate Shavuot — surprising, since most modern liturgy centers Shavuot on the giving of the Torah (a post-Temple shift). The gap is explained by a change in how days were counted: before the Torah, days began at sunrise (night belonging to the previous day). However, once the Jews accepted the Torah, we now start the day at sunset/nightfall. Using both counts respective to their era, we now see how the same 50 day count corresponds to different calendar days, placing the same event of מתן תורה to be celebrated on a different calendar day than the one they calculated back then.
                    """
            }
        case JewishCalendar.TAMMUZ:
            if isHebrew {
                return """
                    ארבעים יום לאחר מתן תורה, ירד משה רבנו מהר סיני עם הלוחות הראשונים, רק כדי לשבר אותם לעיני העם. בעודנו עדיין ללא הגאולה השלמה, אירוע זה מייצג את תמוז - הגלות והטרגדיה שבעקבות הגאולה של ניסן והאחריות החדשה של סיוון.

                    זה אירע ב-17 בתמוז (שבעה עשר בתמוז), וזהו רק אחד מחמישה אירועים שקרו ביום זה:

                    * ה'ערב רב' הרג את חור ואילץ את אהרון לבנות את עגל הזהב - חטא שאנו עדיין חשים בהשפעותיו עד היום. משה חזר ושיבר את הלוחות.
                    * אפוסטומוס שרף את התורה.
                    * צלם הועמד בהיכל.
                    * בוטל התמיד במהלך המצור הבבלי, 586 לפנה"ס (עקב טומאת הכהנים שלחמו בפולשים או בשל מחסור בכבשים).
                    * הובקעה העיר (חומות ירושלים נפרצו על ידי הרומאים), 69 לספירה.
                    פריצת החומות בתקופת הבית הראשון אירעה גם היא בתמוז, אם כי קיימת מחלוקת אם התרחשה ב-9 או ב-17 בחודש (תלמוד ירושלמי).

                    בכך מתחילים ימי 'בין המצרים', שלושת השבועות המובילים ל-9 באב, המאופיינים בהפטרות המנבאות את החורבן המתקרב של אותו דור.
                    """
            } else {
                return """
                    Forty days after Matan Torah, Moshe Rabbenu descended Har Sinai with the first tablets, only to shatter them before the nation. While we're still without the ultimate redemption, this event represents Tammuz - the exile and tragedy following the redemption of Nisan and the new responsibility of Sivan.

                    This occurred on the 17th of Tammuz, and is only one of five events that befell on this day:

                    * The 'Erev Rav killed Ḥur and made Aharon build the Golden Calf - a sin we still feel the effects of to this day. Moshe returned to shatter the tablets.
                    * Apostomos burned the Torah.
                    * An idol was placed in the Temple.
                    * Daily sacrifices ceased during the Babylonian siege, 586 BCE (due to either the impurity of Kohanim who fought the intrusion or the lack of sheep).
                    * Jerusalem's walls were breached by the Romans, 69 CE.
                    A First Temple-era breach also occurred in Tammuz, though whether on the 9th or 17th is disputed (Talmud Yerushalmi).

                    This begins בין המצרים, the Three Weeks leading to the 9th of Av, marked by Haftarot foretelling that generation's coming doom.
                    """
            }
        case JewishCalendar.AV:
            if isHebrew {
                return """
                    מִשֶּׁנִּכְנַס אָב, מְמַעֲטִין בְּשִׂמְחָה
                    (משנה תענית ד':ו')

                    חודש אב עובר מיומו ה-9 אל יומו ה-15 - הניגוד בין העצוב ביותר לשמח ביותר, המופרדים על ידי 6 ימים בלבד (ואולי אפילו רק 5).

                    המדרשים מסבירים כי בשל כך שהיהודים "בכו בכייה של חינם" בתשעה באב הראשון, ה' יספק להם סיבות לבכי לדורות הבאים. ואכן, הרשימה שלהלן כוללת רק את האירועים המפורטים במשנה, אך הרשימה המלאה המגיעה עד ימינו תהיה ארוכה מדי (וכואבת מדי):

                    * העם היהודי בכה על הכניסה לארץ ישראל, כאשר המרגלים חזרו עם דיווח שלילי (הוצאת דיבת הארץ). ה' גזר שאותו דור ימות במדבר במהלך 40 שנות הנדודים.
                    * שני בתי המקדש חרבו, על ידי הבבלים והרומאים בהתאמה. לגבי הבית הראשון בפרט, השריפה נמשכה אל תוך ה-10 בחודש.
                    * מרד בר כוכבא נגד הרומאים בשנת 133 לספירה הסתיים בתבוסה: ביתר, מעוז יהודי חשוב במהלך המרד, נפלה לידי הרומאים ותושביה היהודים נטבחו. שנה לאחר מכן, הרומאים חרשו את ירושלים, והרסו את התקוות לבנייתה מחדש [עבור אותו דור].
                    """
            } else {
                return """
                    מִשֶּׁנִּכְנַס אָב, מְמַעֲטִין בְּשִׂמְחָה
                    When [the month of] Av begins, one diminishes rejoicing.
                    Mishna Ta'anit 4:6

                    The month of Av transitions from its 9th day to its 15th - the contrast between the saddest and happiest, separated only by 6 days (maybe even just 5).

                    The Midrashim explain that due to the Jews "crying for no reason" on the 1st תשעה באב, God will provide reasons of mourning for years to come. Indeed, this list below includes only events listed in the Mishna, but the full list that extends to our day would be too long (and too painful):

                    * The Jewish nation wept over entering the land of Israel, when the spies came back with the negative testimony. God decreed that the generation will die in the desert throughout its 40-year wandering.
                    * Both Temples were destroyed, by the Babylonians and Romans respectively. For the first Temple specifically, the burning extended into the 10th.
                    * The Bar Kochba revolt against the Romans in 133 CE ended in defeat: Betar, an important Jewish stronghold during the Bar-Kochba revolt fell to the Romans, leaving its Jewish residents butchered. One year afterward, the Romans plowed over Jerusalem, destroying hopes of its rebuilding [for that generation].
                    """
            }
        case JewishCalendar.ELUL:
            if isHebrew {
                return """
                    לאחר 40 יום של תחנונים לסליחה עבור האומה היהודית, ה' מצווה על משה לשוב להר סיני כדי לקבל את הלוחות השניים. זהו הלך הרוח של חודש אלול - העונה להיות מודעים לכל ההזדמנויות שה' העניק לנו לאורך השנה, ולהתכונן לרחמים.

                    איקונוגרפיה זו, מעצם הגדרתה, שונה בין הקהילות הספרדיות והאשכנזיות. מנהגנו הוא לומר סליחות החל ממוצאי ראש חודש. האיקונוגרפיה אצל האשכנזים עושה שימוש בשופר (השמור בדרך כלל לראש השנה) לאורך כל החודש (למעט ערב ראש השנה). ישנה חפיפה בין השניים; מיעוט של קהילות ספרדיות תוקעות בשופר במהלך אמירת י"ג מידות, ואילו האשכנזים מאמצים את מנהג הסליחות בסוף החודש.

                    ה-25 בחודש משמעותי משתי סיבות היסטוריות:

                    * בהנחה שהעולם *לא* נברא בניסן, ראש השנה נקרא כך משום שזהו היום בו נברא האדם. מכיוון שזה קרה ביום השישי לבריאה, הפחתת 6 ימים נופלת על יום זה (כ"ה באלול), בו ה' התחיל לתת לכל פרט בעולם את צורתו.
                    * זהו היום שבו נחמיה סיים את בניית חומות ירושלים מחדש לאחר חורבנן המקורי.
                    """
            } else {
                return """
                    After 40 days of pleading for the Jewish nation to be forgiven, Hashem commands Moshe to return to Har Sinai to receive the second tablets. This is the mindset of the month of Elul - the season to be aware of all the chances God gave us throughout the year and prepare for mercy.

                    This iconography, by definition, differs between the Sephardic and Ashkenazi communities. Our custom is to recite the סליחות services, starting from after ראש חודש. The iconography by Ashkenazim utilizes the שופר (usually reserved for ראש השנה) throughout the entire month (except the eve of ראש השנה). There is overlap between the two; a minority of Sephardic congregations blow the שופר during the recital of the 13 attributes, whereas Ashkenazim eventually adopt the custom of סליחות at the end of the month.

                    The 25th of the month is significant for two historical reasons:

                    * Assuming the world was *not* created in Nisan, ראש השנה is called as such because it was the day man was created. Since that occurred on the 6th day of creation, subtracting 6 days falls on this day, when God started to give each item of the world its form.
                    * It's the day Neḥemiah finished rebuilding the walls of Jerusalem after its original destruction.
                    """
            }
        case JewishCalendar.TISHREI:
            if isHebrew {
                return """
                    בֶּחֳדָשִׁים הַשְּׁבִיעִי חָבִיב, "בַחֹדֶשׁ הַשְּׁבִיעִי בְּאֶחָד לַחֹדֶשׁ"
                    (מתוך חודשי השנה, השביעי הוא החביב; "בחודש השביעי באחד לחודש")
                    (ילקוט שמעוני, פרשת יתרו רע"ו)

                    תשרי הוא החודש הפותח מחזורים יהודיים שונים, כולל שמיטה, נדרים, נטיעה (לעורלה) וצמחייה (מעשרות ותרומות). לפי ר' אליעזר, העולם (כפי שנקבע על ידי האנושות) נברא בחודש זה – או לכל הפחות, הבריאה כמושג התרחשה אצל ה' במהלך חודש זה (ראה רבנו תם על ראש השנה כ"ז ע"א; בשילוב עם יישובו של ריש לקיש במסכת חגיגה י"ב ע"א, רש"י על בראשית א':א', ובראשית רבה י"ב:ד' להסבר מלא). השם עצמו מחזק מעמד זה כנקודת התחלה – הוא נגזר מהמילה האכדית tašrītu (תשריתו), שפירושה המילולי הוא 'התחלה', מהשורש šurrū (להתחיל, לפתוח או ליזום).

                    נושא החגים של החודש הוא דין, תשובה, וההכרה בכך שה' הוא מלכנו. החגים הפותחים את החודש הם ראש השנה ויום כיפור, כאשר עשרת ימי תשובה משמשים כמסגרת המקיפה אותם – תוך התמקדות בדין שלנו. לאחר מכן אנו עוברים לסוכות ולדין על הגשם, נושא המשתקף כבר בשמו המקורי של החודש (איתנים - ראה מלכים א' ח':ב'). כל זה מגיע לשיאו בשמיני עצרת, לו הענקנו משמעות נוספת של סיום מחזור קריאת התורה.
                    """
            } else {
                return """
                    בֶּחֳדָשִׁים הַשְּׁבִיעִי חָבִיב, "בַחֹדֶשׁ הַשְּׁבִיעִי בְּאֶחָד לַחֹדֶשׁ"
                    Of the months, the seventh is the beloved; "In the seventh month, on the first day"
                    (Yalkut Shimoni, Parashat Yitro 276)

                    Tishri is the month that starts various Jewish cycles, including Shemita, Nedarim (vows), Neti'a (for Orlah) and vegetation (tithes and terumot). According to R' Eliezer, the world (determined by mankind) was created in this month – or at the very least, creation as a concept occurred for God during this month (see Rabbenu Tam on Rosh Hashanah 27a; combine with the resolution of Resh Lakish on Chagigah 12a, Rashi on Bereshit 1:1, and Bereshit Rabba 12:4 for a complete explanation). The name itself reinforces this status as a starting point – it's derived from the Akkadian word tašrītu, which literally means 'beginning' from the root šurrū (to begin, open, or initiate).

                    The theme of the month's holidays are judgement, repentance and the acknowledgement that God is our king. The holidays that start the month are Rosh Hashana and Yom Kippur, with the 10 Days of Repentance as the enclosure – focusing on our judgement. Then we move to Sukkot and the judgement of the rain, a theme reflected as early as the month's initial name (איתנים - see Kings I 8:2). This all culminates in Shemini Atzeret, which we've multipurposed with the completion of the Torah cycle.
                    """
            }
        case JewishCalendar.CHESHVAN:
            if isHebrew {
                return """
                    בתנ"ך (מלכים א' ו':ל"ח), חודש זה נקרא 'ירח בול', שם ששורשיו בשינויים עונתיים כגון נבילת העשב (בלה), ערבוב המספוא (בולילין), ואיסוף התוצרת (יבול). השם קשור גם לתחילת הגשמים — יצירת גושי אדמה (בולות) ותזכורת למבול — מה שמשקף את המנהג הנוכחי בארץ ישראל לבקש גשם (ברך עלינו) החל מה-7 בחודש, עם תעניות היסטוריות שהתקיימו אם לא ירד גשם עד ה-17 בחודש.

                    השם מרחשוון (שלרוב מקוצר לחשוון) מציין דווקא את סדרו המספרי של החודש, ונגזר מהאכדית warḫu samnu ("החודש השמיני"). מבחינה לשונית, warḫu מקביל לעברית 'ירח' ו-samnu קשור ל'שמונה'. בעוד שהקידומת 'מר' מפורשת לעיתים קרובות כ"מרירות" בשל היעדר החגים בחודש זה, משמעותה היא גם "טיפה" (כפי שמופיע בישעיהו מ':ט"ו), מה שמציין את בואם המבורך של גשמי הסתיו. בניגוד מוחלט לכך, הפירוש הארמי לקידומת "מר" הוא "אדון", המייצג את בניית הבית הראשון (למרות העיכוב המריר בחנוכתו) והתגמול העתידי של חגיגות שטרם באו.
                    """
            } else {
                return """
                    In the Tanakh (I Kings 6:38), this month is referred to as Yeraḥ Bul, a name rooted in seasonal shifts such as the withering of grass (baleh), the mixing of fodder (bolelin), and the harvesting of produce (yevul). The name is also associated with the onset of rain—forming clods of earth (bolot) and recalling the Great Flood (mabul)—which mirrors the current practice in Israel of requesting rain beginning on the 7th of the month (ברך עלינו), with historical fasts held if none fell by the 17th.

                    The name Marḥeshvan (often shortened to Ḥeshvan) instead denotes the month's numerical order, deriving from the Akkadian warḫu samnu ("eighth month"). Linguistically, warḫu corresponds to the Hebrew yerach (month) and samnu relates to shemonah (eight). While the prefix Mar is often interpreted as "bitter" due to the month's lack of festivals, it also means "drop," (such as its use in Isaiah 40:15) signifying the welcome arrival of the autumn rains. As a complete contrast, the Aramaic definition behind the prefix "Mar" is "master", representing the construction of the first Bet HaMikdash (despite its bitterful delay of the dedication) and the eventual repayment of future celebrations.
                    """
            }
        case JewishCalendar.KISLEV:
            if isHebrew {
                return """
                    חודש כסלו ידוע בעיקר בזכות האירועים שהתרחשו בו, אשר נחגגים כיום כחג החנוכה. למרות שהסיפור השלם השתרע על פני מספר שנים, אירועי המפתח התרחשו בחודש זה.

                    ב-15 בכסלו ג'תקצ"ד / 167 לפנה"ס, הוצב "שיקוץ משומם" על המזבח ופסלים רבים הועמדו ברחובות יהודה.

                    ב-25 בכסלו ג'תקצ"ד / 167 לפנה"ס, הוקרבו קורבנות עבודה זרה על המזבח.

                    שלוש שנים מאוחר יותר, ב-25 בכסלו ג'תקצ"ז / 164 לפנה"ס, הצליחו הכהנים לחדש את עבודתם. פך השמן היחיד שנמצא חתום שימש להדלקת הנרות בשמונת הימים הבאים.

                    בתנ"ך, חודש זה מוכר יותר בשל נבואותיו של חגי. דרך ההבטחות לשגשוג ולניצחון על האויבים בימיו, העם עורר לבנות מחדש את בית המקדש. הדבר אירע ב-24 בכסלו, ג'ר"מ / 520 לפנה"ס (חגי ב':י'). אירוע נוסף במאה שלאחר מכן (ב-20 בכסלו ג'תי"ד / 347 לפנה"ס) היה האסיפה בת שלושת הימים של עזרא כדי לדבוק בתורה ולהתיר את נישואי התערובת (ראה עזרא י':ט').
                    """
            } else {
                return """
                    The month of Kislev is mostly known for the events that took place in this month, later being celebrated in the form of Ḥanoukka. Although the entire story spanned several years, the milestone events were performed in this month.

                    On the 15th of Kislev 3594/167 BCE, the "abomination of desolation" was set on the mizbeakh and multiple idols were set in the streets of Judea.

                    On the 25th of Kislev 3594/167 BCE, idolatrous sacrifices were offered on the mizbeakh.

                    Three years later, on the 25th of Kislev 3597/164 BCE, the Kohanim were able to resume their service. The only sealed oil jug found was used to light the candles for the following eight days.

                    In Tanakh, this month is better known for the prophecies of Ḥaggai. Through the promises of prosperity and victory over its enemies in its days, they were encouraged to rebuild the Temple. This occurred on the 24th of Kislev, 3240/520 BCE (Ḥaggai 2:10). Another event in the following century (on the 20th of Kislev, 3414/347 BCE) was 'Ezra's three-day gathering to adhere to the Torah and to dissolve their interfaith marriages (see Ezra 10:9)
                    """
            }
        case JewishCalendar.TEVES:
            if isHebrew {
                return """
                    לאחר סיום חג החנוכה, חודש טבת עובר לייצג יותר את מיקומו בעונת החורף בלוח השנה. יש שהכריזו על החורף החל מחצי חודש קודם לכן - ויש שאף חודש שלם קודם לכן. (ראה בבא מציעא ק"ו ע"ב להבהרה בנושא זה, מתוך מחזור שש העונות של השנה). עם זאת, הכל מסכימים שטבת הוא זמן החורף, עד כדי כך שהמקבילה ההלכתית לנקודת ההיפוך החורפית נקראת 'תקופת טבת'.

                    בחצי הכדור הצפוני, ימי חודש זה קצרים משמעותית מבכל עונה אחרת, וייתכן שזה נרמז בשם החודש. השם טבת מגיע מהאכדית ṭebētu, שפירושו "שקוע". ניתן להבין "שקוע" זה כהתייחסות למיקומה של השמש מתחת לאופק, מחוץ לטווח הזריחה/שקיעה.

                    בתוך החודש עצמו, הימים ח'-י' בו מוכרים בשל הטרגדיות שאירעו בהם – תרגום התורה ליוונית, פטירתו של עזרא (ועמה המנהיגות שייצג), והמצור על ירושלים. עם זאת, בחודש זה עצמו, עשרות שנים לאחר מכן, התרחשה עלייתה של אסתר המלכה (מגילת אסתר ב':ט"ז), המייצגת את סיפור הפורים ואת הגאולה שבאה בעקבותיו.
                    """
            } else {
                return """
                    After concluding the holiday of Ḥanoukka, the month of Tevet shifts more to representing its winter-season placement in the calendar. Some declared winter from half a month prior - some even a full month prior. (See Bava Metzia 106b for clarification on this subject, from its six-season cycle) However, all agree on Tevet being the winter time, to the point where the winter solstice's Halachic equivalent is called Tekufat Tevet.

                    In the Northern Hemisphere, this month's days are considerably shorter than any other season, and this might be hinted to in the month's name. Tevet comes from the Akkadian ṭebētu, which means "sunk". It is possible to read this "sunk" as referring to the position of the sun below the horizon outside of the sunrise/sunset range.

                    Within the month itself, the 8th-10th days of the month are known for the tragedies that befell – that being the translation of the Torah into Greek, the passing of Ezra (and with it, the leadership he represented), and the siege of Jerusalem. It was on this month, though, that decades later would feature the rise of Esther (Megillat Esther, 2:16), representing the Purim story and the redemption that followed suit.
                    """
            }
        case JewishCalendar.SHEVAT:
            if isHebrew {
                return """
                    שנשמע בשורות טובות

                    שבט אינו חודש בעל נוכחות רבה בתנ"ך, ושמו המקביל באכדית (šabāṭu) מתייחס לגשמים העזים המגיעים עם העונה הסולארית של חודש זה. עם זאת, תורתה של 'תורה שבעל פה' היא זו שמספקת תובנה ומשמעות לחודש זה.

                    המקור שלנו מהמשנה דן בכך שראש השנה לאילנות חל בחודש זה. מועד זה זכה לשם ט"ו בשבט, המייצג את התאריך בו מתקיים אירוע זה לפי בית הלל. (ראה משנה ראש השנה א':א' לדיון המלא, כולל דעת בית שמאי). מנהגים רבים התפתחו מכך: יש הנוהגים לערוך סעודה המתמקדת בפירות שונים, הנקראת 'סדר ט"ו בשבט'. אחרים מתמקדים בתפילות השונות שחוברו כדי לזכות באתרוג מהודר לחג הסוכות.

                    בחודש זה החל נאומו האחרון של משה רבנו, בו פנה לעם לפני שיהושע החליפו בהנהגה. תורות אלו נכתבו בסופו של דבר כ'ספר דברים', המכונה לעיתים קרובות 'משנה תורה'.
                    """
            } else {
                return """
                    שנשמע בשורות טובות

                    Shevat is not a month with much presence within Tanakh, and its Akkadian name-equivalent (šabāṭu) refers to the harsh rains that come with the solar season of this month. It is the teachings of תורה שבעל פה, however, that provide insight and meaning to the month.

                    Our source from the Mishna discusses how the new year of the trees falls on this month. This has been titled ט"ו בשבת, representing the calendar day this event takes place on according to Bet Hillel. (See Mishna Rosh HaShana 1:1 for the full discussion, including the opinion of Bet Shammai). Many customs have developed from here: some practice by partaking in a meal focused on the various fruits, called the סדר ט"ו בשבת. Others have focused on the various prayers composed to merit owning a good אתרוג for the holiday of סוכות.

                    This month started the final speech of Moshe Rabbenu, addressing the nation before Yehoshua replaced his leadership. These teachings would ultimately be written in the form of Sefer Devarim, often called Mishne Torah.
                    """
            }
        case JewishCalendar.ADAR_II:
            if isHebrew {
                return """
                    מִשֶּׁנִּכְנַס אֲדָר מַרְבִּין בְּשִׂמְחָה
                    (תענית בבלי, כ"ט ע"א)

                    אדר סובב סביב פורים, המציין את ביטול גזירתו של המן להשמיד את יהודי פרס. למרות שהאיום כבר נוטרל 11 חודשים קודם לכן, הגזירה נותרה בתוקפה, והיהודים נלחמו כדי להגן על עצמם - המלחמה ברחבי האימפריה ב-14 באדר, והקרב בשושן עצמה ב-15 בו.

                    אירועים אלו מתועדים במגילת אסתר. פורים חל ב-15 בחודש בערים מוקפות חומה כמו שושן, וב-14 בשאר המקומות. המנהגים כוללים קריאת מגילה, מתנות לאביונים, משלוח מנות וסעודת פורים (עם יין - יש לשתות מעט יותר מהרגיל ואז לישון; ראה בית יוסף תרצ"ה:ב'). תענית אסתר, יום צום שלפני כן, מנציחה את המלחמה עצמה.

                    באופן רחב יותר, אדר מציין ניצחונות על רדיפות מתקופות שני בתי המקדש: נבוכדנצר, מחריב הבית הראשון, מת ב-25 בחודש (רש"י, מלכים ב' כ"ה:כ"ז); וקרב חדשה מתקופת הבית השני מונצח כ"יום ניקנור" ב-13 בחודש (חשמונאים א' ז':כ"ו–נ').
                    """
            } else {
                return """
                    מִשֶּׁנִּכְנַס אֲדָר מַרְבִּין בְּשִׂמְחָה
                    When [the month of] Adar begins, one increases rejoicing.
                    Ta'anit Bavli, 29a

                    Adar centers on Purim, marking the overturning of Haman's decree to annihilate the Jews of Persia. Though the threat had already been neutralized 11 months earlier, the decree remained in force, and Jews fought to defend themselves - the empire-wide war on the 14th of Adar, and the battle in Shushan itself on the 15th.

                    These events are recorded in מגילת אסתר. Purim falls on the 15th in walled cities like Shushan, and the 14th elsewhere. Observance includes reading the Megillah, giving to the poor, sending food gifts, and a festive meal (with wine - drink a bit more than usual, then sleep; see B"Y 695:2). תענית אסתר, a fast day beforehand, commemorates the war itself.

                    More broadly, Adar marks victories over persecutions from both Temple eras: Nevukhadnetzar, destroyer of the first Temple, died on the 25th (Rashi, II Kings 25:27); and the second-Temple-era Battle of Adasa is commemorated as יום נקנור on the 13th (1 Maccabees 7:26–50).
                    """
            }
        case JewishCalendar.ADAR:
            if isHebrew {
                return """
                    חודשי השנה נקבעים על פי מחזור הירח, שקצר ב-11 ימים מלוח השנה השמשי. חוסר סנכרון זה גורם לבעיה עבור החגים היהודיים, שיש להם מיקומים עונתיים למרות שהתאריך שלהם נקבע לפי החודש הירחי. לפיכך, אנו מוסיפים את חודש אדר א' ללוח הירחי – עם מחזור לוח השנה של הלל שנוצר בשנת 358–359 לספירה, קביעת חודש זה כבר לא הייתה תלויה בשיקולים חקלאיים וחישובים אסטרונומיים (שדרשו סנהדרין), אלא הפכה לחלוקה קבועה של שבע שנים מעוברות ושתיים-עשרה שנים "פשוטות", המהוות יחד מחזור של 19 שנים.

                    שמרנו את חודש אדר ב' עבור חג הפורים (כדי להסמיך את גאולת פורים לגאולת מצרים) ולקריאת ארבע פרשיות (התלויות בפורים). אף על פי כן, ה-14 וה-15 באדר א' זכו לתואר [שושן–]פורים קטן, ומצוינים על ידי הימנעות מתחנון, הספדים או צומות.

                    ההשלכות של חודש זה משפיעות על הילולות, נדרים, וימי הולדת (המשפיעים על הבגרות היהודית – סטטוס הבר מצווה). (ראה את הדיון בתלמוד ירושלמי, מגילה ז' ע"א–ז' ע"ב).
                    """
            } else {
                return """
                    The months of the year are determined by the lunar cycle, which falls short by 11 days from the solar calendar. This desync causes a problem for Jewish holidays, which have seasonal placements despite the date being ruled from the lunar month. Thus, we add the month of Adar I to the lunar calendar – with Hillel's calendar cycle originating in 358–9 CE, the institution of this month was no longer dependent on agricultural concerns and astronomical calculations (which required a Sanhedrin), instead just a division of seven leap years and twelve "ordinary" years, collectively becoming a nineteen-year cycle

                    We've kept the month of Adar II for the respective festival of Purim (to keep the redemption of Purim close to the redemption from Egypt) and the recital of the Arba Parashiot (which are dependent on Purim). Nevertheless, the 14th and 15th of Adar I were titled [Shushan–]Purim Katan, observed by refraining from Taḥanun, eulogies, or fasts.

                    The ramifications of this month affects Hiloulot, vows, and birthdays (affecting Jewish adulthood – the בר מצוה status). (See the discussion on Talmud Yerushalmi Megillah 7a–7b)
                    """
            }
        default:
            return ""
        }
    }
}
