//
//  HighlightString.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 5/6/25.
//

import Foundation

public struct HighlightString: Identifiable, Hashable {
    public let id = UUID()
    var string: String
    var shouldBeHighlighted: Bool
    var isCategory: Bool
    var isInfo: Bool
    var isInstruction: Bool
    var isMenorah: Bool
    var isCompass: Bool
    
    init(_ string: String, shouldBeHighlighted: Bool = false, isCategory: Bool = false, isInfo: Bool = false, isInstruction: Bool = false, isMenorah: Bool = false, isCompass: Bool = false) {
        self.string = string
        self.shouldBeHighlighted = shouldBeHighlighted
        self.isCategory = isCategory
        self.isInfo = isInfo
        self.isInstruction = isInstruction
        self.isMenorah = isMenorah
        self.isCompass = isCompass
    }
    
    func setShouldBeHighlighted(_ highlighted: Bool) -> HighlightString {
        var copy = self
        copy.shouldBeHighlighted = highlighted
        return copy
    }
    
    func setIsCategory(_ isCategory: Bool) -> HighlightString {
        var copy = self
        copy.isCategory = isCategory
        return copy
    }
    
    func setIsInfo(_ isInfo: Bool) -> HighlightString {
        var copy = self
        copy.isInfo = isInfo
        return copy
    }
    
    func setIsInstruction(_ isInstruction: Bool) -> HighlightString {
        var copy = self
        copy.isInstruction = isInstruction
        return copy
    }
    
    func setIsMenorah(_ isMenorah: Bool) -> HighlightString {
        var copy = self
        copy.isMenorah = isMenorah
        return copy
    }
    
    func setIsCompass(_ isCompass: Bool) -> HighlightString {
        var copy = self
        copy.isCompass = isCompass
        return copy
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }
    
    public static func == (lhs: HighlightString, rhs: HighlightString) -> Bool {
        return lhs.string == rhs.string && lhs.shouldBeHighlighted == rhs.shouldBeHighlighted && lhs.isCategory == rhs.isCategory && lhs.id == rhs.id && lhs.isInfo == rhs.isInfo && lhs.isInstruction == rhs.isInstruction
    }
}
