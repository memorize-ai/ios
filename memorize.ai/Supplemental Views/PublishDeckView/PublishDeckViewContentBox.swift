import SwiftUI

struct PublishDeckViewContentBox: View {
	static let topicCellSpacing: CGFloat = 8
	static let numberOfTopicColumns =
		Int(SCREEN_SIZE.width) / Int(TopicCell.dimension)
	
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: PublishDeckViewModel
	
	var maxWidth: CGFloat {
		SCREEN_SIZE.width - (12 + 20) * 2
	}
	
	var imageDimension: CGFloat {
		min(160, maxWidth)
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1.5,
			shadowRadius: 5,
			shadowYOffset: 5
		) {
			VStack {
				Button(action: {
					popUpWithAnimation {
						self.model.isImagePopUpShowing = true
					}
				}) {
					Group {
						if self.model.image == nil {
							VStack {
                                Image.addImage
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40)
								Text("Add Image")
                                    .font(.muli(.regular, size: 17))
                                    .foregroundColor(.lightGrayText)
                                    .padding(.horizontal)
                                    .padding(.top, 3)
							}
						} else {
							model.displayImage?
								.resizable()
								.renderingMode(.original)
								.aspectRatio(contentMode: .fill)
						}
					}
					.frame(width: imageDimension, height: imageDimension)
					.background(CustomTextField.defaultBackgroundColor)
					.cornerRadius(5)
					.clipped()
				}
				CustomTextField(
					$model.name,
					placeholder: "Name (eg. SAT Math Prep)",
					contentType: .name,
					capitalization: .words
				)
				CustomTextField(
					$model.subtitle,
					placeholder: "Subtitle (eg. The best way to study for the SAT)",
					capitalization: .sentences
				)
				Text("Description")
					.font(.muli(.regular, size: 14))
					.foregroundColor(Color.darkText.opacity(0.5))
					.align(to: .leading)
					.padding(.top, 6)
					.padding(.bottom, -4)
				MultilineTextField(
					text: $model.description,
					font: UIFont(
						name: MuliFont.regular.rawValue,
						size: 14
					) ?? .preferredFont(forTextStyle: .body),
					textColor: #colorLiteral(red: 0.4666666667, green: 0.4666666667, blue: 0.4666666667, alpha: 1),
					backgroundColor: CustomTextField.defaultBackgroundColor
				)
				VStack(spacing: 16) {
					if model.topics.isEmpty {
						Text("Warning: Decks need topics to be recommended")
							.font(.muli(.bold, size: 13))
							.foregroundColor(.darkRed)
							.align(to: .leading)
					}
					Grid(
						elements: currentStore.topics.map { topic in
							TopicCell(
								topic: topic,
								isSelected: model.isTopicSelected(topic)
							) {
								self.model.toggleTopicSelect(topic)
							}
						},
						columns: Self.numberOfTopicColumns,
						horizontalSpacing: Self.topicCellSpacing,
						verticalSpacing: Self.topicCellSpacing
					)
					.frame(maxWidth: maxWidth)
				}
				.padding(.top, 12)
			}
			.padding()
		}
	}
}

#if DEBUG
struct PublishDeckViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		PublishDeckViewContentBox()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(PublishDeckViewModel())
	}
}
#endif
