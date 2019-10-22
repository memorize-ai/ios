import SwiftUI

struct LogInView: View {
	var body: some View {
		VStack {
			ZStack {
				AuthenticationViewTopGradient()
//				AuthenticationViewTopControls()
			}
			Spacer()
		}
		.background(Color.lightGrayBackground)
	}
}

#if DEBUG
struct LogInView_Previews: PreviewProvider {
	static var previews: some View {
		LogInView()
	}
}
#endif
