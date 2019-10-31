import SwiftUI
import FirebaseFirestore
import PromiseKit

final class Deck: ObservableObject, Identifiable, Equatable {
	let id: String
	
	@Published var image: Image?
	@Published var name: String
	
	@Published var imageLoadingState = LoadingState.none
	
	init(id: String, image: Image? = nil, name: String) {
		self.id = id
		self.image = image
		self.name = name
	}
	
	@discardableResult
	func loadImage() -> Self {
		imageLoadingState = .loading()
		storage.child("decks/\(id)").getData().done { data in
			guard let image = Image(data: data) else {
				return self.imageLoadingState = .failure(
					message: "Malformed data"
				)
			}
			self.image = image
			self.imageLoadingState = .success()
		}.catch { error in
			self.imageLoadingState = .failure(
				message: error.localizedDescription
			)
		}
		return self
	}
	
	@discardableResult
	func updatePublicDataFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		name = snapshot.get("name") as? String ?? name
		return self
	}
	
	static func fromId(_ id: String) -> Promise<Deck> {
		var didFulfill = false
		var deck: Deck?
		return .init { seal in
			firestore.document("decks/\(id)").addSnapshotListener { snapshot, error in
				guard error == nil, let snapshot = snapshot else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				if didFulfill {
					deck?.updatePublicDataFromSnapshot(snapshot)
				} else {
					didFulfill = true
					deck = .init(
						id: id,
						name: snapshot.get("name") as? String ?? "Unknown"
					)
					seal.fulfill(deck!)
				}
			}
		}
	}
	
	static func == (lhs: Deck, rhs: Deck) -> Bool {
		lhs.id == rhs.id
	}
}
