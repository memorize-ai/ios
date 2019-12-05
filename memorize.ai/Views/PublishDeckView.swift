import SwiftUI

struct PublishDeckView: View {
	@ObservedObject var model: PublishDeckViewModel
		
	init(deck: Deck? = nil) {
		model = .init(deck: deck)
	}
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				HomeViewTopGradient(
					addedHeight: geometry.safeAreaInsets.top
				)
				.edgesIgnoringSafeArea(.all)
				VStack {
					PublishDeckViewTopControls()
						.environmentObject(self.model)
						.padding(.horizontal, 23)
					PublishDeckViewContentBox()
						.environmentObject(self.model)
						.padding(.horizontal, 8)
					Spacer() // TODO: Remove this
				}
			}
		}
	}
}

#if DEBUG
struct PublishDeckView_Previews: PreviewProvider {
	static var previews: some View {
		PublishDeckView()
	}
}
#endif
