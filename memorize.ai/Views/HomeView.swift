import SwiftUI

struct HomeView: View {
	var body: some View {
		Text("HomeView")
	}
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
	}
}
#endif
