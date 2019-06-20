import AVFoundation
import SwiftySound

class Audio {
	private static var audioCache = [URL : URL]()
	
	static func download(url: URL, completion: @escaping (URL?) -> Void = { _ in }) {
		if let cachedUrl = audioCache[url] {
			completion(cachedUrl)
		} else {
			URLSession.shared.downloadTask(with: url) {
				guard $2 == nil, let localUrl = $0 else { return completion(nil) }
				audioCache[url] = localUrl
				completion(localUrl)
			}.resume()
		}
	}
	
	static func download(url: String, completion: @escaping (URL?) -> Void = { _ in }) {
		guard let url = URL(string: url) else { return completion(nil) }
		download(url: url, completion: completion)
	}
	
	static func play(url: URL, completion: @escaping (Bool) -> Void = { _ in }) {
		download(url: url) { url in
			guard let url = url, let sound = Sound(url: url) else { return completion(false) }
			sound.play {
				guard $0 else { return }
				completion(true)
			}
		}
	}
	
	static func play(urls: [URL], completion: @escaping (Bool) -> Void = { _ in }) {
		guard let url = urls.first else { return completion(true) }
		play(url: url) {
			guard $0 else { return completion(false) }
			play(urls: Array(urls.dropFirst()), completion: completion)
		}
	}
}
