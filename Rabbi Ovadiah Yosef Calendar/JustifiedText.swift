//
//  HairSpaceJustifiedText.swift
//  FrameUpExample
//
//  Created by Ryan Lintott on 2022-11-15.
//

import SwiftUI
import FrameUp

/// A SwiftUI-only method for efficiently presenting justifying text. This is particularly useful in a widget or other SwiftUI-only setting.
public struct JustifiedText: View {
    let text: String
    let font: UIFont
    let isJustified: Bool
    
    public init(_ text: String, font: UIFont, isJustified: Bool = false) {
        self.font = font
        self.text = text
        self.isJustified = isJustified
    }
    
    public var body: some View {
        if isJustified {
            HairSpaceJustifiedText(text, font: font)
        } else {
            Text(text).font(Font(font))
        }
    }
}
