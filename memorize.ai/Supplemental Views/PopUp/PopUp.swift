import SwiftUI
import FirebaseAnalytics

struct PopUp<Content: View>: View {
	@Binding var isShowing: Bool {
		didSet {
			playHaptic()
		}
	}
	
	let contentHeight: CGFloat
	let content: Content
	let onHide: (() -> Void)?
	
	init(
		isShowing: Binding<Bool>,
		contentHeight: CGFloat,
		onHide: (() -> Void)? = nil,
		@ViewBuilder content: () -> Content
	) {
		_isShowing = isShowing
		self.contentHeight = contentHeight
		self.onHide = onHide
		self.content = content()
	}
	
	var maxContentHeight: CGFloat {
		SCREEN_SIZE.height * 2 / 3
	}
	
	var realContentHeight: CGFloat {
		min(contentHeight, maxContentHeight)
	}
	
	func hide() {
		Analytics.logEvent("hide_pop_up", parameters: [
			"view": "PopUp"
		])
		
		popUpWithAnimation {
			isShowing = false
		}
		onHide?()
	}
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .bottom) {
				Color.black
					.opacity(self.isShowing ? 0.2 : 0)
					.onTapGesture(perform: self.hide)
					.edgesIgnoringSafeArea(.all)
				VStack(spacing: 0) {
					if self.contentHeight > self.maxContentHeight {
						ScrollView {
							VStack(spacing: 0) {
								self.content
							}
						}
						.frame(height: self.maxContentHeight)
					} else {
						self.content
					}
					PopUpDivider(horizontalPadding: 0)
					Button(action: self.hide) {
						ZStack(alignment: .top) {
							Color.lightGrayBackground
							HStack(spacing: 20) {
								XButton(.purple, height: 15)
									.padding(.horizontal, 2.5)
								Text("Cancel")
									.font(.muli(.extraBold, size: 17))
									.foregroundColor(.darkGray)
								Spacer()
							}
							.padding(.horizontal, 30)
							.padding(.top, 13)
						}
					}
					.frame(height: 50 + geometry.safeAreaInsets.bottom)
				}
				.background(Color.white)
				.offset(
					y: self.isShowing
						? 0
						: self.realContentHeight + geometry.safeAreaInsets.bottom + 51
				)
			}
		}
		.edgesIgnoringSafeArea(.all)
	}
}

#if DEBUG
struct PopUp_Preview: View {
	@State var isShowing = true
	
	var body: some View {
		ZStack {
			Color.blue
				.edgesIgnoringSafeArea(.all)
			Button(action: {
				popUpWithAnimation {
					self.isShowing = true
				}
			}) {
				Text("Show pop-up")
					.foregroundColor(.white)
			}
			PopUp(isShowing: $isShowing, contentHeight: 50 * 2 + 1) {
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

struct PopUp_Previews: PreviewProvider {
	static var previews: some View {
		PopUp_Preview()
	}
}
#endif
