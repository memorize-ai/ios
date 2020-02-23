import SwiftUI

struct InitialViewFooter: View {
	let geometry: GeometryProxy
	let mode: InitialView.Mode
	let currentPageIndex: Int
	
	var padding: CGFloat {
		max(20, geometry.safeAreaInsets.bottom)
	}
	
	var dot: some View {
		Circle()
			.foregroundColor(
				mode.isLight
					? .bluePurple
					: .white
			)
			.frame(width: 10, height: 10)
	}
	
	var body: some View {
		VStack(spacing: 30) {
			HStack(spacing: 6) {
				ForEach(0..<InitialView.pages.count) { pageIndex in
					self.dot
						.opacity(
							pageIndex == self.currentPageIndex
								? 1
								: 0.5
						)
				}
			}
			HStack(spacing: 16) {
				NavigationLink(
					destination: SignUpView()
						.navigationBarRemoved()
				) {
					CustomRectangle(
						background: mode.isLight
							? Color.bluePurple
							: Color.white
					) {
						Text("SIGN UP")
							.font(.muli(.bold, size: 14))
							.foregroundColor(
								mode.isLight
									? .white
									: .bluePurple
							)
							.frame(maxWidth: 300)
							.frame(height: 35)
					}
				}
				NavigationLink(
					destination: LogInView()
						.navigationBarRemoved()
				) {
					CustomRectangle(
						background: Color.clear,
						borderColor: Color.white.opacity(0.4),
						borderWidth: 2
					) {
						Text("LOG IN")
							.font(.muli(.bold, size: 14))
							.foregroundColor(
								mode.isLight
									? .bluePurple
									: .white
							)
							.frame(maxWidth: 300)
							.frame(height: 35)
					}
				}
			}
		}
		.padding(padding)
		.background(mode.isLight ? Color.white : Color.bluePurple)
	}
}

#if DEBUG
struct InitialViewFooter_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geometry in
			InitialViewFooter(
				geometry: geometry,
				mode: .dark,
				currentPageIndex: 1
			)
		}
	}
}
#endif
