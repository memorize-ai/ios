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
		VStack(spacing: padding) {
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
							.font(.muli(.extraBold, size: 14))
							.foregroundColor(
								mode.isLight
									? .white
									: .bluePurple
							)
							.frame(maxWidth: 300)
							.frame(height: 40)
					}
				}
				NavigationLink(
					destination: LogInView()
						.navigationBarRemoved()
				) {
					CustomRectangle(
						background: Color.clear,
						borderColor: (
							mode.isLight
								? Color.bluePurple
								: Color.white
						).opacity(0.4),
						borderWidth: 2
					) {
						Text("LOG IN")
							.font(.muli(.extraBold, size: 14))
							.foregroundColor(
								mode.isLight
									? .bluePurple
									: .white
							)
							.frame(maxWidth: 300)
							.frame(height: 40)
					}
				}
			}
		}
		.padding(padding)
		.padding(.bottom, 8)
		.frame(maxWidth: .infinity)
		.background(mode.isLight ? Color.white : Color.bluePurple)
		.animation(.linear(duration: 0.15))
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
