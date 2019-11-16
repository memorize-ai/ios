import SwiftUI

struct DecksView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		Text("DecksView, Current deck: \(currentStore.selectedDeck?.name ?? "(none)")")
	}
}

#if DEBUG
struct DecksView_Previews: PreviewProvider {
	static var previews: some View {
		DecksView()
	}
}
#endif
