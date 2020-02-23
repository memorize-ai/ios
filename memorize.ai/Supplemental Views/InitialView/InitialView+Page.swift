import SwiftUI

extension InitialView {
	struct Page {
		struct Heading: View {
			let text: String
			
			init(_ text: String) {
				self.text = text
			}
			
			var body: some View {
				Text(text)
					.font(.muli(.extraBold, size: 30))
					.foregroundColor(.white)
					.multilineTextAlignment(.center)
					.frame(
						width: SCREEN_SIZE.width - 30 * 2,
						alignment: .center
					)
			}
		}
		
		struct SubHeading: View {
			let text: String
			
			init(_ text: String) {
				self.text = text
			}
			
			var body: some View {
				Text(text)
					.font(.muli(.bold, size: 30))
					.foregroundColor(Color.white.opacity(0.8))
					.multilineTextAlignment(.center)
					.frame(
						width: SCREEN_SIZE.width - 30 * 2,
						alignment: .center
					)
			}
		}
		
		static var logo: some View {
			Image.longLogo
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(maxWidth: 225)
				.padding(.horizontal, 30)
		}
		
		let mode: Mode
		let content: (GeometryProxy) -> AnyView
		
		init<Background: View, Content: View, BottomAlignedContent: View>(
			mode: Mode,
			@ViewBuilder background: @escaping () -> Background,
			@ViewBuilder content: @escaping () -> Content,
			@ViewBuilder bottomAlignedContent: @escaping () -> BottomAlignedContent
		) {
			self.mode = mode
			self.content = { geometry in
				ZStack(alignment: .bottom) {
					background()
					VStack(spacing: 20) {
						content()
					}
					.frame(height: geometry.size.height, alignment: .top)
					.padding(.top, geometry.safeAreaInsets.top)
					bottomAlignedContent()
						.padding(.bottom, geometry.safeAreaInsets.top)
				}
				.eraseToAnyView()
			}
		}
		
		init<Background: View, Content: View>(
			mode: Mode,
			@ViewBuilder background: @escaping () -> Background,
			@ViewBuilder content: @escaping () -> Content
		) {
			self.init(
				mode: mode,
				background: background,
				content: content,
				bottomAlignedContent: EmptyView.init
			)
		}
	}
}
