import SwiftUI

struct PopUp<Content: View>: View {
	@Binding var isShowing: Bool
	
	let content: Content
	
	init(
		isShowing: Binding<Bool>,
		@ViewBuilder content: () -> Content
	) {
		_isShowing = isShowing
		self.content = content()
	}
	
	func hide() {
		// TODO: Hide view with animation
		isShowing = false
	}
	
	var body: some View {
		ZStack(alignment: .bottom) {
			Color.black
				.opacity(isShowing ? 0.2 : 0)
				.onTapGesture(perform: hide)
				.edgesIgnoringSafeArea(.all)
			VStack(spacing: 0) {
				self.content
				PopUpDivider(horizontalPadding: 0)
				Button(action: hide) {
					ZStack {
						Color.lightGrayBackground
							.edgesIgnoringSafeArea(.all)
						HStack(spacing: 20) {
							XButton(.purple, height: 15)
							Text("Cancel")
								.font(.muli(.extraBold, size: 17))
								.foregroundColor(.darkGray)
							Spacer()
						}
						.padding(.horizontal, 30)
					}
				}
				.frame(height: 50)
			}
			.background(Color.white)
		}
	}
}

#if DEBUG
struct PopUp_Previews: PreviewProvider {
	static var previews: some View {
		ZStack(alignment: .bottom) {
			Color.lightGrayBackground
			PopUp(isShowing: .constant(true)) {
				PopUpButton(
					icon: XButton(.purple, height: 15),
					text: "Remove",
					textColor: .extraPurple
				) {}
				PopUpDivider()
				PopUpButton(
					icon: XButton(.purple, height: 15),
					text: "Remove",
					textColor: .extraPurple
				) {}
			}
		}
	}
}
#endif
