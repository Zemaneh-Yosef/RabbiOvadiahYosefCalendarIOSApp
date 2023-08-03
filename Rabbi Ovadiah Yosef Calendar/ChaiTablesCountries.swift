//
//  ChaiTablesCountries.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Macbook Pro on 7/24/23.
//

import Foundation

enum ChaiTablesCountries: String {
    case ARGENTINA = "Argentina"
    case AUSTRALIA = "Australia"
    case AUSTRIA = "Austria"
    case BELGIUM = "Belgium"
    case BRAZIL = "Brazil"
    case BULGARIA = "Bulgaria"
    case CANADA = "Canada"
    case CHILE = "Chile"
    case CHINA = "China"
    case COLOMBIA = "Colombia"
    case CZECH_REPUBLIC = "Czech-Republic"
    case DENMARK = "Denmark"
    case ERETZ_YISROEL_CITIES = "Eretz_Yisroel" // becomes Eretz_Yisroel in the link
    case ERETZ_YISROEL_NEIGHBORHOODS = "Israel" // becomes Israel in the link
    case FRANCE = "France"
    case GERMANY = "Germany"
    case GREECE = "Greece"
    case HUNGARY = "Hungary"
    case ITALY = "Italy"
    case MEXICO = "Mexico"
    case NETHERLANDS = "Netherlands"
    case PANAMA = "Panama"
    case POLAND = "Poland"
    case ROMANIA = "Romania"
    case RUSSIA = "Russia"
    case SOUTH_AFRICA = "South-Africa"
    case SPAIN = "Spain"
    case SWITZERLAND = "Switzerland"
    case TURKEY = "Turkey"
    case UK_AND_IRELAND = "England" // becomes England in the link
    case UKRAINE = "Ukraine"
    case URUGUAY = "Uruguay"
    case USA = "USA"
    case VENEZUELA = "Venezuela"
    
    var label: String {
        return self.rawValue
    }
}
