import SwiftUI
import FirebaseAnalytics
import Audio

struct PopUp<Content: View>: View {
	@Binding var isShowing: Bool {
		didSet {
			Audio.impact()
		}
	}
	
	let contentHeight: CGFloat
	let content: Content
	let onHide: (() -> Void)?
	let geometry: GeometryProxy
	
	init(
		isShowing: Binding<Bool>,
		contentHeight: CGFloat,
		onHide: (() -> Void)? = nil,
		geometry: GeometryProxy,
		@ViewBuilder content: () -> Content
	) {
		_isShowing = isShowing
		self.contentHeight = contentHeight
		self.onHide = onHide
		self.geometry = geometry
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
		ZStack(alignment: .bottom) {
			Color.black
				.opacity(isShowing ? 0.2 : 0)
				.onTapGesture(perform: hide)
				.edgesIgnoringSafeArea(.all)
			VStack(spacing: 0) {
				if contentHeight > maxContentHeight {
					ScrollView {
						VStack(spacing: 0) {
							content
						}
					}
					.frame(height: maxContentHeight)
				} else {
					content
				}
				PopUpDivider(horizontalPadding: 0)
				Button(action: hide) {
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
				y: isShowing
					? 0
					: realContentHeight + geometry.safeAreaInsets.bottom + 51
			)
		}
		.edgesIgnoringSafeArea(.all)
	}
}

#if DEBUG
struct PopUp_Preview: View {
	@State var isShowing = true
	
	var body: some View {
		GeometryReader { geometry in
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
				PopUp(
					isShowing: self.$isShowing,
					contentHeight: 50 * 2 + 1,
					geometry: geometry
				) {
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
}

struct PopUp_Previews: PreviewProvider {
	static var previews: some View {
		PopUp_Preview()
	}
}
#endif
