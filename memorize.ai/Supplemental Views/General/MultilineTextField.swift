import SwiftUI

struct MultilineTextField: View {
	struct Wrapper: UIViewRepresentable {
		final class Coordinator: NSObject, UITextViewDelegate {
			@Binding var text: String
			@Binding var calculatedHeight: CGFloat
			
			let onDone: (() -> Void)?
			
			init(
				text: Binding<String>,
				height: Binding<CGFloat>,
				onDone: (() -> Void)? = nil
			) {
				_text = text
				_calculatedHeight = height
				self.onDone = onDone
			}

			func textViewDidChange(_ textView: UITextView) {
				text = textView.text
				Wrapper.recalculateHeight(forView: textView, result: $calculatedHeight)
			}

			func textView(
				_ textView: UITextView,
				shouldChangeTextIn range: NSRange,
				replacementText text: String
			) -> Bool {
				if let onDone = onDone, text == "\n" {
					textView.resignFirstResponder()
					onDone()
					return false
				}
				return true
			}
		}
		
		@Binding var text: String
		@Binding var calculatedHeight: CGFloat
		
		let font: UIFont
		let onDone: (() -> Void)?
		
		static func recalculateHeight(forView view: UIView, result: Binding<CGFloat>) {
			let newSize = view.sizeThatFits(.init(
				width: view.frame.size.width,
				height: .greatestFiniteMagnitude
			))
			if result.wrappedValue != newSize.height {
				DispatchQueue.main.async {
					result.wrappedValue = newSize.height
				}
			}
		}
		
		func makeCoordinator() -> Coordinator {
			.init(text: $text, height: $calculatedHeight, onDone: onDone)
		}
		
		func makeUIView(context: Context) -> UITextView {
			let textField = UITextView()
			textField.delegate = context.coordinator
			textField.font = font
			textField.isScrollEnabled = false
			if onDone != nil {
				textField.returnKeyType = .done
			}
			textField.setContentCompressionResistancePriority(
				.defaultLow,
				for: .horizontal
			)
			return textField
		}
		
		func updateUIView(_ textView: UITextView, context: Context) {
			textView.text = text
			if !(textView.window == nil || textView.isFirstResponder) {
				textView.becomeFirstResponder()
			}
			Self.recalculateHeight(forView: textView, result: $calculatedHeight)
		}
	}
	
	@Binding var text: String
	
	let placeholder: String
	let font: UIFont
	let onDone: (() -> Void)?
	
	@State private var dynamicHeight: CGFloat = 100
	@State private var isShowingPlaceholder = false
	
	private var internalText: Binding<String> {
		.init(get: { self.text }) {
			self.text = $0
			self.isShowingPlaceholder = $0.isEmpty
		}
	}
	
	init(
		text: Binding<String>,
		placeholder: String = "",
		font: UIFont = .preferredFont(forTextStyle: .body),
		onDone: (() -> Void)? = nil
	) {
		_text = text
		_isShowingPlaceholder = .init(initialValue: text.wrappedValue.isEmpty)
		self.placeholder = placeholder
		self.font = font
		self.onDone = onDone
	}
	
	var placeholderView: some View {
		Text(placeholder)
			.foregroundColor(.gray)
			.padding(.leading, 4)
			.padding(.top, 8)
			.opacity(*isShowingPlaceholder)
	}
		
	var body: some View {
		Wrapper(text: internalText, calculatedHeight: $dynamicHeight, font: font, onDone: onDone)
			.frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
			.overlay(placeholderView, alignment: .topLeading)
	}
}
