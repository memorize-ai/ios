import SwiftUI
import FirebaseFirestore

struct DecksViewOrderSectionsSheetView: View {
	@ObservedObject var deck: Deck
	
	func onSectionMove(from source: Int, to destination: Int) {
		print(source, destination)
		
		let batch = firestore.batch()
		
		batch.updateData(
			["index": destination],
			forDocument: deck.sections[source].documentReference
		)
		
		if source < destination {
			for section in deck.sections[source..<destination] {
				batch.updateData(
					["index": FieldValue.increment(-1.0)],
					forDocument: section.documentReference
				)
			}
		} else {
			for section in deck.sections[destination + 1...source] {
				batch.updateData(
					["index": FieldValue.increment(1.0)],
					forDocument: section.documentReference
				)
			}
		}
		
		batch.commit()
	}
	
	var body: some View {
		List {
			ForEach(deck.sections) { section in
				Text(section.name)
			}
			.onMove { sources, destination in
				guard
					let source = sources.first,
					source != destination
				else { return }
				self.onSectionMove(
					from: source,
					to: destination
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
