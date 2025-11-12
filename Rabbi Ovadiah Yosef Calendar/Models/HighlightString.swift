//
//  HighlightString.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/6/25.
//

import Foundation

public struct HighlightString: Identifiable, Hashable {
    public let id = UUID()
    let string: String
    let shouldBeHighlighted: Bool
    let isCategory: Bool
    let isInfo: Bool
    let isInstruction: Bool
    
    init(_ string: String, shouldBeHighlighted: Bool = false, isCategory: Bool = false, isInfo: Bool = false, isInstruction: Bool = false) {
        self.string = string
        self.shouldBeHighlighted = shouldBeHighlighted
        self.isCategory = isCategory
        self.isInfo = isInfo
        self.isInstruction = isInstruction
    }
    
    func setShouldBeHighlighted(_ highlighted: Bool) -> HighlightString {
        return HighlightString(string, shouldBeHighlighted: highlighted, isCategory: isCategory)
    }
    
    func setIsCategory(_ isCategory: Bool) -> HighlightString {
        return HighlightString(string, shouldBeHighlighted: shouldBeHighlighted, isCategory: isCategory)
    }
    
    func setIsInfo(_ isInfo: Bool) -> HighlightString {
        return HighlightString(string, shouldBeHighlighted: shouldBeHighlighted, isCategory: isCategory, isInfo: isInfo)
    }
    func setIsInstruction(_ isInstruction: Bool) -> HighlightString {
        return HighlightString(string, shouldBeHighlighted: shouldBeHighlighted, isCategory: isCategory, isInfo: isInfo, isInstruction: isInstruction)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }
    
    public static func == (lhs: HighlightString, rhs: HighlightString) -> Bool {
        return lhs.string == rhs.string && lhs.shouldBeHighlighted == rhs.shouldBeHighlighted && lhs.isCategory == rhs.isCategory && lhs.id == rhs.id && lhs.isInfo == rhs.isInfo && lhs.isInstruction == rhs.isInstruction
    }
}
