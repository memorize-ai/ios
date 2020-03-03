import SwiftUI

struct InitialView: View {
	enum Mode {
		case light
		case dark
		
		var isLight: Bool { self == .light }
		var isDark: Bool { self == .dark }
	}
	
	static let initialViewEditorScreenshotWidth = min(SCREEN_SIZE.width - 30 * 2, 500)
	static let pages = [
		Page(
			mode: .light,
			background: {
				Color.bluePurple
			},
			content: {
				Page.logo
					.frame(width: min(SCREEN_SIZE.width - 40 * 2, 500))
				Spacer()
				Image.initialViewBrain
					.resizable()
					.aspectRatio(contentMode: .fit)
					.padding(.horizontal, 20)
					.padding(.vertical, -30)
				Spacer()
				Page.Heading("Truly effective memorization")
			}
		),
		Page(
			mode: .dark,
			background: {
				Page.Gradient(colors: [.bluePurple, .lightBlue])
			},
			content: {
				Page.Heading("Artificial Intelligence")
				Page.SubHeading(
					"Recall attempts spaced just right for the most effective and efficient studying"
				)
				Page.Screenshot(.initialViewReviewScreenshot)
					.frame(width: min(SCREEN_SIZE.width - 30 * 2, 500))
			},
			bottomAlignedContent: {
				Image.initialViewReviewScreenshotBubble
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: min(SCREEN_SIZE.width - 20 * 2, 540))
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
					.frame(width: min(SCREEN_SIZE.width - 30 * 2, 500))
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
					.frame(width: initialViewEditorScreenshotWidth)
					.offset(x: initialViewEditorScreenshotWidth * 28 / 101)
			}
		),
		Page(
			mode: .dark,
			background: {
				Page.Gradient(colors: [.init(#colorLiteral(red: 0.03529411765, green: 0.6156862745, blue: 0.4117647059, alpha: 1)), .init(#colorLiteral(red: 0.7529411765, green: 0.8862745098, blue: 0.2549019608, alpha: 1))])
			},
			content: {
				Page.Heading("Explore 40,000+ decks")
				Page.SubHeading("Recommendations based on what you like")
				Page.Screenshot(.initialViewMarketScreenshot)
					.frame(width: min(SCREEN_SIZE.width - 30 * 2, 500))
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
		.navigationViewStyle(StackNavigationViewStyle())
	}
}

#if DEBUG
struct InitialView_Previews: PreviewProvider {
	static var previews: some View {
		InitialView()
	}
}
#endif
