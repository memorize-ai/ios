import SwiftUI
import FirebaseFirestore
import PromiseKit
import LoadingState

final class Card: ObservableObject, Identifiable, Equatable, Hashable {
	let id: String
	let parent: Deck
	
	@Published var sectionId: String?
	@Published var front: String
	@Published var back: String
	@Published var numberOfViews: Int
	@Published var numberOfReviews: Int
	@Published var numberOfSkips: Int
	
	@Published var userData: UserData?
	@Published var userDataLoadingState = LoadingState()
	
	@Published var previewImage: Image?
	@Published var previewImageLoadingState = LoadingState()
	
	var snapshot: DocumentSnapshot?
	
	init(
		id: String,
		parent: Deck,
		sectionId: String?,
		front: String,
		back: String,
		numberOfViews: Int,
		numberOfReviews: Int,
		numberOfSkips: Int,
		userData: UserData? = nil,
		previewImage: Image? = nil,
		snapshot: DocumentSnapshot? = nil
	) {
		self.id = id
		self.parent = parent
		self.sectionId = sectionId
		self.front = front
		self.back = back
		self.numberOfViews = numberOfViews
		self.numberOfReviews = numberOfReviews
		self.numberOfSkips = numberOfSkips
		self.userData = userData
		self.previewImage = previewImage
		self.snapshot = snapshot
	}
	
	convenience init(snapshot: DocumentSnapshot, parent: Deck) {
		let sectionId = snapshot.get("section") as? String ?? ""
		self.init(
			id: snapshot.documentID,
			parent: parent,
			sectionId: sectionId.isEmpty ? nil : sectionId,
			front: snapshot.get("front") as? String ?? "(empty)",
			back: snapshot.get("back") as? String ?? "(empty)",
			numberOfViews: snapshot.get("viewCount") as? Int ?? 0,
			numberOfReviews: snapshot.get("reviewCount") as? Int ?? 0,
			numberOfSkips: snapshot.get("skipCount") as? Int ?? 0,
			snapshot: snapshot
		)
	}
	
	var isNew: Bool {
		userData?.isNew ?? true
	}
	
	var isDue: Bool {
		guard let userData = userData else { return false }
		return userData.isNew || userData.dueDate <= .now
	}
	
	var dueMessage: String {
		guard let dueDate = userData?.dueDate else { return "" }
		return "Due \(Date().compare(against: dueDate))"
	}
	
	var previewImageUrl: String? {
		guard let imgRange = front.range(
			of: #"<\s*img[^>]*src="(.+?)"[^>]*>"#,
			options: .regularExpression
		) else { return nil }
		
		let img = front[imgRange]
		
		guard let srcRange = img.range(
			of: #"src="(.+?)""#,
			options: .regularExpression
		) else { return nil }
		
		return .init(img[srcRange].dropFirst(5).dropLast(1))
	}
	
	@discardableResult
	func loadPreviewImage() -> Self {
		guard
			previewImageLoadingState.isNone,
			let url = try? previewImageUrl?.asURL()
		else { return self }
		previewImageLoadingState.startLoading()
		URLSession.shared.dataTask(with: url) { data, _, error in
			guard error == nil, let data = data, let image = Image(data: data) else {
				DispatchQueue.main.async {
					self.previewImageLoadingState.fail(error: error ?? UNKNOWN_ERROR)
				}
				return
			}
			DispatchQueue.main.async {
				self.previewImage = image
				self.previewImageLoadingState.succeed()
			}
		}.resume()
		return self
	}
	
	static func stripFormatting(_ text: String) -> String {
		replaceHtmlElements(replaceHtmlVoidElements(text))
			.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
			.replacingOccurrences(of: "&amp;", with: "&")
			.replacingOccurrences(of: "&lt;", with: "<")
			.replacingOccurrences(of: "&gt;", with: ">")
	}
	
	private static func replaceHtmlElements(_ text: String) -> String {
		HTML_ELEMENTS.reduce(text) { acc, element in
			acc.replacingOccurrences(
				of: "<\\s*\(element)[^>]*>(.*?)<\\s*/\\s*\(element)\\s*>",
				with: "$1 ",
				options: .regularExpression
			)
		}
	}
	
	private static func replaceHtmlVoidElements(_ text: String) -> String {
		text.replacingOccurrences(
			of: HTML_VOID_ELEMENTS
				.map { "<\\s*\($0)[^>]*>" }
				.joined(separator: "|"),
			with: " ",
			options: .regularExpression
		)
	}
	
	@discardableResult
	func updateFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		self.snapshot = snapshot
		
		let sectionId = snapshot.get("section") as? String ?? ""
		self.sectionId = sectionId.isEmpty ? nil : sectionId
		front = snapshot.get("front") as? String ?? front
		back = snapshot.get("back") as? String ?? back
		numberOfViews = snapshot.get("viewCount") as? Int ?? 0
		numberOfReviews = snapshot.get("reviewCount") as? Int ?? 0
		numberOfSkips = snapshot.get("skipCount") as? Int ?? 0
		
		return self
	}
	
	@discardableResult
	func updateUserDataFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		guard snapshot.exists else {
			userData = nil
			return self
		}
		
		if userData == nil {
			userData = .init(snapshot: snapshot)
		} else {
			userData?.updateFromSnapshot(snapshot)
		}
		
		return self
	}
	
	@discardableResult
	func review(rating: PerformanceRating, viewTime: Int) -> Promise<Bool> {
		functions.httpsCallable("reviewCard")
			.call(data: [
				"deck": parent.id,
				"section": sectionId ?? "",
				"card": id,
				"rating": rating.rawValue,
				"viewTime": viewTime
			])
			.compactMap { $0.data as? Bool }
	}
	
	@discardableResult
	func loadUserData(forUser user: User, deck: Deck) -> Self {
		guard userDataLoadingState.isNone else { return self }
		userDataLoadingState.startLoading()
		user
			.documentReference
			.collection("decks/\(deck.id)/cards")
			.document(id)
			.addSnapshotListener { snapshot, error in
				guard
					error == nil,
					let snapshot = snapshot
				else {
					self.userDataLoadingState.fail(error: error ?? UNKNOWN_ERROR)
					return
				}
				self.updateUserDataFromSnapshot(snapshot)
				self.userDataLoadingState.succeed()
			}
		return self
	}
	
	static func == (lhs: Card, rhs: Card) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
