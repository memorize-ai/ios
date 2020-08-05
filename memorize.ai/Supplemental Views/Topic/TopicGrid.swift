import SwiftUI
import QGrid

struct TopicGrid: View {
	struct Row: Identifiable, Equatable, Hashable {
		let id: Int
		let topics: [Topic]
	}
	
	static let spacing: CGFloat = 8
//	static let columns: [Any] = {
//		if #available(iOS 14.0, *) {
//			return [
//				GridItem(.adaptive(
//					minimum: TopicCell.dimension,
//					maximum: TopicCell.dimension
//				))
//			]
//		} else {
//			return []
//		}
//	}()
	
	let width: CGFloat
	let topics: [Topic]
	
	let isSelected: (Topic) -> Bool
	let toggleSelect: (Topic) -> Void
	
	var columns: Int {
		.init((width + Self.spacing) / (TopicCell.dimension + Self.spacing))
	}
	
	func height(rows: Int) -> CGFloat {
		rows == 0
			? 0
			: .init(rows) * (TopicCell.dimension + Self.spacing) - Self.spacing
	}
	
	var fallbackContent: some View {
		let columns = self.columns
		let rows = columns == 0
			? 0
			: CGFloat(topics.count / columns + min(topics.count % columns, 1))
		
		return QGrid(
			topics,
			columns: columns,
			vSpacing: Self.spacing,
			hSpacing: Self.spacing,
			vPadding: 0,
			hPadding: 0,
			isScrollable: false
		) { topic in
			TopicCell(
				topic: topic,
				isSelected: self.isSelected(topic),
				toggleSelect: { self.toggleSelect(topic) }
			)
		}
		.frame(
			width: TopicCell.dimension * .init(columns) + Self.spacing * .init(columns - 1),
			height: TopicCell.dimension * rows + Self.spacing * (rows - 1)
		)
	}
	
	var body: some View {
//		if #available(iOS 14.0, *) {
//			AnyView(
//				LazyVGrid(
//					columns: Self.columns as? [GridItem] ?? [],
//					spacing: Self.spacing
//				) {
//					ForEach(topics) { topic in
//						TopicCell(
//							topic: topic,
//							isSelected: isSelected(topic),
//							toggleSelect: { toggleSelect(topic) }
//						)
//					}
//				}
//			)
//		} else {
//			AnyView(fallbackContent)
//		}
		fallbackContent
	}
}

#if DEBUG
struct TopicGrid_Previews: PreviewProvider {
	static var previews: some View {
		TopicGrid(
			width: SCREEN_SIZE.width,
			topics: [],
			isSelected: { _ in true },
			toggleSelect: { _ in }
		)
	}
}
#endif
