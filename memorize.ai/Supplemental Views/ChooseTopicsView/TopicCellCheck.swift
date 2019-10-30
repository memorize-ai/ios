import SwiftUI

struct TopicCellCheck: View {
	@Binding var isSelected: Bool
	
	var body: some View {
		Button(action: {
			self.isSelected.toggle()
		}) {
			Text(isSelected ? "Y" : "N")
		}
	}
}

#if DEBUG
struct TopicCellCheck_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 20) {
			TopicCellCheck(isSelected: .constant(false))
			TopicCellCheck(isSelected: .constant(true))
		}
	}
}
#endif
