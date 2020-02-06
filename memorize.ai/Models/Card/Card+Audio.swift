import Foundation
import Audio

extension Card {
	private static let AUDIO_REGEX = #"<audio.*?src.*?=.*?["'](.+?)["'].*?>.*?</.*?audio.*?>"#
	
	static let audio = Audio()
	
	var hasAudio: Bool {
		!(audioUrls(forSide: .front).isEmpty && audioUrls(forSide: .back).isEmpty)
	}
	
	func hasAudio(forSide side: Side) -> Bool {
		!audioUrls(forSide: side).isEmpty
	}
	
	@discardableResult
	func playAudio(forSide side: Side) -> Self {
		Self.audio.play(urls: audioUrls(forSide: side))
		return self
	}
	
	private func audioUrls(forSide side: Side) -> [URL] {
		switch side {
		case .front:
			return Self.audioUrls(forText: front)
		case .back:
			return Self.audioUrls(forText: back)
		}
	}
	
	private static func audioUrls(forText text: String) -> [URL] {
		text.match(AUDIO_REGEX).compactMap { match in
			guard let urlString = match[safe: 1] else { return nil }
			return URL(string: urlString)
		}
	}
	
	static func removeAudioUrls(fromText text: String) -> String {
		text.replacingOccurrences(
			of: AUDIO_REGEX,
			with: " ",
			options: .regularExpression
		)
	}
}
