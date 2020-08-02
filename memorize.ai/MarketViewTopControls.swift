import SwiftUI

struct MarketViewTopControls: View {
	@StateObject var counters = Counters.shared
	
	let searchText: String
	let setSearchText: (String) -> Void
	
	var placeholder: String {
		"Explore \(counters[.decks]?.formatted ?? "...") decks"
	}
	
	var body: some View {
		HStack(spacing: 20) {
			ShowSideBarButton {
				HamburgerMenu()
			}
			CustomRectangle(
				background: HomeViewTopControls.searchBarBackgroundColor,
				cornerRadius: 24
			) {
				HStack(spacing: 10) {
					Image.whiteMagnifyingGlass
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 14)
					ZStack(alignment: .leading) {
						if searchText.isEmpty {
							Text(placeholder)
								.foregroundColor(Color.white.opacity(0.8))
						}
						TextField("", text: .init(
							get: { self.searchText },
							set: setSearchText
						))
						.foregroundColor(.white)
						.padding(.vertical)
						.offset(y: 1)
					}
					.font(.muli(.regular, size: 17))
					Spacer()
				}
				.padding(.horizontal)
				.frame(height: 48)
			}
		}
		.onAppear {
			self.counters.get(.decks)
		}
	}
}

#if DEBUG
struct MarketViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewTopControls(searchText: "", setSearchText: { _ in })
	}
}
#endif
