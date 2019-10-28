#if DEBUG

import SwiftUI

fileprivate let DEFAULT_PREVIEW_DEVICES = [
	"iPhone 8",
	"iPhone 8 Plus",
	"iPhone SE",
	"iPhone XS",
	"iPhone XS Max",
	"iPhone XR",
	"iPad Pro (9.7-inch)",
	"iPad Pro (10.5-inch)",
	"iPad Pro (12.9-inch)",
	"iPad Pro (12.9-inch) (3rd generation)"
]

func previewForDevices<Content: View>(
	_ devices: [String] = DEFAULT_PREVIEW_DEVICES,
	content: () -> Content
) -> some View {
	let view = content()
	return ForEach(devices, id: \.self) { deviceName in
		view
			.previewDevice(.init(rawValue: deviceName))
			.previewDisplayName(deviceName)
	}
}

#endif
