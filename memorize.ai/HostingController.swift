import SwiftUI

final class HostingController<Content: View>: UIHostingController<Content> {
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
}
