import SwiftUI

struct ForgotPasswordViewContentBox: View {
	@ObservedObject var model: ForgotPasswordViewModel
	
	var body: some View {
		Text("ForgotPasswordViewContentBox")
	}
}

#if DEBUG
struct ForgotPasswordViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		ForgotPasswordViewContentBox(model: .init())
	}
}
#endif
