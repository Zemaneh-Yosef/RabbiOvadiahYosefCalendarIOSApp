// Source - https://stackoverflow.com/a/76412638
// Posted by Steve Barnes
// Retrieved 2026-07-23, License - CC BY-SA 4.0

// Conform to `PrimitiveButtonStyle` for custom interaction behaviour

import SwiftUI

struct SupportsLongPress: PrimitiveButtonStyle {
    
    /// An action to execute on long press
    let longPressAction: () -> ()
    
    /// Whether the button is being pressed
    @State var isPressed: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        
        // The "label" as specified when declaring the button
        configuration.label
        
            // Visual feedback that the button is being pressed
            .scaleEffect(self.isPressed ? 0.9 : 1.0)
        
            .onTapGesture {
                
                // Run the "action" as specified
                // when declaring the button
                configuration.trigger()
                
            }
        
            .onLongPressGesture(
                
                perform: {
                    
                    // Run the action specified
                    // when using this style
                    self.longPressAction()
                    
                },
                
                onPressingChanged: { pressing in
                    
                    // Use "pressing" to infer whether the button
                    // is being pressed
                    self.isPressed = pressing
                    
                }
                
            )
        
    }
    
}

/// A modifier that applies the `SupportsLongPress` style to buttons
struct SupportsLongPressModifier: ViewModifier {
    let longPressAction: () -> ()
    func body(content: Content) -> some View {
        content.buttonStyle(SupportsLongPress(longPressAction: self.longPressAction))
    }
}

/// Extend the View protocol for a SwiftUI-like shorthand version
extension View {
    func supportsLongPress(longPressAction: @escaping () -> ()) -> some View {
        modifier(SupportsLongPressModifier(longPressAction: longPressAction))
    }
}
