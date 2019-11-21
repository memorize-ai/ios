import SwiftUI

struct PopUp<Content: View>: View {
	@Binding var isShowing: Bool
	
	let contentHeight: CGFloat
	let content: Content
	
	init(
		isShowing: Binding<Bool>,
		contentHeight: CGFloat,
		@ViewBuilder content: () -> Content
	) {
		_isShowing = isShowing
		self.contentHeight = contentHeight
		self.content = content()
	}
	
	var maxHeight: CGFloat {
		SCREEN_SIZE.height * 2 / 3
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
				if contentHeight > maxHeight {
					ScrollView {
						VStack(spacing: 0) {
							content
						}
					}
					.frame(height: maxHeight)
				} else {
					content
				}
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
			PopUp(isShowing: .constant(true), contentHeight: 50 * 2 + 1) {
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
