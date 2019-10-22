import SwiftUI
import SwiftUIX

struct InitialViewPaginatedFeatures: View {
	var body: some View {
		PaginatedViews([Text("Hello!"), Text("Hi!")], axis: .horizontal, pageIndicatorAlignment: .bottom)
	}
}

#if DEBUG
struct InitialViewPaginatedFeatures_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewPaginatedFeatures()
	}
}
#endif
