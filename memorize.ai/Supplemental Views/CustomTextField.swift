import SwiftUI

struct CustomTextField: View {
	@Binding var text: String
	
	let placeholder: String
	let textColor: Color
	let font: Font
	
	init(
		_ text: Binding<String>,
		placeholder: String = "",
		textColor: Color = .darkText,
		font: Font = .muli(.regular, size: 14)
	) {
		_text = text
		self.placeholder = placeholder
		self.textColor = textColor
		self.font = font
	}
	
	var body: some View {
		TextField(placeholder, text: $text)
			.textFieldStyle(RoundedBorderTextFieldStyle())
			.foregroundColor(textColor)
			.font(font)
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
