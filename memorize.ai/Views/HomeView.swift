import SwiftUI

struct HomeView: View {
	var body: some View {
		Text("memorize.ai")
	}
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
	}
}
#endif
