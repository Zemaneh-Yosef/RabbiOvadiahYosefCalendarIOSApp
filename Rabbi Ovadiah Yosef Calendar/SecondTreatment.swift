//
//  SecondTreatment.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 3/12/26.
//

import Foundation
/**
 * This enum is used to determine how a zman should be displayed. If it is ALWAYS_DISPLAY, it will always display the seconds. If it is ROUND_EARLIER,
 * it will round the seconds down to the nearest minute. If it is ROUND_LATER, it will round the seconds up to the nearest minute.
 */
public enum SecondTreatment: Int {
    case alwaysDisplay = 0
    case roundEarlier = 1
    case roundLater = 2
}
