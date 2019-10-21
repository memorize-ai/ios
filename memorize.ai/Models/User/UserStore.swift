import Combine

final class UserStore: ObservableObject {
	@Published var user: User
	
	init(_ user: User) {
		self.user = user
	}
	
	@discardableResult
	func prepareForUpdate() -> Self {
		objectWillChange.send()
		return self
	}
}
