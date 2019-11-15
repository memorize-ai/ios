import SwiftUI

struct DeckIcon<Content: View>: View {
	let color: Color
	let content: Content?
	
	init(
		color: Color = .white,
		content: (() -> Content)? = nil
	) {
		self.color = color
		self.content = content?()
	}
	
	var rectangle: some View {
		RoundedRectangle(cornerRadius: 4)
			.foregroundColor(color)
			.frame(width: 26, height: 18)
	}
	
	var body: some View {
		ZStack(alignment: .topLeading) {
			rectangle
				.padding([.leading, .top], 4.5)
				.opacity(0.5)
			ZStack {
				rectangle
				content
			}
		}
	}
}

#if DEBUG
struct DeckIcon_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.extraPurple
				.edgesIgnoringSafeArea(.all)
			DeckIcon {
				Text("123")
			}
		}
	}
}
#endif
