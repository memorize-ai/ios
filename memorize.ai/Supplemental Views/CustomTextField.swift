import SwiftUI

struct CustomTextField: View {
	static let defaultBackgroundColor = Color.mediumGray.opacity(0.6799)
	
	@Binding var text: String
	
	let placeholder: String
	let contentType: UITextContentType
	let keyboardType: UIKeyboardType
	let secure: Bool
	let internalPadding: CGFloat
	let textColor: Color
	let font: Font
	let backgroundColor: Color
	let cornerRadius: CGFloat
	
	init(
		_ text: Binding<String>,
		placeholder: String = "",
		contentType: UITextContentType = .name,
		keyboardType: UIKeyboardType = .default,
		secure: Bool = false,
		internalPadding: CGFloat = 10,
		textColor: Color = .darkText,
		font: Font = .muli(.regular, size: 14),
		backgroundColor: Color = Self.defaultBackgroundColor,
		cornerRadius: CGFloat = 5
	) {
		_text = text
		self.placeholder = placeholder
		self.contentType = contentType
		self.keyboardType = keyboardType
		self.secure = secure
		self.internalPadding = internalPadding
		self.textColor = textColor
		self.font = font
		self.backgroundColor = backgroundColor
		self.cornerRadius = cornerRadius
	}
	
	var textField: some View {
		secure
			? AnyView(SecureField(placeholder, text: $text))
			: AnyView(TextField(placeholder, text: $text))
	}
	
	var body: some View {
		textField
			.padding(internalPadding)
			.background(backgroundColor)
			.foregroundColor(textColor)
			.font(font)
			.cornerRadius(cornerRadius)
			.textContentType(contentType)
			.keyboardType(keyboardType)
	}
}

#if DEBUG
struct CustomTextField_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 20) {
			CustomTextField(
				.constant("Ken Mueller"),
				placeholder: "Name"
			)
			CustomTextField(
				.constant(""),
				placeholder: "Name"
			)
		}
		.padding(.horizontal)
	}
}
#endif
