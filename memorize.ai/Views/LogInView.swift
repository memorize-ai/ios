import SwiftUI

struct LogInView: View {
	var body: some View {
		GeometryReader { geometry in
			VStack {
				ZStack {
					AuthenticationViewTopGradient([
						.bluePurple,
						.lightGreen
					], fullHeight: geometry.size.height)
	//				AuthenticationViewTopControls()
				}
				Spacer()
			}
		}
		.background(Color.lightGrayBackground)
		.edgesIgnoringSafeArea(.all)
	}
}

#if DEBUG
struct LogInView_Previews: PreviewProvider {
	static var previews: some View {
		LogInView()
	}
}
#endif
