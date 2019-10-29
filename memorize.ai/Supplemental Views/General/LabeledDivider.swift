import SwiftUI

struct LabeledDivider<Content: View>: View {
	let color: Color
	let content: Content
	
	init(color: Color, content: () -> Content) {
		self.color = color
		self.content = content()
	}
	
	var divider: some View {
		VStack {
			Divider()
				.foregroundColor(color)
		}
	}
	
	var body: some View {
		HStack {
			divider
			content
			divider
		}
	}
}

#if DEBUG
struct LabeledDivider_Previews: PreviewProvider {
	static var previews: some View {
		LabeledDivider(color: .darkText) {
			Text("OR")
		}
	}
}
#endif
