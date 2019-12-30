import SwiftUI

struct DecksViewPerformanceSheetView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var deck: Deck
	
	func hide() {
		presentationMode.wrappedValue.dismiss()
	}
	
	var xButton: some View {
		Button(action: hide) {
			XButton(.purple, height: 16)
		}
	}
	
	var body: some View {
		VStack(spacing: 0) {
			ZStack {
				Color.lightGrayBackground
				HStack(spacing: 25) {
					Text("Performance")
						.font(.muli(.bold, size: 20))
						.foregroundColor(.darkGray)
						.lineLimit(1)
					Spacer()
					xButton
				}
				.padding(.horizontal, 25)
			}
			.frame(height: 64)
			// TODO: Add performance graph
		}
	}
}

#if DEBUG
struct DecksViewPerformanceSheetView_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewPerformanceSheetView(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
	}
}
#endif
