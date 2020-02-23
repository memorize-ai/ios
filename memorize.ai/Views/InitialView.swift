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
				Page.Gradient(colors: [.bluePurple, .lightBlue])
			},
			content: {
				Page.logo
				Page.Heading("Spaced Repetition with Artificial Intelligence")
				Page.Screenshot(.initialViewReviewScreenshot)
					.padding(.horizontal, 30)
			},
			bottomAlignedContent: {
				Image.initialViewReviewScreenshotBubble
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: SCREEN_SIZE.width - 20 * 2)
					.padding(.bottom, 8)
			}
		),
		Page(
			mode: .dark,
			background: {
				Page.Gradient(colors: [.init(#colorLiteral(red: 0.03529411765, green: 0.6156862745, blue: 0.4117647059, alpha: 1)), .init(#colorLiteral(red: 0.7529411765, green: 0.8862745098, blue: 0.2549019608, alpha: 1))])
			},
			content: {
				Page.Heading("Got a test tomorrow?")
				Page.SubHeading(
					"Effectively learn faster than you ever thought was possible"
				)
				Page.Screenshot(.initialViewCramScreenshot)
					.padding(.horizontal, 30)
			}
		),
		Page(
			mode: .dark,
			background: {
				Page.Gradient(colors: [.bluePurple, .lightBlue])
			},
			content: {
				Page.Heading("Flash-cards have never looked so good")
				Page.SubHeading("The most advanced editor on the market")
				Page.Screenshot(.initialViewEditorScreenshot)
					.padding(.leading, 30)
					.padding(.trailing, 30 * 28 / 101)
			}
		),
		Page(
			mode: .dark,
			background: {
				Page.Gradient(colors: [.init(#colorLiteral(red: 0.03529411765, green: 0.6156862745, blue: 0.4117647059, alpha: 1)), .init(#colorLiteral(red: 0.7529411765, green: 0.8862745098, blue: 0.2549019608, alpha: 1))])
			},
			content: {
				Page.Heading("Explore 7,000+ decks")
				Page.SubHeading("Recommendations based on what you like")
				Page.Screenshot(.initialViewMarketScreenshot)
					.padding(.horizontal, 30)
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
