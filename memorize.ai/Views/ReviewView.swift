import SwiftUI

struct ReviewView: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: ReviewViewModel
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				ZStack(alignment: .top) {
					Group {
						Color.lightGrayBackground
						HomeViewTopGradient(
							addedHeight: geometry.safeAreaInsets.top
						)
					}
					.edgesIgnoringSafeArea(.all)
					VStack {
						ReviewViewTopControls()
							.padding(.horizontal, 23)
						ReviewViewCardSection()
							.padding(.top, 6)
							.padding(.horizontal, 8)
						ReviewViewFooter()
							.frame(height: 80)
					}
				}
				.blur(radius: self.model.isPopUpShowing ? 5 : 0)
				.onTapGesture {
					if self.model.isWaitingForRating { return }
					self.model.waitForRating()
				}
				.disabled(self.model.isPopUpShowing)
				ReviewViewPopUp()
				NavigateTo(
					ReviewRecapView()
						.environmentObject(self.currentStore)
						.environmentObject(self.model)
						.removeNavigationBar(),
					when: self.$model.shouldShowRecap
				)
			}
		}
		.onAppear {
			self.model.loadNextCard()
		}
	}
}

#if DEBUG
struct ReviewView_Previews: PreviewProvider {
	static var previews: some View {
		ReviewView()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(ReviewViewModel(
				user: PREVIEW_CURRENT_STORE.user,
				deck: nil,
				section: nil
			))
	}
}
#endif
