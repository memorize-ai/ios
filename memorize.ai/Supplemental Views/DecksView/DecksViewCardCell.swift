import SwiftUI
import SwiftUIX

struct DecksViewCardCell: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var card: Card
	
	@State var isCardPreviewPresented = false
	
	var hasPreviewImage: Bool {
		!card.previewImageLoadingState.isNone
	}
	
	var isOwner: Bool {
		card.parent.creatorId == currentStore.user.id
	}
	
	var content: some View {
		ZStack(alignment: .topLeading) {
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGrayBorder,
				borderWidth: 1,
				cornerRadius: 8,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				VStack(alignment: .leading) {
					HStack(alignment: .top) {
						if card.isNew {
							Text("NEW")
								.font(.muli(.semiBold, size: 13))
								.foregroundColor(.darkBlue)
						}
						Spacer()
						if card.hasAudio {
							Button(action: {
								_ = self.card.hasAudio(forSide: .front)
									? self.card.playAudio(forSide: .front)
									: self.card.playAudio(forSide: .back)
							}) {
								Image(systemName: .speaker3Fill)
									.foregroundColor(.darkBlue)
							}
							.padding([.trailing, .top], 4)
						}
					}
					.padding(
						.bottom,
						card.isNew && !card.hasAudio
							? hasPreviewImage ? 2 : 8
							: 0
					)
					HStack(alignment: .top) {
						if hasPreviewImage {
							SwitchOver(card.previewImageLoadingState)
								.case(.loading) {
									ZStack {
										Color.lightGrayBackground
										ActivityIndicator(color: .gray)
									}
								}
								.case(.success) {
									card.previewImage?
										.resizable()
										.renderingMode(.original)
										.aspectRatio(contentMode: .fill)
								}
								.case(.failure) {
									ZStack {
										Color.lightGrayBackground
										Image(systemName: .exclamationmarkTriangle)
											.foregroundColor(.gray)
											.scaleEffect(1.5)
									}
								}
								.frame(width: 100, height: 100)
								.cornerRadius(5)
								.clipped()
						}
						Text(Card.stripFormatting(card.front).trimmed)
							.font(.muli(.semiBold, size: 15))
							.foregroundColor(.darkGray)
							.lineLimit(5)
							.lineSpacing(1)
							.layoutPriority(1)
							.alignment(.leading)
					}
					.frame(minHeight: 40, alignment: .top)
					if !card.isNew {
						HStack {
							Text(card.dueMessage)
								.foregroundColor(.darkBlue)
							Spacer()
							Group {
								if card.userData?.isMastered ?? false {
									HStack {
										Text("🎉")
										Text("Mastered!")
									}
								} else {
									Text("⚡️ \(card.userData?.streak ?? 0)x streak")
								}
							}
							.foregroundColor(Color.darkGray.opacity(0.7))
						}
						.font(.muli(.bold, size: 13))
						.padding(.horizontal, 2)
						.padding(.top, hasPreviewImage ? 6 : 10)
					}
				}
				.padding(8)
			}
			if card.isDue {
				Circle()
					.foregroundColor(Color.darkBlue.opacity(0.5))
					.frame(width: 12, height: 12)
					.offset(x: -4, y: -4)
			}
		}
		.onAppear {
			self.card.loadPreviewImage()
		}
	}
	
	var body: some View {
		Group {
			if isOwner {
				EditCardViewNavigationLink(
					deck: currentStore.selectedDeck!,
					card: card
				) {
					content
				}
			} else {
				Button(action: {
					self.isCardPreviewPresented = true
				}) {
					content
				}
				.sheet(isPresented: $isCardPreviewPresented) {
					DecksViewCardPreviewSheetView(card: self.card)
				}
			}
		}
	}
}

#if DEBUG
struct DecksViewCardCell_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 20) {
			DecksViewCardCell(card: .init(
				id: "0",
				parent: PREVIEW_CURRENT_STORE.user.decks.first!,
				sectionId: "CSS",
				front: #"This is the front of the card<audio src="a"></audio><h1>I am some big text</h1><img src="https://cdn.vox-cdn.com/thumbor/K7b0-MAQj0C2hy707Mm8WsUIocI=/0x0:600x350/1200x800/filters:focal(252x127:348x223)/cdn.vox-cdn.com/uploads/chorus_image/image/63386642/A_Consensus_sm.0.jpg">"#,
				back: "This is the back of the card",
				numberOfViews: 670,
				numberOfReviews: 0,
				numberOfSkips: 40,
				userData: {
					var userData = Card.UserData(isNew: false, dueDate: Date().addingTimeInterval(10000))
					userData.isMastered = true
					return userData
				}()
			))
			.environmentObject(PREVIEW_CURRENT_STORE)
			DecksViewCardCell(card: .init(
				id: "0",
				parent: PREVIEW_CURRENT_STORE.user.decks.first!,
				sectionId: "CSS",
				front: "This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text This is some text ",
				back: "This is the back of the card",
				numberOfViews: 670,
				numberOfReviews: 0,
				numberOfSkips: 40,
				userData: .init(isNew: false, dueDate: Date().addingTimeInterval(-10000))
			))
			.environmentObject(PREVIEW_CURRENT_STORE)
		}
		.padding(.horizontal, DecksView.horizontalPadding)
	}
}
#endif
