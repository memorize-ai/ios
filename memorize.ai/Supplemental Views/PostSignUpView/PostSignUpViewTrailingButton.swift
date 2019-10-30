import SwiftUI

struct PostSignUpViewTrailingButton<Destination: View>: View {
	let text: String
	let destination: Destination
	
	var body: some View {
		NavigationLink(destination: destination) {
			CustomRectangle(
				backgroundColor: .transparent,
				borderColor: .transparentLightGray,
				borderWidth: 1.5
			) {
				Text(text)
					.font(.muli(.bold, size: 13))
					.foregroundColor(Color.white.opacity(0.7))
					.padding(.horizontal, 8)
					.frame(height: 28)
			}
		}
	}
}

#if DEBUG
struct PostSignUpViewTrailingButton_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.gray
				.edgesIgnoringSafeArea(.all)
			PostSignUpViewTrailingButton(
				text: "NEXT",
				destination: EmptyView()
			)
		}
	}
}
#endif
