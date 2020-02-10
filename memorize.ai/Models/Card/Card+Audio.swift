import Foundation
import Audio

extension Card {
	static let audio = Audio()
	
	var hasAudio: Bool {
		hasAudio(forSide: .front) || hasAudio(forSide: .back)
	}
	
	func hasAudio(forSide side: Side) -> Bool {
		Audio.hasValidAudioUrlsFromAudioTags(inHTML: htmlForSide(side))
	}
	
	@discardableResult
	func playAudio(forSide side: Side) -> Self {
		Self.audio.playAll(inHTML: htmlForSide(side))
		return self
	}
}
