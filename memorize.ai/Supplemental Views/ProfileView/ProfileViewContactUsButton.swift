import SwiftUI

struct ProfileViewContactUsButton: View {
	@ObservedObject var user: User
	
	@State var options: MailView.Options?
	
	var defaultOptions: MailView.Options {
		let device = UIDevice.current
		let tab = "&nbsp;&nbsp;&nbsp;&nbsp;"
		
		return .init(
			recipient: SUPPORT_EMAIL,
			subject: "",
			body: """
			<br>
			<hr>
			<b>User info</b><br>
			ID: \(user.id)<br>
			Name: \(user.name)<br>
			Email: \(user.email)<br>
			XP: \(user.xp)<br>
			App version: \(APP_VERSION ?? "(error)")<br>
			Device:<br>
			\(tab)Name: \(device.name)<br>
			\(tab)Model: \(device.model)<br>
			\(tab)System: \(device.systemName)<br>
			\(tab)System version: \(device.systemVersion)
			""",
			isHTML: true
		)
	}
	
	var body: some View {
		Button(action: {
			self.options = self.defaultOptions
		}) {
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGrayBorder,
				borderWidth: 1
			) {
				Text("Contact us")
					.font(.muli(.semiBold, size: 16))
					.foregroundColor(.darkBlue)
					.shrinks()
					.frame(
						width: (SCREEN_SIZE.width - 8 * 3) / 2,
						height: 40
					)
			}
		}
		.padding(.top, 1)
		.mailView(options: $options)
	}
}

#if DEBUG
struct ProfileViewContactUsButton_Previews: PreviewProvider {
	static var previews: some View {
		ProfileViewContactUsButton(user: PREVIEW_CURRENT_STORE.user)
	}
}
#endif
