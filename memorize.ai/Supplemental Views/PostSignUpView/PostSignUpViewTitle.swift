import SwiftUI

struct PostSignUpViewTitle: View {
	let text: String
	
	var body: some View {
		Text(text)
			.font(.muli(.bold, size: 28))
			.foregroundColor(.white)
			.multilineTextAlignment(.leading)
			.align(to: .leading)
			.padding(.leading, 50)
			.padding(.trailing, 60)
			.padding(.top, 8)
	}
}

#if DEBUG
struct PostSignUpViewTitle_Previews: PreviewProvider {
	static var previews: some View {
		PostSignUpViewTitle(text: "Choose your interests")
	}
}
#endif
