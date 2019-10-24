import SwiftUI

struct LogInViewContentBox: View {
	@State var email = ""
	@State var password = ""
	
	var body: some View {
		VStack {
			VStack(spacing: 12) {
				CustomTextField($email, placeholder: "Email")
				CustomTextField($password, placeholder: "Password")
			}
			CustomRectangle(backgroundColor: .neonGreen) {
				Text("LOG IN")
					.font(.muli(.bold, size: 14))
					.foregroundColor(.white)
			}
		}
	}
}

#if DEBUG
struct LogInViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		LogInViewContentBox()
	}
}
#endif
