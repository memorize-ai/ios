import SwiftUI

struct UserLevelView: View {
	var body: some View {
		Text("UserLevelView")
	}
}

#if DEBUG
struct UserLevelView_Previews: PreviewProvider {
	static var previews: some View {
		UserLevelView()
	}
}
#endif
