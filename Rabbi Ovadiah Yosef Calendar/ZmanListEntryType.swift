//
//  ZmanListEntryType.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 10/12/26.
//

enum ZmanListEntryType: CaseIterable {
    case unspecified
    case shabbatMevarchim
    case specialDay
    case eruvTavshilin
    case dayOfOmer
    case threeWeeks
    case nineDays
    case shevuaShechalBo
    case music
    case halelOrChatziHallel
    case ulchaparatPesha
    case tachanun
    case purimMeshulash
    case birchatHalevana
    case moonStatus
    case birkatHachamah
    case burnChametz
    case tekufaTime
    case tekufaLength

    // Zmanim start here
    case fastStartsNonTishaBavZman
    case alotHashacharZman
    case misheyakir66Zman
    case misheyakir60Zman
    case hanetzZman
    case sofZmanShmaMGAZman
    case sofZmanShmaGRAZman
    case birkatHachmahZman
    case sofZmanAchilatChametzZman
    case sofZmanBerachotShmaZman
    case sofZmanBiurChametzZman
    case chatzotZman
    case minchaGedolahZman
    case minchaKetanaZman
    case plagHaminchaHBZman
    case plagHaminchaYYZman
    case candlelightingZman
    case fastStartsTishaBavZman
    case sunsetZman
    case tzetHakokhavimZman
    case tzetHakokhavimLChumraZman
    case fastEndsZman
    case shabbatChagEndsZman
    case rabbenuTamZman
    case chatzotLaylaZman
    // Zmanim end here

    case seasonalPrayerChanges
    case shaahZmanitGRA
    case shaahZmanitMGA
    case leapYear
    case dst
    case shmitaYear
    case elevationValue
    case jewishMonth // not on Android, but needed

    /// Replaces the "Zmanim start here / end here" comment markers with something queryable.
    var isZman: Bool {
        guard let index = Self.allCases.firstIndex(of: self),
              let start = Self.allCases.firstIndex(of: .fastStartsNonTishaBavZman),
              let end = Self.allCases.firstIndex(of: .chatzotLaylaZman) else {
            return false
        }
        return (start...end).contains(index)
    }
}
