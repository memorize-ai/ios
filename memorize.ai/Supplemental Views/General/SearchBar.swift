import SwiftUI

struct SearchBar: View {
	@Binding var text: String
	
	let placeholder: String
	let contentType: UITextContentType
	let keyboardType: UIKeyboardType
	let capitalization: UITextAutocapitalizationType
	let internalPadding: CGFloat
	let textColor: Color
	let backgroundColor: Color
	let font: Font
	let cornerRadius: CGFloat
	let borderColor: Color
	let borderWidth: CGFloat
	
	init(
		_ text: Binding<String>,
		placeholder: String,
		contentType: UITextContentType = .name,
		keyboardType: UIKeyboardType = .default,
		capitalization: UITextAutocapitalizationType = .sentences,
		internalPadding: CGFloat = 10,
		textColor: Color = .lightGrayText,
		backgroundColor: Color = .white,
		font: Font = .muli(.regular, size: 17),
		cornerRadius: CGFloat = 8,
		borderColor: Color = .lightGrayBorder,
		borderWidth: CGFloat = 1
	) {
		_text = text
		self.placeholder = placeholder
		self.contentType = contentType
		self.keyboardType = keyboardType
		self.capitalization = capitalization
		self.internalPadding = internalPadding
		self.textColor = textColor
		self.backgroundColor = backgroundColor
		self.font = font
		self.cornerRadius = cornerRadius
		self.borderColor = borderColor
		self.borderWidth = borderWidth
	}
	
	var body: some View {
		HStack {
			Image.grayMagnifyingGlass
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 16)
			TextField(placeholder, text: $text)
				.font(font)
				.foregroundColor(textColor)
				.textContentType(contentType)
				.keyboardType(keyboardType)
				.autocapitalization(capitalization)
				.padding([.trailing, .vertical], internalPadding)
		}
		.padding(.leading, 16)
		.background(backgroundColor)
		.cornerRadius(cornerRadius)
		.overlay(
			RoundedRectangle(cornerRadius: cornerRadius)
				.stroke(borderColor, lineWidth: borderWidth)
		)
	}
}

#if DEBUG
struct SearchBar_Previews: PreviewProvider {
	static var previews: some View {
		SearchBar(
			.constant(""),
			placeholder: "Search"
		)
	}
}
#endif
