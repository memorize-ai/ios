import SwiftUI

struct PublishDeckView: View {
	@ObservedObject var model: PublishDeckViewModel
		
	init(deck: Deck? = nil) {
		model = .init(deck: deck)
	}
	
	var body: some View {
		Text("PublishDeckView")
	}
}

#if DEBUG
struct PublishDeckView_Previews: PreviewProvider {
	static var previews: some View {
		PublishDeckView()
	}
}
#endif
