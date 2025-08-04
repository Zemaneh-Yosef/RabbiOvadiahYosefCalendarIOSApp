import SwiftUI

public struct MarqueeText: View {
    @State public var text: String
    public var font: UIFont
    public var leftFade: CGFloat
    public var rightFade: CGFloat
    public var startDelay: Double
    public var alignment: Alignment
    public var foregroundColor: Color?
    public var backgroundColor: Color?

    @State private var animate = false
    var isCompact = false

    public var body: some View {
        let stringWidth  = text.widthOfString(usingFont: font)
        let stringHeight = text.heightOfString(usingFont: font)

        // Create our animations
        let animation = Animation
            .linear(duration: Double(stringWidth) / 30)
            .delay(startDelay)
            .repeatForever(autoreverses: false)

        let nullAnimation = Animation.linear(duration: 0)

        GeometryReader { geo in
            let needsScrolling = (stringWidth > geo.size.width)

            ZStack {
                if needsScrolling {
                    makeMarqueeTexts(
                        stringWidth: stringWidth,
                        stringHeight: stringHeight,
                        geoWidth: geo.size.width,
                        animation: animation,
                        nullAnimation: nullAnimation
                    )
                    .frame(minWidth: 0, maxWidth: .infinity,
                           minHeight: 0, maxHeight: .infinity,
                           alignment: .topLeading)
                    .offset(x: leftFade)
                    .mask(fadeMask(leftFade: leftFade, rightFade: rightFade))
                    .frame(width: geo.size.width + leftFade)
                    .offset(x: -leftFade)
                } else {
                    Text(text)
                        .font(.init(font))
                        .foregroundStyle(foregroundColor ?? .black)
                        .onChange(of: text) { _ in self.animate = false }
                        .frame(minWidth: 0, maxWidth: .infinity,
                               minHeight: 0, maxHeight: .infinity,
                               alignment: alignment)
                }
            }
            .background(backgroundColor)
            .onAppear {
                self.animate = needsScrolling
            }
            .onChange(of: text) { newValue in
                let newStringWidth = newValue.widthOfString(usingFont: font)
                if newStringWidth > geo.size.width {
                    self.animate = false
                    DispatchQueue.main.async {
                        self.animate = true
                    }
                } else {
                    self.animate = false
                }
            }
        }
        .frame(height: stringHeight)
        .frame(maxWidth: isCompact ? stringWidth : nil)
        .onDisappear {
            self.animate = false
        }
    }

    // MARK: - Marquee pair of texts
    @ViewBuilder
    private func makeMarqueeTexts(
        stringWidth: CGFloat,
        stringHeight: CGFloat,
        geoWidth: CGFloat,
        animation: Animation,
        nullAnimation: Animation
    ) -> some View {
        // Two stacked texts moving across in opposite phases
        Group {
            Text(text)
                .lineLimit(1)
                .font(.init(font))
                .foregroundStyle(foregroundColor ?? Color.blue)
                .offset(x: animate ? -stringWidth - stringHeight * 2 : 0)
                .animation(animate ? animation : nullAnimation, value: animate)
                .fixedSize(horizontal: true, vertical: false)

            Text(text)
                .lineLimit(1)
                .font(.init(font))
                .foregroundStyle(foregroundColor ?? Color.blue)
                .offset(x: animate ? 0 : stringWidth + stringHeight * 2)
                .animation(animate ? animation : nullAnimation, value: animate)
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    // MARK: - Fade mask
    @ViewBuilder
    private func fadeMask(leftFade: CGFloat, rightFade: CGFloat) -> some View {
        HStack(spacing: 0) {
            Rectangle().frame(width: 2).opacity(0)

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0), Color.black]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: leftFade)

            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black]),
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: rightFade)

            Rectangle().frame(width: 2).opacity(0)
        }
    }

    // MARK: - Initializer
    public init(
        text: String,
        font: UIFont,
        leftFade: CGFloat,
        rightFade: CGFloat,
        startDelay: Double,
        alignment: Alignment? = nil,
        foregroundColor: Color? = nil,
        backgroundColor: Color? = nil
    ) {
        self.text = text
        self.font = font
        self.leftFade = leftFade
        self.rightFade = rightFade
        self.startDelay = startDelay
        self.alignment = alignment ?? .topLeading
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
}

extension MarqueeText {
    public func makeCompact(_ compact: Bool = true) -> Self {
        var view = self
        view.isCompact = compact
        return view
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}
