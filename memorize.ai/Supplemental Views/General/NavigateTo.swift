import SwiftUI

struct NavigateTo<Destination: View>: View {
	let destination: Destination
	
	@Binding var isActive: Bool
	
	init(
		_ destination: Destination,
		when isActive: Binding<Bool>
	) {
		self.destination = destination
		_isActive = isActive
	}
	
	var body: some View {
		NavigationLink(
			destination: destination
				.removeNavigationBar(),
			isActive: $isActive
		) {
			EmptyView()
		}
		.hidden()
	}
}

#if DEBUG
struct NavigateTo_Previews: PreviewProvider {
	static var previews: some View {
		NavigateTo(Text("Hello!"), when: .constant(false))
	}
}
#endif
