import SwiftUI

struct AuthenticationViewTopControls: View {
	@Binding var presentationMode: PresentationMode
	
	var body: some View {
		HStack {
			Button(action: {
				self.presentationMode.dismiss()
			}) {
				LeftArrowHead(height: 20)
			}
			Spacer()
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
