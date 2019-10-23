import SwiftUI

struct LogInView: View {
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		GeometryReader { geometry in
			VStack {
				ZStack(alignment: .top) {
					AuthenticationViewTopGradient([
						.bluePurple,
						.lightGreen
					], fullHeight: geometry.size.height)
					AuthenticationViewTopControls(
						presentationMode: self.presentationMode
					)
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
