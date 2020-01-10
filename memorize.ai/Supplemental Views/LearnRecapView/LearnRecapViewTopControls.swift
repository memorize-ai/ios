import SwiftUI

struct LearnRecapViewTopControls: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		HStack(spacing: 22) {
			Text("Recap")
				.font(.muli(.bold, size: 20))
				.foregroundColor(.white)
			Spacer()
			NavigationLink(
				destination: MainTabView(currentUser: currentStore.user)
					.environmentObject(currentStore)
					.navigationBarRemoved()
			) {
				CustomRectangle(
					background: Color.transparent,
					borderColor: .transparentLightGray,
					borderWidth: 1.5
				) {
					Text("CONTINUE")
						.font(.muli(.extraBold, size: 17))
						.foregroundColor(Color.white.opacity(0.7))
						.padding(.horizontal, 10)
						.frame(height: 30)
				}
			}
		}
	}
}

#if DEBUG
struct LearnRecapViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewTopControls()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif
