import SwiftUI

struct AuthenticationViewContentBox: View {
	static let horizontalPadding: CGFloat = 96
	static let verticalPadding: CGFloat = 212
	
	let title: String
	
	var body: some View {
		GeometryReader { geometry in
			CustomRectangle(
				borderColor: .lightGray,
				borderWidth: 1.5,
				cornerRadius: 5,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				VStack {
					Text(self.title)
						.font(.muli(.bold, size: 28))
						.foregroundColor(.darkGray)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.leading, 16)
						.padding(.top, 35)
					Spacer()
				}
				.frame(
					width: geometry.size.width - Self.horizontalPadding,
					height: geometry.size.height - Self.verticalPadding
				)
			}
		}
	}
}

#if DEBUG
struct AuthenticationViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		AuthenticationViewContentBox(
			title: "Welcome back"
		)
	}
}
#endif
