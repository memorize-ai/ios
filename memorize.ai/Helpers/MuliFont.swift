import SwiftUI

extension Font {
	static func muli(_ font: MuliFont, size: CGFloat) -> Self {
		custom(font.rawValue, size: size)
	}
}

enum MuliFont: String {
	case extraLight = "Muli-ExtraLight"
	case extraLightItalic = "Muli-ExtraLightItalic"
	case boldItalic = "Muli-BoldItalic"
	case black = "Muli-Black"
	case extraBold = "Muli-ExtraBold"
	case bold = "Muli-Bold"
	case extraBoldItalic = "Muli-ExtraBoldItalic"
	case italic = "Muli-Italic"
	case semiBold = "Muli-SemiBold"
	case semiBoldItalic = "Muli-SemiBoldItalic"
	case blackItalic = "Muli-BlackItalic"
	case light = "Muli-Light"
	case regular = "Muli-Regular"
	case lightItalic = "Muli-LightItalic"
}
