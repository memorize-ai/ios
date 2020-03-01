import SwiftUI

struct NavigateTo<Destination: View>: View {
	@Binding var isActive: Bool
	
	let destination: Destination
	
	init(
		_ destination: Destination,
		when isActive: Binding<Bool>
	) {
		_isActive = isActive
		self.destination = destination
	}
	
	var body: some View {
		NavigationLink(
			destination: destination
				.navigationBarRemoved(),
			isActive: $isActive
		) {
			Text("NavigationLink")
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
