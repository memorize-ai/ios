import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
	final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
		@Binding var options: Options?
		@Binding var result: Result?
		
		init(options: Binding<Options?>, result: Binding<Result?>) {
			_options = options
			_result = result
		}
		
		func mailComposeController(
			_ controller: MFMailComposeViewController,
			didFinishWith result: MFMailComposeResult,
			error: Error?
		) {
			defer {
				options = nil
			}
			
			if let error = error {
				return self.result = .failure(error)
			}
			
			self.result = .success(result)
		}
	}
	
	struct Options {
		let recipients: [String]
		let subject: String
		let body: String
		let isHTML: Bool
		
		init(
			recipients: [String],
			subject: String,
			body: String,
			isHTML: Bool = false
		) {
			self.recipients = recipients
			self.subject = subject
			self.body = body
			self.isHTML = isHTML
		}
		
		init(
			recipient: String,
			subject: String,
			body: String,
			isHTML: Bool = false
		) {
			self.init(
				recipients: [recipient],
				subject: subject,
				body: body,
				isHTML: isHTML
			)
		}
		
		func configure(_ composeViewController: MFMailComposeViewController) {
			composeViewController.setToRecipients(recipients)
			composeViewController.setSubject(subject)
			composeViewController.setMessageBody(body, isHTML: isHTML)
		}
	}
	
	typealias Result = Swift.Result<MFMailComposeResult, Error>
	
	static var canSendMail: Bool {
		MFMailComposeViewController.canSendMail()
	}
	
	@Binding var options: Options?
	@Binding var result: Result?
	
	func makeCoordinator() -> Coordinator {
		.init(options: $options, result: $result)
	}
	
	func makeUIViewController(context: Context) -> MFMailComposeViewController {
		let composeViewController = MFMailComposeViewController()
		
		composeViewController.mailComposeDelegate = context.coordinator
		options?.configure(composeViewController)
		
		return composeViewController
	}
	
	func updateUIViewController(
		_ composeViewController: MFMailComposeViewController,
		context: Context
	) {}
}

extension View {
	func mailView(
		options: Binding<MailView.Options?>,
		result: Binding<MailView.Result?> = .constant(nil)
	) -> some View {
		sheet(isPresented: .init(
			get: {
				options.wrappedValue != nil &&
				MailView.canSendMail
			},
			set: { _ in }
		)) {
			MailView(options: options, result: result)
				.edgesIgnoringSafeArea(.all)
		}
	}
}

struct MailView_Previews: PreviewProvider {
    static var previews: some View {
		MailView(options: .constant(nil), result: .constant(nil))
    }
}
