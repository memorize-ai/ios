import SwiftUI
import FirebaseFirestore

struct DecksViewOrderSectionsSheetView: View {
	@ObservedObject var deck: Deck
	
	func onSectionMove(from source: Int, to destination: Int) {
		if source == destination { return }
		
		let section = deck.sections.remove(at: source)
		deck.sections.insert(section, at: destination)
		
		let batch = firestore.batch()
		
		for i in 0..<deck.sections.count {
			batch.updateData(
				["index": i],
				forDocument: deck.sections[i].documentReference
			)
		}

		batch.commit()
	}
	
	var body: some View {
		List {
			ForEach(deck.sections) { section in
				Text(section.name)
			}
			.onMove { sources, destination in
				guard let source = sources.first else { return }
				print(source, destination)
				self.onSectionMove(
					from: source,
					to: destination - *(source < destination)
				)
			}
		}
		.environment(\.editMode, .constant(.active))
	}
}

#if DEBUG
struct DecksViewOrderSectionsSheetView_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewOrderSectionsSheetView(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
	}
}
#endif
