import UIKit

class Rating {
	static let ratings = [
		Rating(image: image(0), color: color(0), description: description(0)),
		Rating(image: image(1), color: color(1), description: description(1)),
		Rating(image: image(2), color: color(2), description: description(2)),
		Rating(image: image(3), color: color(3), description: description(3)),
		Rating(image: image(4), color: color(4), description: description(4)),
		Rating(image: image(5), color: color(5), description: description(5))
	]
	
	let image: UIImage
	let color: UIColor
	let description: String
	
	init(image: UIImage, color: UIColor, description: String) {
		self.image = image
		self.color = color
		self.description = description
	}
	
	static func get(_ rating: Int) -> Rating {
		return ratings[rating]
	}
	
	static func image(_ rating: Int) -> UIImage {
		return rating < 0 || rating > 5 ? #imageLiteral(resourceName: "Gray Circle") : UIImage(named: "Rating \(rating)") ?? #imageLiteral(resourceName: "Gray Circle")
	}
	
	static func color(_ rating: Int) -> UIColor {
		switch rating {
		case 0:
			return #colorLiteral(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
		case 1:
			return #colorLiteral(red: 0.7862434983, green: 0.4098072052, blue: 0.2144107223, alpha: 1)
		case 2:
			return #colorLiteral(red: 0.7540822029, green: 0.6499487758, blue: 0, alpha: 1)
		case 3:
			return #colorLiteral(red: 0.6504547, green: 0.7935678959, blue: 0, alpha: 1)
		case 4:
			return #colorLiteral(red: 0.3838550448, green: 0.7988399267, blue: 0, alpha: 1)
		case 5:
			return #colorLiteral(red: 0.2823529412, green: 0.8, blue: 0.4980392157, alpha: 1)
		default:
			return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		}
	}
	
	static func description(_ rating: Int) -> String {
		switch rating {
		case 0:
			return "Forgot"
		case 1:
			return "Kind of forgot"
		case 2:
			return "Almost remembered"
		case 3:
			return "Struggled and got it"
		case 4:
			return "Hesitated"
		case 5:
			return "Easy"
		default:
			return ""
		}
	}
}
