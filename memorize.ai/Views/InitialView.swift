import SwiftUI

struct InitialView: View {
	var body: some View {
		Text("InitialView")
	}
}

#if DEBUG
struct InitialView_Previews: PreviewProvider {
	static var previews: some View {
		InitialView()
	}
}
#endif
