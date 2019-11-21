import SwiftUI

struct PopUp: View {
	var body: some View {
		GeometryReader { geometry in
			Button(action: {
				// TODO: Hide
			}) {
				ZStack {
					Color.lightGrayBackground
					HStack(spacing: 20) {
						XButton(.purple, height: 15)
						Text("Cancel")
							.font(.muli(.extraBold, size: 17))
							.foregroundColor(.darkGray)
						Spacer()
					}
					.padding(.leading, 30)
				}
			}
			.frame(height: 50)
		}
	}
}

#if DEBUG
struct PopUp_Previews: PreviewProvider {
	static var previews: some View {
		PopUp()
	}
}
#endif
