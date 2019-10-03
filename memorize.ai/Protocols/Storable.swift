protocol Storable {
	var prepareForUpdate: (() -> Void)? { get }
}
