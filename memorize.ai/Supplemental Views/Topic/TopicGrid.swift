import SwiftUI

struct TopicGrid: View {
	static let spacing: CGFloat = 8
	static let columns = [
		GridItem(.adaptive(
			minimum: TopicCell.dimension,
			maximum: TopicCell.dimension
		))
	]
	
	let topics: [Topic]
	
	let isSelected: (Topic) -> Bool
	let toggleSelect: (Topic) -> Void
	
	var body: some View {
		LazyVGrid(columns: Self.columns, spacing: Self.spacing) {
			ForEach(topics) { topic in
				TopicCell(
					topic: topic,
					isSelected: isSelected(topic),
					toggleSelect: { toggleSelect(topic) }
				)
			}
		}
	}
}

#if DEBUG
struct TopicGrid_Previews: PreviewProvider {
	static var previews: some View {
		TopicGrid(
			topics: [],
			isSelected: { _ in true },
			toggleSelect: { _ in }
		)
	}
}
#endif
