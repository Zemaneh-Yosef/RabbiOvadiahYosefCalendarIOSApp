//
//  ZmanimTimeNames.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 3/28/23.
//

import Foundation

struct ZmanimTimeNames {
    var mIsZmanimInHebrew: Bool
    var mIsZmanimEnglishTranslated: Bool
    var mIsZmanimAmericanized: Bool
    
    init(defaults: UserDefaults) {
        self.mIsZmanimInHebrew = defaults.bool(forKey: "isZmanimInHebrew")
        self.mIsZmanimEnglishTranslated = defaults.bool(forKey: "isZmanimEnglishTranslated")
        self.mIsZmanimAmericanized = defaults.bool(forKey: "isZmanimAmericanized")
    }
    
    func getYalkutYosefString() -> String {
        if (mIsZmanimInHebrew) {
            return "ילקוט יוסף"
        } else {
            return "Yalkut Yosef"
        }
    }
    
    func getHalachaBerurahString() -> String {
        if (mIsZmanimInHebrew) {
            return "הלכה ברורה"
        } else {
            return "Halacha Berura"
        }
    }
    
    func getAbbreviatedYalkutYosefString() -> String {
        if (mIsZmanimInHebrew) {
            return "י\"י"
        } else {
            return "Y\"Y"
        }
    }
    
    func getAbbreviatedHalachaBerurahString() -> String {
        if (mIsZmanimInHebrew) {
            return "ה\"ב"
        } else {
            return "H\"B"
        }
    }
    
    
    public func getChatzotLaylaString() -> String {
        if (mIsZmanimInHebrew) {
            return "חצות הלילה";
        } else if (mIsZmanimEnglishTranslated) {
            return "Midnight";
        } else if (mIsZmanimAmericanized) {
            return "Chatzot Ha'Layla";
        } else {
            return "Ḥatzot Ha'Layla";
        }
    }
    
    public func getLChumraString() -> String {
        if (mIsZmanimInHebrew) {
            return "לחומרא";
        } else if (mIsZmanimEnglishTranslated) {
            return "(Stringent)";
        } else if (mIsZmanimAmericanized) {
            return "L'Chumra";
        } else {
            return "L'Ḥumra";
        }
    }
    
    public func getTaanitString() -> String {
        if (mIsZmanimInHebrew) {
            return "תענית";
        } else {
            return "Fast";
        }
    }
    
    public func getStartsString() -> String {
        if (mIsZmanimInHebrew) {
            return " מתחיל";
        } else {
            return " Starts";
        }
    }
    
    public func getTzaitHacochavimString() -> String {
        if (mIsZmanimInHebrew) {
            return "צאת הכוכבים";
        } else if (mIsZmanimEnglishTranslated) {
            return "Nightfall";
        } else if (mIsZmanimAmericanized) {
            return "Tzet Ha'Kochavim";
        } else {
            return "Tzet Ha'Kokhavim";
        }
    }
    
    public func getSunsetString() -> String {
        if (mIsZmanimInHebrew) {
            return "שקיעה";
        } else if (mIsZmanimEnglishTranslated) {
            return "Sunset";
        } else if (mIsZmanimAmericanized) {
            return "Shekia";
        } else {
            return "Sheqi'a";
        }
    }
    
    public func getRTString() -> String {
        if (mIsZmanimInHebrew) {
            return "רבינו תם";
        } else {
            return "Rabbenu Tam";
        }
    }
    
    public func getRTType(isFixed: Bool) -> String {
        if (isFixed) {
            if (mIsZmanimInHebrew) {
                return " (קבוע)";
            } else {
                return " (Fixed)";
            }
        } else {
            if (mIsZmanimInHebrew) {
                return " (זמנית)";
            } else {
                return " (Seasonal)";
            }
        }
    }
    
    public func getMacharString() -> String {
        if (mIsZmanimInHebrew) {
            return " (מחר) ";
        } else {
            return " (Tom) ";
        }
    }
    
    public func getEndsString() -> String {
        if (!mIsZmanimInHebrew) {
            return " Ends";
        } else {
            return "";
        }
    }
    
    public func getTzaitString() -> String {
        if (mIsZmanimInHebrew) {
            return "צאת ";
        } else {
            return "";//if we are translating to English, we don't want to show the word Tzet first, just {Zman} Ends
        }
    }
    
    public func getCandleLightingString() -> String {
        if (mIsZmanimInHebrew) {
            return "הדלקת נרות";
        } else {
            return "Candle Lighting";
        }
    }
    
    public func getPlagHaminchaString() -> String {
        if (mIsZmanimInHebrew) {
            return "פלג המנחה"
        } else {
            if (mIsZmanimAmericanized) {
                return "Pelag Ha'Mincha";
            }
            return "Pelag Ha'Minḥa"
        }
    }
    
    public func getMinchaKetanaString() -> String {
        if (mIsZmanimInHebrew) {
            return "מנחה קטנה"
        } else if (mIsZmanimAmericanized) {
            return "Mincha Ketana";
        } else {
            return "Minḥa Ketana"
        }
    }
    
    public func getMinchaGedolaString() -> String {
        if (mIsZmanimInHebrew) {
            return "מנחה גדולה"
        } else if (mIsZmanimEnglishTranslated) {
            return "Earliest Minḥa"
        } else if (mIsZmanimAmericanized) {
            return "Mincha Gedola";
        } else {
            return "Minḥa Gedola"
        }
    }
    
    public func getChatzotString() -> String {
        if (mIsZmanimInHebrew) {
            return "חצות"
        } else if (mIsZmanimEnglishTranslated) {
            return "Mid-day"
        } else if (mIsZmanimAmericanized) {
            return "Chatzot";
        } else {
            return "Ḥatzot"
        }
    }
    
    public func getBiurChametzString() -> String {
        if (mIsZmanimInHebrew) {
            return "סוף זמן ביעור חמץ"
        } else if (mIsZmanimEnglishTranslated) {
            return "Latest time to burn Ḥametz"
        } else if (mIsZmanimAmericanized) {
            return "Sof Zeman Biur Chametz";
        } else {
            return "Sof Zeman Biur Ḥametz"
        }
    }
    
    public func getBrachotShmaString() -> String {
        if (mIsZmanimInHebrew) {
            return "סוף זמן ברכות שמע"
        } else if (mIsZmanimEnglishTranslated) {
            return "Latest Berakhot Shema"
        } else if (mIsZmanimAmericanized) {
            return "Sof Zeman Berachot Shema";
        } else {
            return "Sof Zeman Berakhot Shema"
        }
    }
    
    public func getAchilatChametzString() -> String {
        if (mIsZmanimInHebrew) {
            return "סוף זמן אכילת חמץ"
        } else if (mIsZmanimEnglishTranslated) {
            return "Latest time to eat Ḥametz"
        } else if (mIsZmanimAmericanized) {
            return "Sof Zeman Achilat Chametz";
        } else {
            return "Sof Zeman Akhilat Ḥametz"
        }
    }
    
    public func getShmaGraString() -> String {
        if (mIsZmanimInHebrew) {
            return "סוף זמן שמע גר\"א"
        } else if (mIsZmanimEnglishTranslated) {
            return "Latest Shema GR\"A"
        } else {
            return "Sof Zeman Shema GR\"A"
        }
    }
    
    public func getBirkatHachamaString() -> String {
        if (mIsZmanimInHebrew) {
            return "סוף זמן ברכת החמה";
        } else if (mIsZmanimEnglishTranslated) {
            return "Latest Birkat Ha'Ḥamah";
        } else if (mIsZmanimAmericanized) {
            return "Sof Zeman Birkat Ha'Chamah";
        } else {
            return "Sof Zeman Birkat Ha'Ḥamah";
        }
    }
    
    public func getShmaMgaString() -> String {
        if (mIsZmanimInHebrew) {
            return "סוף זמן שמע מג\"א"
        } else if (mIsZmanimEnglishTranslated) {
            return "Latest Shema MG\"A"
        } else {
            return "Sof Zeman Shema MG\"A"
        }
    }
    
    public func getMishorString() -> String {
        if (mIsZmanimInHebrew) {
            return "מישור";
        } else if (mIsZmanimEnglishTranslated) {
            return "Sea Level";
        } else {
            return "Mishor";
        }
    }
    
    public func getBetterString() -> String {
         if (mIsZmanimInHebrew) {
             return "(העדיף)";
         } else {
             return "(Better)";
         }
     }
    
    public func getElevatedString() -> String {
        if (mIsZmanimInHebrew) {
            return "(גבוה)"
        } else {
            return "(Elevated)"
        }
    }
    
    public func getHaNetzString() -> String {
        if (mIsZmanimInHebrew) {
            return "הנץ"
        } else if (mIsZmanimEnglishTranslated) {
            return "Sunrise"
        } else {
            return "Ha'Netz"
        }
    }
    
    public func getIsInString() -> String {
        if (mIsZmanimInHebrew) {
            return " ב... "
        } else {
            return " is in... "
        }
    }
    
    public func getTalitTefilinString() -> String {
        if (mIsZmanimInHebrew) {
            return "טלית ותפילין"
        } else {
            return "Earliest Tallit/Tefilin"
        }
    }
    
    public func getAlotString() -> String {
        if (mIsZmanimInHebrew) {
            return "עלות השחר"
        } else if (mIsZmanimEnglishTranslated) {
            return "Dawn"
        } else if (mIsZmanimAmericanized) {
            return "Alot Ha'Shachar";
        } else {
            return "Alot Ha'Shaḥar"
        }
    }
}

