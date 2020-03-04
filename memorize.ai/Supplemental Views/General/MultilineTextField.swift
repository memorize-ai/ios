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
			Self.recalculateHeight(forView: textView, result: $calculatedHeight)
		}
	}
	
	@Binding var text: String
	
	let font: UIFont
	let textColor: UIColor
	let backgroundColor: Color
	let minHeight: CGFloat
	let onDone: (() -> Void)?
	
	@State var dynamicHeight: CGFloat = 100
	
	init(
		text: Binding<String>,
		font: UIFont = .preferredFont(forTextStyle: .body),
		textColor: UIColor = .gray,
		backgroundColor: Color = .clear,
		minHeight: CGFloat = 100,
		onDone: (() -> Void)? = nil
	) {
		_text = text
		self.font = font
		self.textColor = textColor
		self.backgroundColor = backgroundColor
		self.minHeight = minHeight
		self.onDone = onDone
	}
	
	var height: CGFloat {
		max(minHeight, dynamicHeight)
	}
	
	var body: some View {
		Wrapper(
			text: $text,
			calculatedHeight: $dynamicHeight,
			font: font,
			textColor: textColor,
			onDone: onDone
		)
		.frame(minHeight: height, maxHeight: height)
		.padding(.leading, 6)
		.background(backgroundColor)
		.cornerRadius(5)
	}
}
