import SwiftUI

struct PublishDeckView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var model: PublishDeckViewModel
	
	init(deck: Deck? = nil) {
		model = .init(deck: deck)
	}
	
	var imagePopUp: some View {
		PopUp(
			isShowing: $model.isImagePopUpShowing,
			contentHeight: 50 * (2 + *(model.image != nil))
		) {
			PopUpButton(
				icon: Image.camera
					.resizable()
					.renderingMode(.original)
					.aspectRatio(contentMode: .fit)
					.frame(width: 21, height: 21),
				text: "Camera",
				textColor: .darkGray
			) {
				self.model.showImagePicker(source: .camera)
			}
			PopUpButton(
				icon: Image.photoLibrary
					.resizable()
					.renderingMode(.original)
					.aspectRatio(contentMode: .fit)
					.frame(width: 21, height: 21),
				text: "Photo library",
				textColor: .darkGray
			) {
				self.model.showImagePicker(source: .photoLibrary)
			}
			if model.image != nil {
				PopUpButton(
					icon: Image.redTrashIcon
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 21, height: 21),
					text: "Remove image",
					textColor: .darkGray
				) {
					popUpWithAnimation {
						self.model.image = nil
						self.model.isImagePopUpShowing = false
					}
				}
			}
		}
	}
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				HomeViewTopGradient(
					addedHeight: geometry.safeAreaInsets.top
				)
				.edgesIgnoringSafeArea(.all)
				VStack {
					PublishDeckViewTopControls()
						.environmentObject(self.model)
						.padding(.horizontal, 23)
					ScrollView {
						PublishDeckViewContentBox()
							.environmentObject(self.model)
							.padding(.horizontal, 12)
							.respondsToKeyboard(
								withExtraOffset: geometry.safeAreaInsets.bottom + 12
							)
					}
				}
				self.imagePopUp
			}
			.imagePicker(
				isShowing: self.$model.isImagePickerShowing,
				image: self.$model.image,
				source: self.model.imagePickerSource
			)
		}
	}
}

#if DEBUG
struct PublishDeckView_Previews: PreviewProvider {
	static var previews: some View {
		PublishDeckView()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif
