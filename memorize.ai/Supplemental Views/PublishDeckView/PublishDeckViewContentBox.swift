import SwiftUI

struct PublishDeckViewContentBox: View {
	@EnvironmentObject var model: PublishDeckViewModel
	
	var imageDimension: CGFloat {
		min(160, SCREEN_SIZE.width - (12 + 20) * 2)
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
					// TODO: Show camera roll
				}) {
					Group {
						if self.model.image == nil {
							VStack {
								// TODO: Add icon
								Text("Add image")
							}
						} else {
							model.image?
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
			}
			.padding()
		}
	}
}

#if DEBUG
struct PublishDeckViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		PublishDeckViewContentBox()
			.environmentObject(PublishDeckViewModel())
	}
}
#endif
