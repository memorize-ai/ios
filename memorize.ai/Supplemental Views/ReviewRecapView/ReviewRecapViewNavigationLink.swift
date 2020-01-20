import SwiftUI

struct ReviewRecapViewNavigationLink<Label: View>: View {
	
	let label: Label
	
	init(label: () -> Label) {
		self.label = label()
	}
	
	var body: some View {
		NavigationLink(
			destination: ReviewRecapView()
				.navigationBarRemoved()
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
