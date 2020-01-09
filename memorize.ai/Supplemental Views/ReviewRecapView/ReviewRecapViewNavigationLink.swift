import SwiftUI

struct ReviewRecapViewNavigationLink<Label: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: ReviewViewModel
	
	let label: Label
	
	init(label: () -> Label) {
		self.label = label()
	}
	
	var body: some View {
		NavigationLink(
			destination: ReviewRecapView()
				.environmentObject(currentStore)
				.environmentObject(model)
				.removeNavigationBar()
		) {
			label
		}
	}
}

#if DEBUG
struct ReviewRecapViewNavigationLink_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewNavigationLink {
			Text("Recap")
		}
	}
}
#endif
