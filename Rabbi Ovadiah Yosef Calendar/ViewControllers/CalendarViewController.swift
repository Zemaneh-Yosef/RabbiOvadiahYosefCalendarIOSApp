//
//  CalendarViewController.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 6/12/23.
//

import UIKit

class CalendarViewController: UIViewController {
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard

    @IBAction func info(_ sender: UIButton) {
        var longInfoMessage: String
        if Locale.isHebrewLocale() {
            longInfoMessage = "\n" +
            "האפליקציה יכולה להציג שני לוחות שנה נפרדים. בשנת 1990, רבי עובדיה יוסף זצ\"ל התחיל פרויקט ליצירת לוח זמנים על פי ההלכות והמנהגים שלו. יחד עם רבי שלמה בניזרי ורבי אשר דרשן, יצר לוח זמנים בשם \"לוח המאור אור החיים\". רבי עובדיה עצמו השגיח על יצירת הלוח והשתמש בו עד לפטירתו. האפליקציה עברה על כל זמני לוח אור החיים ואישרה את דיוקם.\n" +
            "\n" +
            "יש גם אפשרות להשתמש בלוח זמנים שנקרא \"עמודי הוראה\", הנוצר על ידי רבי ליאור דהן שליט\"א. רבי ליאור דהן הוא סופר ספר בשם \"עמודי הוראה\", וכיושב בארצות הברית, הוא יצר לוח זמנים על פי עמדתו של רבי עובדיה. לוחו דומה ללוח אור החיים עם הבדלים קטנים; בהתאם להלכה ברורה בסימן 261 הלכה 13, הוא מתאים את הדקות זמניות בהתאם לקווי הרוחב של המשתמש. לדוגמה, בישראל, עלות השחר הוא 72 דקות זמניות לפני הזריחה, אך בניו יורק יעמידו כ-80 דקות זמניות, ובצרפת זה יהיה יותר. כדאי לציין כי ילקוט יוסף אינו נראה נוטה להסכמה לחישובים אלה (ראה עין יצחק חלק 3 עמוד 230). כדאי גם לציין כי לוח עמודי הוראה מציג את פלג המנחה על פי ההלכה ברורה, וגם צאת הכוכבים לחומרה. צאת הכוכבים לחומרה משמש במקרים מסוימים, כמו למתי שהצום נגמר. שאלתי את רבי בניזרי למה אין מופיעה הזכרת זמן צאת הכוכבים לחומרה בלוח אור החיים, והוא ענה שהלוח פשוט אומר שהצום נגמרת בצאת הכוכבים והזמן יכול להתייחס לשני הזמנים.\n" +
            "\n" +
            "חשוב לציין כי שני הלוחות ישתמשו בקווי רוחב ואורך שאתה סופק כדי לחשב את זמני היום. ההבחנה בין שני הלוחות היא בגלל הדקות זמניות הנוספות המתווספות באזורים יותר צפוניים/דרומיים. לוח עמודי הוראה רק לשימוש מחוץ לישראל, אך יש רבנים שחוזרים גם על כך כי גם תוכניות החישוב של לוח אור החיים יכולות לשמש מחוץ לישראל. לכן, השארתי למשתמש לבחור איזה לוח הוא רוצה לעקוב אחרי. יש רבנים בשני הצדדים, אז יש לך על מה לסמוך בכל מקרה."
        } else {
            longInfoMessage = "This app has the capability to display two separate calendars. In 1990, Rabbi Ovadiah Yosef ZT\"L started a project to create a zmanim calendar according to his halachot and minhagim. Rabbi Ovadiah sat down with Rabbi Shlomo Benizri and Rabbi Asher Darshan and created a zmanim calendar called \"Luach HaMaor Ohr HaChaim\". Rabbi Ovadiah himself oversaw this calendar's creation and used it until he passed. This app has reverse engineered all the zmanim of the Ohr Hachaim calendar and confirmed that they are accurate.\n\nThere is also an option to use the Amudei Horaah calendar created by Rabbi Leeor Dahan Shlita. Rabbi Leeor Dahan is the author of the popular sefer \"Amudei Horaah\", and as he lives in America, he has set out to create his own calendar according to Rabbi Ovadiah's views. His calendar is similar to the Ohr HaChaim calendar with minor differences, based on the Halacha Berurah in Siman 261 Halacha 13, he adjusts the seasonal minutes based on the latitude of the user. For example, in Israel Alot/Dawn is 72 seasonal minutes before Sunrise, however, in New York, it would come out to around 80 seasonal minutes, and in France it would be even more. It should be noted that the Yalkut Yosef does not seem to agree to these calculations (See Eyin Yitzchak Chelek 3 Amud 230). It should also be noted that the Amudei Horaah calendar shows plag hamincha according to the Halacha Berurah as well as tzeit/nightfall l'chumra. Tzeit l'chumra is used in certain scenarios like for when a fast ends. I asked Rabbi Benizri why there was no mention of this stringent tzeit in the Ohr HaChaim calendar and he answered that the calendar just says that the fasts end at tzeit and it can refer to both times.\n\n Please note that both calendars will use the latitude and longitude you provide to calculate the zmanim. The difference between the two calendars is because of the additional seasonal minutes added in more northern/southern areas. The Amudei Horaah calendar is only to be used outside of Israel, however, many rabbanim also hold that the Ohr HaChaim calendar's calculations CAN be used outside of Israel as well. Therefore, I left it up to the user to choose which calendar they want to follow. There are rabbanim on both sides, so you have on what to rely on either way."
        }
        
        var alertController = UIAlertController(title: "Calendar Choice Page Explained".localized(), message: longInfoMessage, preferredStyle: .actionSheet)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: "Calendar Choice Page Explained".localized(), message: longInfoMessage, preferredStyle: .alert)
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss".localized(), style: .cancel) { (_) in }
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func amudeiHoraah(_ sender: UIButton) {
        defaults.setValue(true, forKey: "LuachAmudeiHoraah")
        dismissAllViews()
    }
    
    @IBOutlet weak var ohrHachaim: UIButton!
    @IBAction func ohrHachaim(_ sender: UIButton) {
        defaults.setValue(false, forKey: "LuachAmudeiHoraah")
        dismissAllViews()
    }
    @IBOutlet weak var amudeiHoraah: UIButton!
    @IBAction func skip(_ sender: UIButton) {
        dismissAllViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            ohrHachaim.configuration = .filled()
            ohrHachaim.configuration?.background.backgroundColor = .init(named: "Gold")
            ohrHachaim.setTitleColor(.black, for: .normal)
            
            amudeiHoraah.configuration = .filled()
            amudeiHoraah.configuration?.background.backgroundColor = .init(named: "Gold")
            amudeiHoraah.setTitleColor(.black, for: .normal)
        }
    }
    
    func dismissAllViews() {
        defaults.setValue(true, forKey: "isSetup")
        let inIsraelView = super.presentingViewController?.presentingViewController?.presentingViewController
        let zmanimLanguagesView = super.presentingViewController?.presentingViewController
        let getUserLocationView = super.presentingViewController
        
        super.dismiss(animated: false) {//when this view is dismissed, dismiss the superview as well
            if getUserLocationView != nil {
                getUserLocationView?.dismiss(animated: false)
                if zmanimLanguagesView != nil {
                    zmanimLanguagesView?.dismiss(animated: false) {
                        if inIsraelView != nil {
                            inIsraelView?.dismiss(animated: false)
                        }
                    }
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
