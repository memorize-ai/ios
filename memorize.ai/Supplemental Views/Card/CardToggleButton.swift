import SwiftUI
import FirebaseAnalytics

struct CardToggleButton: View {
	let image: Image
	let circleDimension: CGFloat
	let fontSize: CGFloat
	
	@Binding var side: Card.Side
	@Binding var degrees: Double
	
	init(
		image: Image = .swapIcon,
		circleDimension: CGFloat = 30,
		fontSize: CGFloat = 10,
		side: Binding<Card.Side>,
		degrees: Binding<Double>
	) {
		self.image = image
		self.circleDimension = circleDimension
		self.fontSize = fontSize
		_side = side
		_degrees = degrees
	}
	
	var icon: some View {
		ZStack {
			Circle()
				.foregroundColor(.lightGray)
			image
				.resizable()
				.renderingMode(.original)
				.aspectRatio(contentMode: .fit)
				.padding(6)
				.rotationEffect(.degrees(degrees))
		}
		.frame(
			width: circleDimension,
			height: circleDimension
		)
	}
	
	var body: some View {
		HStack(alignment: .bottom) {
			Text(side == .front ? "FRONT" : "BACK")
				.font(.muli(.bold, size: fontSize))
				.foregroundColor(Color.gray.opacity(0.7))
				.padding(.bottom, 3)
			Button(action: {
				Analytics.logEvent("toggle_card_side", parameters: [
					"view": "CardToggleButton"
				])
				
				self.side.toggle()
				withAnimation {
					self.degrees += 180
				}
			}) {
				icon
			}
		}
	}
}

#if DEBUG
struct CardToggleButton_Previews: PreviewProvider {
	static var previews: some View {
		CardToggleButton(
			side: .constant(.front),
			degrees: .constant(0)
		)
	}
}
#endif
