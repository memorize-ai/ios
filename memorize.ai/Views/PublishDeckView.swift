import SwiftUI

struct PublishDeckView: View { // FIXME: Doesn't update the view when model updates the first time this is opened
    @EnvironmentObject var model: PublishDeckViewModel
	
	var imagePopUp: some View {
		PopUp(
			isShowing: $model.isImagePopUpShowing,
			contentHeight: 50 * 2
		) {
			PopUpButton(
				icon: nil as EmptyView?, // TODO: Add image
				text: "Camera",
				textColor: .darkGray
			) {
				self.model.showImagePicker(source: .camera)
			}
			PopUpButton(
				icon: nil as EmptyView?, // TODO: Add image
				text: "Photo library",
				textColor: .darkGray
			) {
				self.model.showImagePicker(source: .photoLibrary)
			}
		}
	}
	
	var imagePicker: ImagePicker {
		.init(
			isShowing: $model.isImagePickerShowing,
			image: $model.image,
			source: model.imagePickerSource
		)
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
						.padding(.horizontal, 23)
					ScrollView {
						PublishDeckViewContentBox()
							.padding(.horizontal, 12)
					}
				}
				self.imagePopUp
				if self.model.isImagePickerShowing {
					self.imagePicker
				}
			}
		}
	}
}

#if DEBUG
struct PublishDeckView_Previews: PreviewProvider {
	static var previews: some View {
		PublishDeckView()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(PublishDeckViewModel())
	}
}
#endif
