import AVFoundation
import SwiftySound

class Audio {
	private static var cache = [URL : URL]()
	private static var player: AVAudioPlayer?
	
	enum PlayState {
		case ready
		case stop
	}
	
	static var isPlaying: Bool {
		return player?.isPlaying ?? false
	}
	
	static func stop() {
		player?.stop()
	}
	
	static func image(for playState: PlayState) -> UIImage {
		switch playState {
		case .ready:
			return #imageLiteral(resourceName: "Play")
		case .stop:
			return #imageLiteral(resourceName: "Stop")
		}
	}
	
	static func download(url: URL, completion: @escaping (URL?) -> Void = { _ in }) {
		if let cachedUrl = cache[url] {
			completion(cachedUrl)
		} else {
			URLSession.shared.downloadTask(with: url) {
				guard $2 == nil, let localUrl = $0 else { return completion(nil) }
				cache[url] = localUrl
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
			guard let url = url, let data = try? Data(contentsOf: url) else { return completion(false) }
			play(data: data, completion: completion)
		}
	}
	
	static func play(data: Data, completion: @escaping (Bool) -> Void = { _ in }) {
		guard let player = try? AVAudioPlayer(data: data) else { return completion(false) }
		stop()
		self.player = player
		let success = self.player?.play(numberOfLoops: 0) {
			guard $0 else { return }
			completion(true)
		}
		guard success ?? false else { return completion(false) }
	}
	
	static func play(urls: [URL], completion: @escaping (Bool) -> Void = { _ in }) {
		guard let url = urls.first else { return completion(true) }
		play(url: url) {
			guard $0 else { return completion(false) }
			play(urls: Array(urls.dropFirst()), completion: completion)
		}
	}
}
