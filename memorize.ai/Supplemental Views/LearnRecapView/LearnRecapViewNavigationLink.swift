import SwiftUI

struct LearnRecapViewNavigationLink<Label: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: LearnViewModel
	
	let label: Label
	
	init(label: () -> Label) {
		self.label = label()
	}
	
	var body: some View {
		NavigationLink(
			destination: LearnRecapView()
				.environmentObject(currentStore)
				.environmentObject(model)
				.navigationBarRemoved()
		) {
			label
		}
	}
}

#if DEBUG
struct LearnRecapViewNavigationLink_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewNavigationLink {
			Text("Recap")
		}
	}
}
#endif
