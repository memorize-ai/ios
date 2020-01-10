import SwiftUI

struct HorizontalBarGraph: View {
	struct Data: Identifiable, Equatable, Hashable {
		let id = UUID()
		let label: String
		let value: Int
	}
	
	let data: [Data]
	
	var body: some View {
		VStack {
			ForEach(data) { row in
				Text(row.label)
			}
		}
	}
}

#if DEBUG
struct HorizontalBarGraph_Previews: PreviewProvider {
    static var previews: some View {
		HorizontalBarGraph(data: [
			.init(label: "EASY", value: 12),
			.init(label: "STRUGGLED", value: 10),
			.init(label: "FORGOT", value: 9),
		])
    }
}
#endif
