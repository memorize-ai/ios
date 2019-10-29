import SwiftUI

struct SignUpViewContentBox: View {
	@ObservedObject var model: SignUpViewModel
	
	var body: some View {
		VStack(spacing: 12) {
			CustomTextField(
				$model.name,
				placeholder: "Name",
				contentType: .name,
				keyboardType: .alphabet,
				capitalization: .words,
				borderWidth: 0 // TODO
			)
			CustomTextField(
				$model.email,
				placeholder: "Email",
				contentType: .emailAddress,
				keyboardType: .emailAddress,
				capitalization: .none,
				borderWidth: 0 // TODO
			)
			CustomTextField(
				$model.password,
				placeholder: "Password",
				contentType: .newPassword,
				capitalization: .none,
				secure: true,
				borderWidth: 0 // TODO
			)
		}
	}
}

#if DEBUG
struct SignUpViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		SignUpViewContentBox(model: .init())
	}
}
#endif
