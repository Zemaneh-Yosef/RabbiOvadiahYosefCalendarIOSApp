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
            return "Halacha Berurah"
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
            return "Chatzot Layla";
        }
    }
    
    public func getLChumraString() -> String {
        if (mIsZmanimInHebrew) {
            return "לחומרא";
        } else if (mIsZmanimEnglishTranslated) {
            return "(Stringent)";
        } else {
            return "L'Chumra";
        }
    }
    
    public func getTaanitString() -> String {
        if (mIsZmanimInHebrew) {
            return "תענית";
        } else if (mIsZmanimEnglishTranslated) {
            return "Fast";
        } else {
            return "Taanit";
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
            return "Tzait Hacochavim";
        }
    }
    
    public func getSunsetString() -> String {
        if (mIsZmanimInHebrew) {
            return "שקיעה";
        } else if (mIsZmanimEnglishTranslated) {
            return "Sunset";
        } else {
            return "Shkia";
        }
    }
    
    public func getRTString() -> String {
        if (mIsZmanimInHebrew) {
            return "רבינו תם";
        } else {
            return "Rabbeinu Tam";
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
            return "Tzait ";
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
    return "Mincha Ketana"
    }
    }

    public func getMinchaGedolaString() -> String {
    if (mIsZmanimInHebrew) {
    return "מנחה גדולה"
    } else if (mIsZmanimEnglishTranslated) {
    return "Earliest Mincha"
    } else {
    return "Mincha Gedola"
    }
    }

    public func getChatzotString() -> String {
    if (mIsZmanimInHebrew) {
    return "חצות"
    } else if (mIsZmanimEnglishTranslated) {
    return "Mid-day"
    } else {
    return "Chatzot"
    }
    }

    public func getBiurChametzString() -> String {
    if (mIsZmanimInHebrew) {
    return "סוף זמן ביעור חמץ"
    } else if (mIsZmanimEnglishTranslated) {
    return "Latest time to burn Chametz"
    } else {
    return "Sof Zman Biur Chametz"
    }
    }

    public func getBrachotShmaString() -> String {
    if (mIsZmanimInHebrew) {
    return "סוף זמן ברכות שמע"
    } else if (mIsZmanimEnglishTranslated) {
    return "Latest Brachot Shma"
    } else {
    return "Sof Zman Brachot Shma"
    }
    }

    public func getAchilatChametzString() -> String {
    if (mIsZmanimInHebrew) {
    return "סוף זמן אכילת חמץ"
    } else if (mIsZmanimEnglishTranslated) {
    return "Latest time to eat Chametz"
    } else {
    return "Sof Zman Achilat Chametz"
    }
    }

    public func getShmaGraString() -> String {
    if (mIsZmanimInHebrew) {
    return "סוף זמן שמע גר\"א"
    } else if (mIsZmanimEnglishTranslated) {
    return "Latest Shma GR\"A"
    } else {
    return "Sof Zman Shma GR\"A"
    }
    }

    public func getShmaMgaString() -> String {
    if (mIsZmanimInHebrew) {
    return "סוף זמן שמע מג\"א"
    } else if (mIsZmanimEnglishTranslated) {
    return "Latest Shma MG\"A"
    } else {
    return "Sof Zman Shma MG\"A"
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

