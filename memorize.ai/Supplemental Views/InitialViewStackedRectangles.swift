import SwiftUI

struct InitialViewStackedRectangles: View {
	var body: some View {
		GeometryReader { geometry in
			Path { path in
				
			}
		}
	}
}

#if DEBUG
struct InitialViewStackedRectangles_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewStackedRectangles()
	}
}
#endif
