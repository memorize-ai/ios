import SwiftUI

struct TopicPerformanceSheetView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var currentUser: User
	@ObservedObject var topic: Topic
	
	var decks: [Deck] {
		currentUser.decks.filter { deck in
			deck.topics.contains(topic.id)
		}
	}
	
	var xButton: some View {
		Button(action: {
			self.presentationMode.wrappedValue.dismiss()
		}) {
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
					Group {
						Rectangle()
							.frame(height: 200) // TODO: Change to actual graph
						Rectangle()
							.foregroundColor(.lightGrayBorder)
							.frame(height: 1)
						HStack {
							Text("Decks")
								.font(.muli(.bold, size: 18))
								.foregroundColor(.darkGray)
								.padding(.top, -6)
							Spacer()
							Button(action: {
								// TODO: Go to search view with selected topic
							}) {
								HStack {
									Image(systemName: .plusCircle)
									Text("Add")
										.font(.muli(.semiBold, size: 15))
								}
							}
						}
					}
					.padding(.horizontal, 25)
					if !decks.isEmpty {
						VStack(spacing: 4) {
							ForEach(decks) { deck in
								DeckRow(
									deck: deck,
									selectedDeck: self.$currentStore.selectedDeck,
									unselectedBackgroundColor: .white
								)
							}
						}
						.padding(.top, -12)
					}
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
				image: .init("GeographyTopic"),
				topDecks: []
			)
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif
