import SwiftUI

struct PublishDeckView: View {
	@EnvironmentObject var model: PublishDeckViewModel
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				HomeViewTopGradient(
					addedHeight: geometry.safeAreaInsets.top
				)
				.edgesIgnoringSafeArea(.all)
				VStack {
					PublishDeckViewTopControls()
						.padding(.horizontal, 23)
					ScrollView {
						PublishDeckViewContentBox()
							.padding(.horizontal, 12)
					}
				}
			}
		}
	}
}

#if DEBUG
struct PublishDeckView_Previews: PreviewProvider {
	static var previews: some View {
		PublishDeckView()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif
