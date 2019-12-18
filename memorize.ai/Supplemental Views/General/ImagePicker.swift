import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
	final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
		@Binding var isShowing: Bool
		@Binding var image: Image?
		
		init(isShowing: Binding<Bool>, image: Binding<Image?>) {
			_isShowing = isShowing
			_image = image
		}
		
		func imagePickerController(
			_ picker: UIImagePickerController,
			didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
		) {
			guard let image = info[.originalImage] as? UIImage else { return }
			self.image = .init(uiImage: image)
			isShowing = false
		}
		
		func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			isShowing = false
		}
	}
	
	@Binding var isShowing: Bool
	@Binding var image: Image?
	
	let source: UIImagePickerController.SourceType
	
	init(
		isShowing: Binding<Bool>,
		image: Binding<Image?>,
		source: UIImagePickerController.SourceType = .photoLibrary
	) {
		_isShowing = isShowing
		_image = image
		self.source = source
	}
	
	func makeCoordinator() -> Coordinator {
		.init(isShowing: $isShowing, image: $image)
	}
	
	func makeUIViewController(context: Context) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.delegate = context.coordinator
		picker.sourceType = source
		return picker
	}
	
	func updateUIViewController(_ picker: UIImagePickerController, context: Context) {}
}

#if DEBUG
struct ImagePicker_Previews: PreviewProvider {
	static var previews: some View {
		ImagePicker(isShowing: .constant(true), image: .constant(nil))
	}
}
#endif
