import SwiftUI

final class HostingController<T: View>: UIHostingController<T> {
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
}
