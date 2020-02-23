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
				Page.Screenshot(.initialViewReviewScreenshot)
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
				LinearGradient(
					gradient: .init(colors: [
						.init(#colorLiteral(red: 0.03529411765, green: 0.6156862745, blue: 0.4117647059, alpha: 1)),
						.init(#colorLiteral(red: 0.7529411765, green: 0.8862745098, blue: 0.2549019608, alpha: 1))
					]),
					startPoint: .top,
					endPoint: .bottom
				)
			},
			content: {
				Page.Heading("Got a test tomorrow?")
				Page.SubHeading(
					"Effectively learn faster than you ever thought was possible"
				)
				Page.Screenshot(.initialViewCramScreenshot)
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
