import SwiftUI

struct HorizontalBarGraph: View {
	struct Row: Identifiable, Equatable, Hashable {
		let id = UUID()
		let label: String
		let value: Int
		
		func percentFilled(relativeToMax max: Self) -> CGFloat {
			.init(value) &/ .init(max.value)
		}
	}
	
	let rows: [Row]
	let color: Color
	
	var max: Row! {
		rows.max(by: \.value)
	}
	
	var dottedLineValues: (Int, Int, Int, Int) {
		let maxValue = max.value
		return (
			maxValue * 0 / 3,
			maxValue * 1 / 3,
			maxValue * 2 / 3,
			maxValue * 3 / 3
		)
	}
	
	var height: CGFloat {
		.init(rows.count * 12) + .init((rows.count - 1) * 16)
	}
	
	var dottedLine: some View {
		Path { path in
			path.move(to: .zero)
			path.addLine(to: .init(x: 0, y: height))
		}
		.stroke(style: .init(lineWidth: 2, dash: [5]))
		.foregroundColor(Color.lightGrayBorder.opacity(0.4))
		.frame(width: 2, height: height)
	}
	
	func dottedLineWithValue(_ value: Int) -> some View {
		ZStack(alignment: .bottom) {
			dottedLine
			Text(value.formatted)
				.font(.muli(.semiBold, size: 14))
				.foregroundColor(.lightGrayText)
				.shrinks()
				.frame(height: 20)
				.offset(y: 20)
		}
	}
	
	var body: some View {
		HStack {
			VStack(alignment: .trailing, spacing: 16) {
				ForEach(rows) { row in
					Text(row.label)
						.font(.muli(.extraBold, size: 12))
						.foregroundColor(.darkGray)
						.frame(height: 12)
						.shrinks()
				}
			}
			ZStack {
				HStack {
					dottedLineWithValue(dottedLineValues.0)
					Spacer()
					dottedLineWithValue(dottedLineValues.1)
					Spacer()
					dottedLineWithValue(dottedLineValues.2)
					Spacer()
					dottedLineWithValue(dottedLineValues.3)
				}
				VStack(spacing: 16) {
					ForEach(rows) { row in
						RoundedRectangle(cornerRadius: 2)
							.foregroundColor(
								self.color.opacity(self.max == row ? 1 : 0.3)
							)
							.frame(height: 12)
							.scaleEffect(
								x: row.percentFilled(relativeToMax: self.max),
								y: 1,
								anchor: .leading
							)
					}
				}
			}
		}
		.padding(.bottom)
	}
}

#if DEBUG
struct HorizontalBarGraph_Previews: PreviewProvider {
    static var previews: some View {
		HorizontalBarGraph(
			rows: [
				.init(label: "EASY", value: 12),
				.init(label: "STRUGGLED", value: 10),
				.init(label: "FORGOT", value: 9)
			],
			color: .init(#colorLiteral(red: 0.03529411765, green: 0.6156862745, blue: 0.4117647059, alpha: 1))
		)
		.padding(.horizontal, 40)
    }
}
#endif
