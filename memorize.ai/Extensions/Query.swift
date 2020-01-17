import FirebaseFirestore

extension Query {
	func start(afterDocument document: DocumentSnapshot?) -> Query {
		document.map {
			(start(afterDocument:) as (DocumentSnapshot) -> Query)($0)
		} ?? self
	}
}
