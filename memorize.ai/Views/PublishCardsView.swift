import SwiftUI

struct PublishCardsView: View {
	@EnvironmentObject var model: PublishCardsViewModel
	
	var body: some View {
		Text("Hello, World!")
	}
}

#if DEBUG
struct PublishCardsView_Previews: PreviewProvider {
	static var previews: some View {
		PublishCardsView()
			.environmentObject(PublishCardsViewModel())
	}
}
#endif
