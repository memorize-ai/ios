import SwiftUI

struct InitialView: View {
	var body: some View {
		VStack {
			Spacer()
			ZStack(alignment: .bottom) {
				InitialViewBottomGradient()
				InitialViewBottomButtons()
			}
		}
	}
}

#if DEBUG
struct InitialView_Previews: PreviewProvider {
	static var previews: some View {
		InitialView()
	}
}
#endif
