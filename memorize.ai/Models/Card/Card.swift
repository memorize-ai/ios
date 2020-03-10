import SwiftUI
import FirebaseFirestore
import PromiseKit
import Audio
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
		self.init(
			id: snapshot.documentID,
			parent: parent,
			sectionId: (snapshot.get("section") as? String)?.nilIfEmpty,
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
			of: #"<img.+?src="(.+?)".*?>"#,
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
			let urlString = previewImageUrl
		else { return self }
		
		do {
			guard let image = Image(
				data: try .init(contentsOf: try urlString.asURL())
			) else {
				previewImageLoadingState.fail(message: "Unable to load image from data")
				return self
			}
			
			previewImage = image
			previewImageLoadingState.succeed()
		} catch {
			previewImageLoadingState.fail(error: error)
		}
		
		return self
	}
	
	static func stripFormatting(_ text: String) -> String {
		replaceHtmlElements(text).trimmed
			.replacingOccurrences(of: #"&nbsp;|\\\(|\\\)|\\\[|\\\]|\$\$"#, with: " ", options: .regularExpression)
			.replacingOccurrences(of: "&quot;", with: "\"")
			.replacingOccurrences(of: "&amp;", with: "&")
			.replacingOccurrences(of: "&lt;", with: "<")
			.replacingOccurrences(of: "&gt;", with: ">")
			.replacingOccurrences(of: "&iexcl;", with: "¡")
			.replacingOccurrences(of: "&cent;", with: "¢")
			.replacingOccurrences(of: "&pound;", with: "£")
			.replacingOccurrences(of: "&curren;", with: "¤")
			.replacingOccurrences(of: "&yen;", with: "¥")
			.replacingOccurrences(of: "&brvbar;", with: "¦")
			.replacingOccurrences(of: "&sect;", with: "§")
			.replacingOccurrences(of: "&uml;", with: "¨")
			.replacingOccurrences(of: "&copy;", with: "©")
			.replacingOccurrences(of: "&ordf;", with: "ª")
			.replacingOccurrences(of: "&laquo;", with: "«")
			.replacingOccurrences(of: "&not;", with: "¬")
			.replacingOccurrences(of: "&shy;", with: "­")
			.replacingOccurrences(of: "&reg;", with: "®")
			.replacingOccurrences(of: "&macr;", with: "¯")
			.replacingOccurrences(of: "&deg;", with: "°")
			.replacingOccurrences(of: "&plusmn;", with: "±")
			.replacingOccurrences(of: "&sup2", with: "²")
			.replacingOccurrences(of: "&sup3;", with: "³")
			.replacingOccurrences(of: "&acute;", with: "´")
			.replacingOccurrences(of: "&micro;", with: "µ")
			.replacingOccurrences(of: "&para;", with: "¶")
			.replacingOccurrences(of: "&middot;", with: "·")
			.replacingOccurrences(of: "&cedil;", with: "¸")
			.replacingOccurrences(of: "&sup1;", with: "¹")
			.replacingOccurrences(of: "&ordm;", with: "º")
			.replacingOccurrences(of: "&raquo;", with: "»")
			.replacingOccurrences(of: "&frac14;", with: "¼")
			.replacingOccurrences(of: "&frac12;", with: "½")
			.replacingOccurrences(of: "&frac34;", with: "¾")
			.replacingOccurrences(of: "&iquest;", with: "¿")
			.replacingOccurrences(of: "&times;", with: "×")
			.replacingOccurrences(of: "&divide;", with: "÷")
			.replacingOccurrences(of: "&ETH;", with: "Ð")
			.replacingOccurrences(of: "&eth;", with: "ð")
			.replacingOccurrences(of: "&THORN;", with: "Þ")
			.replacingOccurrences(of: "&thorn;", with: "þ")
			.replacingOccurrences(of: "&AElig;", with: "Æ")
			.replacingOccurrences(of: "&aelig;", with: "æ")
			.replacingOccurrences(of: "&OElig;", with: "Œ")
			.replacingOccurrences(of: "&oelig;", with: "œ")
			.replacingOccurrences(of: "&Aring;", with: "Å")
			.replacingOccurrences(of: "&Oslash;", with: "Ø")
			.replacingOccurrences(of: "&Ccedil;", with: "Ç")
			.replacingOccurrences(of: "&ccedil;", with: "ç")
			.replacingOccurrences(of: "&szlig;", with: "ß")
			.replacingOccurrences(of: "&Ntilde;", with: "Ñ")
			.replacingOccurrences(of: "&ntilde;", with: "ñ")
			.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
	}
	
	private static func replaceHtmlElements(_ text: String) -> String {
		Audio.replaceAudioTags(inHTML: text, with: " ")
			.replacingOccurrences(
				of: "<.+?>",
				with: " ",
				options: .regularExpression
			)
	}
	
	func htmlForSide(_ side: Side) -> String {
		switch side {
		case .front:
			return front
		case .back:
			return back
		}
	}
	
	@discardableResult
	func updateFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		self.snapshot = snapshot
		
		sectionId = (snapshot.get("section") as? String)?.nilIfEmpty
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
	
	// "viewTime" is in milliseconds
	@discardableResult
	func review(rating: PerformanceRating, viewTime: TimeInterval) -> Promise<Bool> {
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
		onBackgroundThread {
			user
				.documentReference
				.collection("decks/\(deck.id)/cards")
				.document(self.id)
				.addSnapshotListener { snapshot, error in
					guard
						error == nil,
						let snapshot = snapshot
					else {
						onMainThread {
							self.userDataLoadingState.fail(error: error ?? UNKNOWN_ERROR)
						}
						return
					}
					onMainThread {
						self.updateUserDataFromSnapshot(snapshot)
						self.userDataLoadingState.succeed()
					}
				}
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
