import SwiftUI

struct SignOutButton<Label: View>: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	let label: Label
	
	init(label: () -> Label) {
		self.label = label()
	}
	
	var body: some View {
		Group {
			Button(action: {
				showAlert(title: "Sign out", message: "Are you sure?") { alert in
					alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
					alert.addAction(.init(title: "Sign out", style: .destructive) { _ in
						self.currentStore.signOut()
					})
				}
			}) {
				label
			}
			NavigateTo(
				InitialView(),
				when: $currentStore.signOutLoadingState.didSucceed
			)
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
