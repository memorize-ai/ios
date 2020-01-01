import SwiftUI
import Combine

struct KeyboardResponder: ViewModifier {
	static var publisher: AnyPublisher<CGFloat, Never> {
		Publishers.Merge(
			NotificationCenter.default
				.publisher(for: UIResponder.keyboardWillShowNotification)
				.compactMap {
					$0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
				}
				.map { $0.cgRectValue.height },
			NotificationCenter.default
				.publisher(for: UIResponder.keyboardWillHideNotification)
				.map { _ in 0 }
		).eraseToAnyPublisher()
	}
	
	@State var keyboardHeight: CGFloat = 0

	func body(content: Content) -> some View {
		content
			.padding(.bottom, keyboardHeight)
			.onReceive(Self.publisher) { self.keyboardHeight = $0 }
	}
}

extension View {
	func respondsToKeyboard() -> some View {
		ModifiedContent(content: self, modifier: KeyboardResponder())
	}
}
