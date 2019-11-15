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
	}
	
	var body: some View {
		ZStack(alignment: .topLeading) {
			rectangle
				.frame(width: 28, height: 20)
				.padding([.leading, .top], 4.5)
				.opacity(0.5)
			ZStack {
				rectangle
					.frame(width: 28, height: 20)
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
