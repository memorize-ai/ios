import SwiftUI

struct PublishDeckViewContentBox: View {
	@EnvironmentObject var model: PublishDeckViewModel
	
	var body: some View {
		Text("PublishDeckViewContentBox")
	}
}

#if DEBUG
struct PublishDeckViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		PublishDeckViewContentBox()
			.environmentObject(PublishDeckViewModel())
	}
}
#endif
