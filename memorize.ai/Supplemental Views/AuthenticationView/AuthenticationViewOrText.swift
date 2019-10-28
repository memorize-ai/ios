import SwiftUI

struct AuthenticationViewOrText: View {
	var body: some View {
		Text("OR")
			.font(.muli(.regular, size: 12))
			.foregroundColor(.darkText)
	}
}

#if DEBUG
struct AuthenticationViewOrText_Previews: PreviewProvider {
	static var previews: some View {
		AuthenticationViewOrText()
	}
}
#endif
