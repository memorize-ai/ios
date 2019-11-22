import SwiftUI

struct MarketViewFilterPopUpContentWithSlider: View {
	@Binding var value: Double
	
	let leadingText: String
	let trailingText: String
	let lowerBound: Double
	let upperBound: Double
	let formatAsInt: Bool
	
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
				CustomRectangle(
					background: value.isZero
						? Color.darkGray
						: Color.darkBlue
				) {
					Text(
						formatAsInt
							? value.formattedAsInt
							: value.formatted
					)
					.font(.muli(.extraBold, size: 16))
					.foregroundColor(.white)
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
				}
				.opacity(value.isZero ? 0.5 : 1)
				lightText(trailingText)
			}
			Slider(
				value: $value,
				in: lowerBound...upperBound,
				minimumValueLabel: sliderValueLabel(lowerBound),
				maximumValueLabel: sliderValueLabel(upperBound),
				label: EmptyView.init
			)
			Spacer()
		}
		.padding()
	}
}

#if DEBUG
struct MarketViewFilterPopUpContentWithSlider_Preview: View {
	@State var value = 7800.0
	
	var body: some View {
		MarketViewFilterPopUpContentWithSlider(
			value: $value,
			leadingText: "Must have over",
			trailingText: "downloads",
			lowerBound: 0,
			upperBound: 10000,
			formatAsInt: true
		)
	}
}

struct MarketViewFilterPopUpContentWithSlider_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewFilterPopUpContentWithSlider_Preview()
	}
}
#endif
