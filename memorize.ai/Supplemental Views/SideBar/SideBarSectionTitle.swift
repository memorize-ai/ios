import SwiftUI

struct SideBarSectionTitle: View {
	let text: String
	
	init(_ text: String) {
		self.text = text
	}
	
	var body: some View {
		Text(text)
			.font(.muli(.extraBold, size: 13))
			.foregroundColor(.extraPurple)
	}
}

#if DEBUG
struct SideBarSectionTitle_Previews: PreviewProvider {
	static var previews: some View {
		SideBarSectionTitle("Due")
	}
}
#endif
