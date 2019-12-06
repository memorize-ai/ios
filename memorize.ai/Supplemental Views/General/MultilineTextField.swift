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
		@Binding var shouldSelect: Bool
		
		let font: UIFont
		let textColor: UIColor
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
			let textView = UITextView()
			textView.delegate = context.coordinator
			textView.font = font
			textView.textColor = textColor
			textView.isScrollEnabled = false
			textView.backgroundColor = nil
			if onDone != nil {
				textView.returnKeyType = .done
			}
			textView.setContentCompressionResistancePriority(
				.defaultLow,
				for: .horizontal
			)
			return textView
		}
		
		func updateUIView(_ textView: UITextView, context: Context) {
			textView.text = text
			if shouldSelect {
				shouldSelect = false
				textView.becomeFirstResponder()
			}
			Self.recalculateHeight(forView: textView, result: $calculatedHeight)
		}
	}
	
	@Binding var text: String
	
	let placeholder: String
	let font: UIFont
	let textColor: UIColor
	let placeholderColor: Color
	let backgroundColor: Color
	let onDone: (() -> Void)?
	
	@State private var dynamicHeight: CGFloat = 100
	@State private var isShowingPlaceholder = false
	@State private var shouldSelect = false
	
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
		textColor: UIColor = .gray,
		placeholderColor: Color = .black,
		backgroundColor: Color = .transparent,
		onDone: (() -> Void)? = nil
	) {
		_text = text
		_isShowingPlaceholder = .init(initialValue: text.wrappedValue.isEmpty)
		self.placeholder = placeholder
		self.font = font
		self.textColor = textColor
		self.placeholderColor = placeholderColor
		self.backgroundColor = backgroundColor
		self.onDone = onDone
	}
	
	var placeholderView: some View {
		Text(placeholder)
			.font(.muli(.regular, size: 14))
			.foregroundColor(placeholderColor)
			.padding(.leading, 4)
			.padding(.top, 8)
			.opacity(*isShowingPlaceholder)
			.onTapGesture {
				self.shouldSelect = true
			}
	}
		
	var body: some View {
		Wrapper(
			text: internalText,
			calculatedHeight: $dynamicHeight,
			shouldSelect: $shouldSelect,
			font: font,
			textColor: textColor,
			onDone: onDone
		)
		.frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
		.background(backgroundColor)
		.cornerRadius(5)
		.overlay(placeholderView, alignment: .topLeading)
	}
}
