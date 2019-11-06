import SwiftUI

struct SideBarDeckRowDueCardsBadge: View {
	let count: Int
	
	var body: some View {
		Text(String(count))
	}
}

#if DEBUG
struct SideBarDeckRowDueCardsBadge_Previews: PreviewProvider {
	static var previews: some View {
		SideBarDeckRowDueCardsBadge(count: 23)
	}
}
#endif
