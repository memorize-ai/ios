import SwiftUI

struct TopicPerformanceSheetView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var currentUser: User
	@ObservedObject var topic: Topic
	
	func hide() {
		presentationMode.wrappedValue.dismiss()
	}
	
	var decks: [Deck] {
		currentUser.decks.filter { deck in
			deck.topics.contains(topic.id)
		}
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
					Text(topic.name)
						.font(.muli(.bold, size: 20))
						.foregroundColor(.darkGray)
						.lineLimit(1)
					Spacer()
					xButton
				}
				.padding(.horizontal, 25)
			}
			.frame(height: 64)
			ScrollView {
				VStack(spacing: 25) {
					Text("Decks")
						.font(.muli(.bold, size: 18))
						.foregroundColor(.darkGray)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.horizontal, 25)
						.padding(.top, -6)
					Group {
						if decks.isEmpty {
							ZStack {
								Color.lightGrayBackground
								Text("Go to the marketplace for more")
									.font(.muli(.semiBold, size: 14))
									.foregroundColor(.gray)
							}
							.frame(height: 150)
						} else {
							VStack(spacing: 4) {
								ForEach(decks) { deck in
									DeckRow(
										deck: deck,
										unselectedBackgroundColor: .white,
										onClick: self.hide
									)
								}
							}
						}
					}
					.padding(.top, -12)
				}
				.padding(.top, 25)
			}
		}
	}
}

#if DEBUG
struct TopicPerformanceSheetView_Previews: PreviewProvider {
	static var previews: some View {
		TopicPerformanceSheetView(
			currentUser: PREVIEW_CURRENT_STORE.user,
			topic: .init(
				id: "0",
				name: "Geography",
				image: .init("GeographyTopic")
			)
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif
