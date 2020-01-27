import SwiftUI

struct ProfileViewMainCard: View {
	@ObservedObject var user: User
	
	var name: Binding<String> {
		.init(get: { self.user.name }) {
			self.user.setName(to: $0)
		}
	}
	
	func titleLabel(_ text: String) -> some View {
		Text(text)
			.font(.muli(.bold, size: 14))
			.foregroundColor(.lightGrayText)
			.alignment(.leading)
	}
	
	var body: some View {
		CustomRectangle(background: Color.white) {
			VStack(spacing: 20) {
				VStack(spacing: 8) {
					titleLabel("Name")
					CustomTextField(
						name,
						textColor: .darkGray,
						font: .muli(.bold, size: 16)
					)
				}
				VStack(spacing: 8) {
					titleLabel("Email")
					Text(user.email)
						.font(.muli(.bold, size: 16))
						.foregroundColor(.darkGray)
						.alignment(.leading)
				}
			}
			.padding()
			.frame(width: SCREEN_SIZE.width - 8 * 2)
		}
	}
}

#if DEBUG
struct ProfileViewMainCard_Previews: PreviewProvider {
	static var previews: some View {
		ProfileViewMainCard(user: PREVIEW_CURRENT_STORE.user)
	}
}
#endif
