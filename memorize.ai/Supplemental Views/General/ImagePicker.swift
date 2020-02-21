import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
	final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
		@Binding var isShowing: Bool
		@Binding var image: UIImage?
		
		init(isShowing: Binding<Bool>, image: Binding<UIImage?>) {
			_isShowing = isShowing
			_image = image
		}
		
		func imagePickerController(
			_ picker: UIImagePickerController,
			didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
		) {
			image = info[.originalImage] as? UIImage
			isShowing = false
		}
		
		func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			isShowing = false
		}
	}
	
	typealias Source = UIImagePickerController.SourceType
	
	@Binding var isShowing: Bool
	@Binding var image: UIImage?
	
	let source: Source
	
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

extension View {
	func imagePicker(
		isShowing: Binding<Bool>,
		image: Binding<UIImage?>,
		source: ImagePicker.Source = .photoLibrary
	) -> some View {
		sheet(isPresented: isShowing) {
			ImagePicker(
				isShowing: isShowing,
				image: image,
				source: source
			)
			.edgesIgnoringSafeArea(.all)
		}
	}
}

#if DEBUG
struct ImagePicker_Previews: PreviewProvider {
	static var previews: some View {
		ImagePicker(isShowing: .constant(true), image: .constant(nil), source: .photoLibrary)
	}
}
#endif
