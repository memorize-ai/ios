import SwiftUI
import FirebaseAnalytics

struct AuthenticationViewTopControls<AlternativeDestination: View>: View {
	@Binding var presentationMode: PresentationMode
	
	let alternativeMessage: String
	let alternativeButtonText: String
	let alternativeButtonDestination: AlternativeDestination
	
	var body: some View {
		HStack {
			Button(action: {
				Analytics.logEvent("authentication_view_dismissed", parameters: [
					"view": "AuthenticationViewTopControls",
					"alternative_message": self.alternativeMessage
				])
				
				self.presentationMode.dismiss()
			}) {
				LeftArrowHead(height: 20)
			}
			Spacer()
			Text(alternativeMessage)
				.font(.muli(.regular, size: 13))
				.foregroundColor(Color.white.opacity(0.5))
				.padding([.trailing, .bottom], 1)
			NavigationLink(
				destination: alternativeButtonDestination
					.navigationBarRemoved()
			) {
				CustomRectangle(
					background: Color.clear,
					borderColor: .transparentLightGray,
					borderWidth: 1.5
				) {
					Text(alternativeButtonText)
						.font(.muli(.bold, size: 13))
						.foregroundColor(Color.white.opacity(0.7))
						.frame(width: 70, height: 28)
				}
			}
		}
		.padding(.leading, 33)
		.padding(.trailing, 16)
	}
}

#if DEBUG
struct AuthenticationViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		Text("Preview unavailable")
	}
}
#endif
