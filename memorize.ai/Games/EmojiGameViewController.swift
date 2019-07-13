import UIKit

class EmojiGameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var emojiLabel: UILabel!
	@IBOutlet weak var mainLabel: UILabel!
	@IBOutlet weak var blockView: UIView!
	@IBOutlet weak var countTextField: UITextField!
	@IBOutlet weak var countBarView: UIView!
	@IBOutlet weak var difficultyCollectionView: UICollectionView!
	@IBOutlet weak var changeGameStateButton: UIButton!
	
	class Difficulty {
		let count: Int
		let name: String
		let textColor: UIColor
		let backgroundColor: UIColor
		
		init(count: Int, name: String, textColor: UIColor = .white, backgroundColor: UIColor) {
			self.count = count
			self.name = name
			self.textColor = textColor
			self.backgroundColor = backgroundColor
		}
	}
	
	enum GameState {
		case ready
		case timerIsOn
		case timerDidEnd
	}
	
	let EMOJIS = "😀😃😄😁😆😅😂🤣☺️🥰😘😗😇😊☺️🙂🙃😉😌😍😋😛😝🤪😜🤩😎🤓🥳😭😤"
	let DELAY = 20
	let DIFFICULTIES = [
		Difficulty(count: 10, name: "EASY", backgroundColor: #colorLiteral(red: 0.337254902, green: 0.8235294118, blue: 0.2, alpha: 1)),
		Difficulty(count: 15, name: "MEDIUM", backgroundColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)),
		Difficulty(count: 20, name: "HARD", backgroundColor: #colorLiteral(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)),
		Difficulty(count: 30, name: "EXPERT", backgroundColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)),
		Difficulty(count: -1, name: "SELECT COUNT", textColor: .darkGray, backgroundColor: #colorLiteral(red: 0.9150854945, green: 0.9158141017, blue: 0.9373884797, alpha: 1))
	]
	
	var gameState = GameState.ready
	var currentDifficulty: Difficulty?
	var timer: Timer?
	var seconds = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction
	func changeGameState() {
		switch gameState {
		case .ready:
			startTimer()
			gameState = .timerIsOn
		case .timerIsOn:
			return
		case .timerDidEnd:
			nextGuess()
		}
	}
	
	func chooseEmojis(_ count: Int) -> [String] {
		return (1...count).compactMap { _ in EMOJIS.randomElement() }.map(String.init)
	}
	
	func startTimer() {
		seconds = DELAY
		blockView.alpha = 0
		blockView.isHidden = false
		UIView.animate(withDuration: 0.15, animations: {
			self.blockView.alpha = 1
		}) {
			guard $0 else { return }
			self.blockView.isHidden = false
		}
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
			self.seconds -= 1
			self.setMainLabelTimerText(self.seconds)
			guard self.seconds <= 0 else { return }
			self.timer?.invalidate()
			self.gameState = .timerDidEnd
			self.changeGameState()
		}
	}
	
	func setMainLabelTimerText(_ seconds: Int) {
		mainLabel.text = "\(seconds)s left"
	}
	
	func nextGuess() {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return DIFFICULTIES.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? EmojiGameDifficultyCollectionViewCell else { return _cell }
		let element = DIFFICULTIES[indexPath.item]
		cell.label.text = element.name
		cell.label.textColor = element.textColor
		cell.backgroundColor = element.backgroundColor
		return cell
	}
}

class EmojiGameDifficultyCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var label: UILabel!
}
