import SwiftUI

struct SideBar<Content: View>: View {
	let extendedWidth = SCREEN_SIZE.width - 36
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@State var searchText = ""
	@State var selectedDeck: Deck?
	
	@Binding var isShowing: Bool
	
	let content: Content
	
	init(isShowing: Binding<Bool>, content: () -> Content) {
		_isShowing = isShowing
		self.content = content()
	}
	
	func hide() {
		withAnimation(SIDE_BAR_ANIMATION) {
			isShowing = false
		}
	}
	
	var body: some View {
		ZStack(alignment: .leading) {
			ZStack {
				content
				Color.black
					.opacity(isShowing ? 0.3954 : 0)
					.onTapGesture(perform: hide)
					.edgesIgnoringSafeArea(.all)
			}
			.offset(x: isShowing ? extendedWidth : 0)
			ZStack {
				Color.lightGrayBackground
					.shadow(
						color: .black,
						radius: isShowing ? 5 : 0,
						x: isShowing ? -3 : 0
					)
				VStack(alignment: .leading, spacing: 18) {
					ZStack(alignment: .top) {
						SideBarTopGradient(width: extendedWidth)
						SearchBar(
							$searchText,
							placeholder: "Decks",
							internalPadding: 12
						)
						.padding([.horizontal, .top])
					}
					ScrollView {
						SideBarSections(
							currentUser: currentStore.user,
							selectedDeck: $selectedDeck,
							searchText: searchText
						)
					}
				}
			}
			.frame(width: extendedWidth)
			.frame(maxHeight: .infinity)
			.offset(x: isShowing ? 0 : -extendedWidth)
			.edgesIgnoringSafeArea(.all)
		}
	}
}

#if DEBUG
struct SideBar_Previews: PreviewProvider {
	static var previews: some View {
		SideBar(isShowing: .constant(true)) {
			Text("Content")
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif
