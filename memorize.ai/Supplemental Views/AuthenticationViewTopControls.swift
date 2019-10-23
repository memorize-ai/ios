import SwiftUI

struct AuthenticationViewTopControls: View {
	@Binding var presentationMode: PresentationMode

	let alternativeMessage: String
	let alternativeButtonText: String
	
	var body: some View {
		HStack {
			Button(action: {
				self.presentationMode.dismiss()
			}) {
				LeftArrowHead(height: 20)
			}
			Spacer()
			Text(alternativeMessage)
				.font(.muli(.regular, size: 12))
				.foregroundColor(Color.white.opacity(0.5))
			Button(action: {}) {
				Text(alternativeButtonText)
			}
		}
		.padding(.horizontal, 33)
		.padding(.top, 30)
		.removeNavigationBar()
	}
}

#if DEBUG
struct AuthenticationViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		Text("Preview unavailable")
	}
}
#endif
