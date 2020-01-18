extension Int {
	var formatted: String {
		Double(self).formatted
	}
	
	var nilIfZero: Self? {
		self == 0 ? nil : self
	}
}
