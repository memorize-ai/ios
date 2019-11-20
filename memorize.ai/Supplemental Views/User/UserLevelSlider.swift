import SwiftUI

struct UserLevelSlider: View {
	let percent: CGFloat
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .leading) {
				Capsule()
					.foregroundColor(.white)
				Capsule()
					.stroke(Color.lightGrayBorder)
				Capsule()
					.foregroundColor(.extraPurple)
					.frame(width: geometry.size.width * self.percent)
			}
		}
		.frame(height: 12)
	}
}

#if DEBUG
struct UserLevelSlider_Previews: PreviewProvider {
	static var previews: some View {
		UserLevelSlider(percent: 1 / 3)
	}
}
#endif
