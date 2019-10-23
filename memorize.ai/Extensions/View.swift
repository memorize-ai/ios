import SwiftUI

extension View {
	func removeNavigationBar() -> some View {
		navigationBarTitle("").navigationBarHidden(true)
	}
}
