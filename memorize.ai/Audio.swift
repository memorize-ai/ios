import AVFoundation
import SwiftySound

class Audio {
	private static var player: AVAudioPlayer?
	
	enum PlayState {
		case ready
		case stop
		case pause
	}
	
	static var isPlaying: Bool {
		return player?.isPlaying ?? false
	}
	
	static func resume() {
		player?.resume()
	}
	
	static func pause() {
		player?.pause()
	}
	
	static func stop() {
		player?.stop()
	}
	
	static func image(for playState: PlayState, white: Bool = false) -> UIImage {
		switch playState {
		case .ready:
			return white ? #imageLiteral(resourceName: "Play White") : #imageLiteral(resourceName: "Play Black")
		case .stop:
			return white ? #imageLiteral(resourceName: "Stop White") : #imageLiteral(resourceName: "Stop Black")
		case .pause:
			return white ? #imageLiteral(resourceName: "Pause White") : #imageLiteral(resourceName: "Pause Black")
		}
	}
	
	static func download(url: URL, completion: @escaping (URL?) -> Void = { _ in }) {
		URLSession.shared.downloadTask(with: url) {
			guard $2 == nil else { return completion(nil) }
			completion($0)
		}.resume()
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
