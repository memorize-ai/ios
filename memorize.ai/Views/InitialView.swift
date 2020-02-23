import SwiftUI

struct InitialView: View {
	enum Mode {
		case light
		case dark
		
		var isLight: Bool { self == .light }
		var isDark: Bool { self == .dark }
	}
	
	static let pages = [
		Page(
			mode: .dark,
			background: {
				LinearGradient(
					gradient: .init(colors: [
						.bluePurple,
						.lightBlue
					]),
					startPoint: .top,
					endPoint: .bottom
				)
			},
			content: {
				Page.logo
				Page.Heading("Spaced Repetition with Artificial Intelligence")
				Image.initialViewReviewScreenshot
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: SCREEN_SIZE.width - 30 * 2)
			},
			bottomAlignedContent: {
				Image.initialViewReviewScreenshotBubble
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: SCREEN_SIZE.width - 30 * 2)
					.padding(.bottom, 8)
			}
		),
		Page(
			mode: .dark,
			background: {
				EmptyView()
			},
			content: {
				EmptyView()
			}
		),
		Page(
			mode: .dark,
			background: {
				EmptyView()
			},
			content: {
				EmptyView()
			}
		),
		Page(
			mode: .dark,
			background: {
				EmptyView()
			},
			content: {
				EmptyView()
			}
		),
		Page(
			mode: .light,
			background: {
				EmptyView()
			},
			content: {
				EmptyView()
			}
		)
	]
	
	@State var currentPageIndex = 0
	
	var mode: Mode {
		Self.pages[currentPageIndex].mode
	}
	
	var body: some View {
		NavigationView {
			GeometryReader { geometry in
				VStack(spacing: 0) {
					InitialViewPages(
						currentPageIndex: self.$currentPageIndex
					)
					InitialViewFooter(
						geometry: geometry,
						mode: self.mode,
						currentPageIndex: self.currentPageIndex
					)
				}
				.edgesIgnoringSafeArea(.all)
			}
			.navigationBarRemoved()
		}
	}
}

#if DEBUG
struct InitialView_Previews: PreviewProvider {
	static var previews: some View {
		InitialView()
	}
}
#endif
