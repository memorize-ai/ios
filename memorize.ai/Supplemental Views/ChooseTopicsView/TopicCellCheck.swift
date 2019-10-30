import SwiftUI

struct TopicCellCheck: View {
	let isSelected: Bool
	
	var body: some View {
		Group {
			if isSelected {
				Circle() // TODO: Show check
			} else {
				Circle()
					.foregroundColor(Color.white.opacity(0.24))
					.overlay(
						Circle()
							.stroke(Color.white, lineWidth: 1)
					)
			}
		}
		.animation(.linear(duration: 0.1))
		.frame(width: 24, height: 24)
	}
}

#if DEBUG
struct TopicCellCheck_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 20) {
			TopicCellCheck(isSelected: false)
			TopicCellCheck(isSelected: true)
		}
	}
}
#endif
