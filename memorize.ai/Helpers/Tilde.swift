prefix operator ~

prefix func ~ <T, U>(_ keyPath: KeyPath<T, U>) -> (T) -> U {
	{ $0[keyPath: keyPath] }
}
