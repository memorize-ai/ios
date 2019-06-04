import Firebase

var listeners = [String : ListenerRegistration]()

class Listener {
	static func remove(_ key: String) {
		listeners[key]?.remove()
	}
	
	static func removeAll() {
		listeners.forEach {
			$0.value.remove()
			listeners.removeValue(forKey: $0.key)
		}
	}
}
