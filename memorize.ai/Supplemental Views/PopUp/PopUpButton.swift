import SwiftUI

struct PopUpButton<Icon: View>: View {
	let icon: Icon?
	let text: String
	let textColor: Color
	let onClick: () -> Void
	
	var body: some View {
		Button(action: onClick) {
			HStack(spacing: 20) {
				icon
				Text(text)
					.font(.muli(.semiBold, size: 17))
					.foregroundColor(textColor)
				Spacer()
			}
		}
		.frame(height: 50)
	}
}

#if DEBUG
struct PopUpButton_Previews: PreviewProvider {
	static var previews: some View {
		PopUpButton(
			icon: XButton(.purple, height: 15),
			text: "Remove",
			textColor: .extraPurple
		) {}
	}
}
#endif
