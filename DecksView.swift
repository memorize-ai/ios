import SwiftUI

struct DecksView: View {
	static let horizontalPadding: CGFloat = 23
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@Binding var isDeckOptionsPopUpShowing: Bool
	@Binding var selectedSection: Deck.Section?
	@Binding var isSectionOptionsPopUpShowing: Bool
	
	let isSectionExpanded: (Deck.Section) -> Bool
	let toggleSectionExpanded: (Deck.Section, User) -> Void
	
	var selectedDeck: Deck {
		if currentStore.selectedDeck == nil {
			currentStore.selectedDeck = currentStore.user.decks.first
		}
		return currentStore.selectedDeck!
	}
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				HomeViewTopGradient(
					addedHeight: geometry.safeAreaInsets.top
				)
				.edgesIgnoringSafeArea(.all)
				VStack {
					DecksViewTopControls(
						selectedDeck: self.selectedDeck,
						isDeckOptionsPopUpShowing: self.$isDeckOptionsPopUpShowing
					)
					VStack(spacing: 0) {
						ZStack {
							Rectangle()
								.foregroundColor(.lightGrayBackground)
							ScrollView {
								DecksViewSections(
									selectedDeck: self.selectedDeck,
									selectedSection: self.$selectedSection,
									isSectionOptionsPopUpShowing: self.$isSectionOptionsPopUpShowing,
									isSectionExpanded: self.isSectionExpanded,
									toggleSectionExpanded: self.toggleSectionExpanded
								)
								.frame(maxWidth: .infinity)
								.padding(
									[.horizontal, .bottom],
									Self.horizontalPadding
								)
								.padding(.top)
							}
						}
						DecksViewBottomControls(
							selectedDeck: self.selectedDeck
						)
					}
				}
			}
		}
		.onAppear {
			self.selectedDeck.loadSections()
		}
	}
}

#if DEBUG
struct DecksView_Previews: PreviewProvider {
	static var previews: some View {
		DecksView(
			isDeckOptionsPopUpShowing: .constant(false),
			selectedSection: .constant(nil),
			isSectionOptionsPopUpShowing: .constant(false),
			isSectionExpanded: { _ in true },
			toggleSectionExpanded: { _, _ in }
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif
