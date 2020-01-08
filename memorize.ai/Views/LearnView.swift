import SwiftUI

struct LearnView: View {
	@EnvironmentObject var model: LearnViewModel
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				ZStack(alignment: .top) {
					Group {
						Color.lightGrayBackground
						HomeViewTopGradient(
							colors: [
								.init(#colorLiteral(red: 0.03529411765, green: 0.6156862745, blue: 0.4117647059, alpha: 1)),
								.init(#colorLiteral(red: 0.7529411765, green: 0.8862745098, blue: 0.2549019608, alpha: 1))
							],
							addedHeight: geometry.safeAreaInsets.top
						)
					}
					.edgesIgnoringSafeArea(.all)
					VStack {
						Group {
							LearnViewTopControls()
							LearnViewSliders()
						}
						.padding(.horizontal, 23)
						LearnViewCardSection(deck: self.model.deck)
							.padding(.top, 6)
							.padding(.horizontal, 8)
						LearnViewFooter()
							.frame(height: 80)
					}
				}
				.blur(radius: self.model.isPopUpShowing ? 5 : 0)
				.disabled(self.model.isPopUpShowing)
				.onTapGesture {
					if self.model.isWaitingForRating { return }
					self.model.waitForRating()
				}
				LearnViewPopUp()
			}
		}
		.sheet(isPresented: $model.shouldShowRecap) {
			LearnRecapView()
		}
		.onAppear(perform: model.loadNextCard)
	}
}

#if DEBUG
struct LearnView_Previews: PreviewProvider {
	static var previews: some View {
		LearnView()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(LearnViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil
			))
	}
}
#endif
