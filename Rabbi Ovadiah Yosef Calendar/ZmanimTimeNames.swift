//
//  ZmanimTimeNames.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu on 3/28/23.
//

import Foundation

struct ZmanimTimeNames {
    var mIsZmanimInHebrew = false
    var mIsZmanimEnglishTranslated = false
    
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
        } else {
            return "Ḥatzot Layla";
        }
    }
    
    public func getLChumraString() -> String {
        if (mIsZmanimInHebrew) {
            return "לחומרא";
        } else if (mIsZmanimEnglishTranslated) {
            return "(Stringent)";
        } else {
            return "L'Ḥumra";
        }
    }
    
    public func getTaanitString() -> String {
        if (mIsZmanimInHebrew) {
            return "תענית";
        } else if (mIsZmanimEnglishTranslated) {
            return "Fast";
        } else {
            return "Ta'anit";
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
        } else {
            return "Tzait Hakokhavim";
        }
    }
    
    public func getSunsetString() -> String {
        if (mIsZmanimInHebrew) {
            return "שקיעה";
        } else if (mIsZmanimEnglishTranslated) {
            return "Sunset";
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
    
    public func getMacharString() -> String {
        if (mIsZmanimInHebrew) {
            return " (מחר) ";
        } else {
            return " (Tom) ";
        }
    }
    
    public func getEndsString() -> String {
        if (mIsZmanimEnglishTranslated) {
            return " Ends";
        } else {
            return "";
        }
    }
    
    public func getTzaitString() -> String {
        if (mIsZmanimInHebrew) {
            return "צאת ";
        } else if (!mIsZmanimEnglishTranslated) {
            return "Tzet ";
        } else {
            return "";//if we are translating to English, we don't want to show the word Tzait first, just {Zman} Ends
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
            return "Plag HaMincha"
        }
    }
    
    public func getMinchaKetanaString() -> String {
        if (mIsZmanimInHebrew) {
            return "מנחה קטנה"
        } else {
            return "Minḥa Ketana"
        }
    }
    
    public func getMinchaGedolaString() -> String {
        if (mIsZmanimInHebrew) {
            return "מנחה גדולה"
        } else if (mIsZmanimEnglishTranslated) {
            return "Earliest Minḥa"
        } else {
            return "Minḥa Gedola"
        }
    }
    
    public func getChatzotString() -> String {
        if (mIsZmanimInHebrew) {
            return "חצות"
        } else if (mIsZmanimEnglishTranslated) {
            return "Mid-day"
        } else {
            return "Ḥatzot"
        }
    }
    
    public func getBiurChametzString() -> String {
        if (mIsZmanimInHebrew) {
            return "סוף זמן ביעור חמץ"
        } else if (mIsZmanimEnglishTranslated) {
            return "Latest time to burn Ḥametz"
        } else {
            return "Sof Zeman Biur Ḥametz"
        }
    }
    
    public func getBrachotShmaString() -> String {
        if (mIsZmanimInHebrew) {
            return "סוף זמן ברכות שמע"
        } else if (mIsZmanimEnglishTranslated) {
            return "Latest Berakhot Shema"
        } else {
            return "Sof Zeman Berakhot Shema"
        }
    }
    
    public func getAchilatChametzString() -> String {
        if (mIsZmanimInHebrew) {
            return "סוף זמן אכילת חמץ"
        } else if (mIsZmanimEnglishTranslated) {
            return "Latest time to eat Ḥametz"
        } else {
            return "Sof Zeman Achilat Ḥametz"
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
            return "Latest Birkat HaChamah";
        } else {
            return "Sof Zeman Birkat HaChamah";
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
            return "HaNetz"
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
            return "Earliest Talit/Tefilin"
        }
    }
    
    public func getAlotString() -> String {
        if (mIsZmanimInHebrew) {
            return "עלות השחר"
        } else if (mIsZmanimEnglishTranslated) {
            return "Dawn"
        } else {
            return "Alot Hashachar"
        }
    }
}

