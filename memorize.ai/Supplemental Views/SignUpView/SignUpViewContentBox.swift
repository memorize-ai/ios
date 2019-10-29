import SwiftUI

struct SignUpViewContentBox: View {
	@ObservedObject var model: SignUpViewModel
	
	var body: some View {
		Text("SignUpViewContentBox")
	}
}

#if DEBUG
struct SignUpViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		SignUpViewContentBox(model: .init())
	}
}
#endif
