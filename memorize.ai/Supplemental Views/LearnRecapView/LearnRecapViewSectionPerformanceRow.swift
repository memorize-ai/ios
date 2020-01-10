import SwiftUI

struct LearnRecapViewSectionPerformanceRow: View {
	let rating: Card.PerformanceRating
	
	var body: some View {
		VStack {
			HStack {
				Text("Frequently \(rating.title.lowercased())")
				
			}
		}
	}
}

#if DEBUG
struct LearnRecapViewSectionPerformanceRow_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewSectionPerformanceRow(rating: .easy)
	}
}
#endif
