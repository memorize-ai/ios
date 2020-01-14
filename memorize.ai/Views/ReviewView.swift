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
							.padding(.top, 16)
					}
				}
				.blur(radius: self.model.isPopUpShowing ? 5 : 0)
				.onTapGesture {
					if
						self.model.isWaitingForRating ||
						self.model.current == nil
					{ return }
					self.model.waitForRating()
				}
				.disabled(self.model.isPopUpShowing)
				ReviewViewPopUp()
				NavigateTo(
					ReviewRecapView()
						.environmentObject(self.currentStore)
						.environmentObject(self.model)
						.navigationBarRemoved(),
					when: self.$model.shouldShowRecap
				)
			}
		}
		.onAppear {
			self.model.initialXP = self.currentStore.user.xp
			self.model.loadNextCard()
		}
	}
}

#if DEBUG
struct ReviewView_Previews: PreviewProvider {
	static var previews: some View {
		let model = ReviewViewModel(
			user: PREVIEW_CURRENT_STORE.user,
			deck: nil,
			section: nil
		)
		model.isWaitingForRating = true
		return ReviewView()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(model)
	}
}
#endif
