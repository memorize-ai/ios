import SwiftUI

struct SideBar<Content: View>: View {
	let extendedWidth = SCREEN_SIZE.width - 36
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@State var searchText = ""
	
	let geometry: GeometryProxy
	let content: Content
	
	init(geometry: GeometryProxy, content: () -> Content) {
		self.geometry = geometry
		self.content = content()
	}
	
	func hide() {
		withAnimation(SIDE_BAR_ANIMATION) {
			currentStore.isSideBarShowing = false
		}
	}
	
	var isShowing: Bool {
		currentStore.isSideBarShowing
	}
	
	var body: some View {
		ZStack(alignment: .leading) {
			ZStack {
				self.content
				Color.black
					.opacity(self.isShowing ? 0.3954 : 0)
					.onTapGesture(perform: self.hide)
					.edgesIgnoringSafeArea(.all)
			}
			.offset(x: self.isShowing ? self.extendedWidth : 0)
			ZStack {
				Color.lightGrayBackground
					.shadow(
						color: .black,
						radius: self.isShowing ? 5 : 0,
						x: self.isShowing ? -3 : 0
					)
				VStack(spacing: 0) {
					VStack(alignment: .leading, spacing: 18) {
						ZStack(alignment: .top) {
							SideBarTopGradient(
								width: self.extendedWidth,
								addedHeight: geometry.safeAreaInsets.top
							)
							SearchBar(
								self.$searchText,
								placeholder: "Decks",
								internalPadding: 12
							)
							.padding(.horizontal)
							.padding(.top, geometry.safeAreaInsets.top + 12)
						}
						ScrollView {
							SideBarSections(
								currentUser: self.currentStore.user,
								searchText: self.searchText
							)
							.frame(maxWidth: .infinity)
						}
					}
					VStack(spacing: 2) {
						SideBarSectionDivider()
						UserLevelView(user: self.currentStore.user)
							.padding([.horizontal, .bottom])
					}
					.padding(.bottom, geometry.safeAreaInsets.bottom)
				}
			}
			.frame(width: self.extendedWidth)
			.frame(maxHeight: .infinity)
			.offset(x: self.isShowing ? 0 : -self.extendedWidth)
			.edgesIgnoringSafeArea(.all)
		}
	}
}

#if DEBUG
struct SideBar_Previews: PreviewProvider {
	static var previews: some View {
		PREVIEW_CURRENT_STORE.isSideBarShowing = true
		return GeometryReader { geometry in
			SideBar(geometry: geometry) {
				Text("Content")
			}
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif
