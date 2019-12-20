import SwiftUI

struct AddCardsViewCardCell: View {
	@EnvironmentObject var model: AddCardsViewModel
	
	@ObservedObject var card: Card.Draft
	
	var section: some View {
		CustomRectangle(
			background: Color.mediumGray.opacity(0.68)
		) {
			HStack {
				Text("Add section")
					.font(.muli(.regular, size: 18))
					.foregroundColor(.lightGrayText)
				Spacer()
				Image.grayDropDownArrowHead
					.resizable()
					.renderingMode(.original)
					.aspectRatio(contentMode: .fit)
					.frame(width: 25)
					.padding(.vertical)
			}
			.padding(.horizontal)
		}
	}
	
	var front: some View {
		Text("Front")
	}
	
	var back: some View {
		Text("Back")
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white
		) {
			VStack {
				section
				Rectangle()
					.foregroundColor(.lightGrayBorder)
					.frame(height: 1)
				front
				back
			}
			.padding(.horizontal)
		}
	}
}

#if DEBUG
struct AddCardsViewCardCell_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.blue
				.edgesIgnoringSafeArea(.all)
			AddCardsViewCardCell(card: .init(
				parent: PREVIEW_CURRENT_STORE.user.decks.first!
			))
			.padding(.horizontal, 10)
		}
		.environmentObject(AddCardsViewModel(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		))
	}
}
#endif
