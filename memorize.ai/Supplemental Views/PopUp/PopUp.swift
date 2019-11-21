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
	
	var body: some View {
		GeometryReader { geometry in
			VStack(spacing: 0) {
				self.content
				PopUpDivider(horizontalPadding: 0)
				Button(action: {
					self.isShowing = false
				}) {
					ZStack {
						Color.lightGrayBackground
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
		}
	}
}

#if DEBUG
struct PopUp_Previews: PreviewProvider {
	static var previews: some View {
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
#endif
