import SwiftUI
import FirebaseAnalytics

struct SignOutButton<Label: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let label: Label
	
	init(label: () -> Label) {
		self.label = label()
	}
	
	var body: some View {
		Group {
			Button(action: {
				Analytics.logEvent("sign_out_clicked", parameters: [
					"view": "SignOutButton"
				])
				
				showAlert(title: "Sign out", message: "Are you sure?") { alert in
					alert.addAction(.init(title: "Cancel", style: .cancel) { _ in
						Analytics.logEvent("sign_out_canceled", parameters: [
							"view": "SignOutButton"
						])
					})
					alert.addAction(.init(title: "Sign out", style: .destructive) { _ in
						Analytics.logEvent("sign_out_confirmed", parameters: [
							"view": "SignOutButton"
						])
						
						self.currentStore.signOut()
					})
				}
			}) {
				label
			}
			if currentStore.signOutLoadingState.didSucceed {
				NavigateTo(
					InitialView(),
					when: $currentStore.signOutLoadingState.didSucceed
				)
			}
		}
	}
}

#if DEBUG
struct SignOutButton_Previews: PreviewProvider {
	static var previews: some View {
		SignOutButton {
			Text("Sign out")
		}
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif
