import SwiftUI

struct MarketViewFilterPopUpContentWithSlider: View {
	@Binding var value: Double
	
	let leadingText: String
	let trailingText: String
	let lowerBound: Double
	let upperBound: Double
	
	func lightText(_ text: String) -> some View {
		Text(text)
			.font(.muli(.bold, size: 16))
			.foregroundColor(.lightGrayText)
	}
	
	func sliderValueLabel(_ value: Double) -> some View {
		Text(value.formatted)
			.font(.muli(.bold, size: 16))
			.foregroundColor(.darkGray)
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack(spacing: 6) {
				lightText(leadingText)
				CustomRectangle(background: Color.darkBlue) {
					Text(value.formatted)
						.font(.muli(.extraBold, size: 16))
						.foregroundColor(.white)
						.padding(.horizontal, 8)
						.padding(.vertical, 4)
				}
				lightText(trailingText)
			}
			Slider(
				value: $value,
				in: lowerBound...upperBound,
				minimumValueLabel: sliderValueLabel(lowerBound),
				maximumValueLabel: sliderValueLabel(upperBound),
				label: EmptyView.init
			)
		}
		.padding(.horizontal)
	}
}

#if DEBUG
struct MarketViewFilterPopUpContentWithSlider_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewFilterPopUpContentWithSlider(
			value: .constant(7800),
			leadingText: "Must have over",
			trailingText: "downloads",
			lowerBound: 0,
			upperBound: 10000
		)
	}
}
#endif
