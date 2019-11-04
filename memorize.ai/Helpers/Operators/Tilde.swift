prefix operator ~

prefix func ~ <T, U>(keyPath: KeyPath<T, U>) -> (T) -> U {
	{ $0[keyPath: keyPath] }
}
