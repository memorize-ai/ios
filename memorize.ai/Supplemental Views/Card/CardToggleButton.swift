import SwiftUI

struct CardToggleButton: View {
	let image: Image
	
	@Binding var side: Card.Side
	@Binding var degrees: Double
	
	init(
		image: Image = .swapIcon,
		side: Binding<Card.Side>,
		degrees: Binding<Double>
	) {
		self.image = image
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
		.frame(width: 30, height: 30)
	}
	
	var body: some View {
		HStack(alignment: .bottom) {
			Text(side == .front ? "FRONT" : "BACK")
				.font(.muli(.bold, size: 10))
				.foregroundColor(Color.gray.opacity(0.7))
				.padding(.bottom, 3)
			Button(action: {
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