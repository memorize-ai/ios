import SwiftUI
import FirebaseFirestore

struct DecksViewOrderSectionsSheetView: View {
	@Environment(\.presentationMode) var presentationMode
	
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
					Text("Order sections")
						.font(.muli(.bold, size: 20))
						.foregroundColor(.darkGray)
						.lineLimit(1)
					Spacer()
					xButton
				}
				.padding(.horizontal, 25)
			}
			.frame(height: 64)
			List {
				ForEach(deck.sections) { section in
					DecksViewOrderSectionsSheetViewSectionRow(
						section: section
					)
				}
				.onMove { sources, destination in
					guard let source = sources.first else { return }
					self.onSectionMove(
						from: source,
						to: destination - *(source < destination)
					)
				}
			}
			.environment(\.editMode, .constant(.active))
		}
		.onAppear {
			UITableView.appearance().separatorStyle = .none
		}
		.onDisappear {
			UITableView.appearance().separatorStyle = .singleLine
		}
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
