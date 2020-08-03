import SwiftUI

struct TopicGrid: View {
	struct Row: Identifiable, Equatable, Hashable {
		let id: Int
		let topics: [Topic]
	}
	
	static let spacing: CGFloat = 8
	static let columns: [Any] = {
		if #available(iOS 14.0, *) {
			return [
				GridItem(.adaptive(
					minimum: TopicCell.dimension,
					maximum: TopicCell.dimension
				))
			]
		} else {
			return []
		}
	}()
	
	let topics: [Topic]
	
	let isSelected: (Topic) -> Bool
	let toggleSelect: (Topic) -> Void
	
	func columns(geometry: GeometryProxy) -> Int {
		.init(
			(geometry.size.width + Self.spacing) /
			(TopicCell.dimension + Self.spacing)
		)
	}
	
	func rows(geometry: GeometryProxy) -> [Row] {
		var temp = [Row]()
		
		_ = topics
			.publisher
			.collect(columns(geometry: geometry))
			.collect()
			.sink {
				temp = $0.enumerated().map { id, topics in
					.init(id: id, topics: topics)
				}
			}
		
		return temp
	}
	
	var body: some View {
		Group {
			if #available(iOS 14.0, *) {
				LazyVGrid(
					columns: Self.columns as? [GridItem] ?? [],
					spacing: Self.spacing
				) {
					ForEach(topics) { topic in
						TopicCell(
							topic: topic,
							isSelected: isSelected(topic),
							toggleSelect: { toggleSelect(topic) }
						)
					}
				}
			} else {
				GeometryReader { geometry in
					VStack(spacing: Self.spacing) {
						ForEach(rows(geometry: geometry)) { row in
							HStack(spacing: Self.spacing) {
								ForEach(row.topics) { topic in
									TopicCell(
										topic: topic,
										isSelected: isSelected(topic),
										toggleSelect: { toggleSelect(topic) }
									)
								}
							}
						}
					}
				}
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
