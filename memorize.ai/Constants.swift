import UIKit
import Firebase
import DeviceKit

let MAX_FILE_SIZE: Int64 = 50 * 1024 * 1024
let COMPRESSION_QUALITY: CGFloat = 0.5
let JPEG_METADATA = StorageMetadata(mime: "image/jpeg")
let DEFAULT_E = 2.5
let DEFAULT_PROFILE_PICTURE = #imageLiteral(resourceName: "Person")
let DEFAULT_BACKGROUND_IMAGE_COLOR: UIColor = .lightGray
let DEFAULT_DECK_IMAGE = #imageLiteral(resourceName: "Gray Deck")
let UPLOAD_SOUND_ICON = #imageLiteral(resourceName: "Sound")
let DEFAULT_BLUE_COLOR = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
let DEFAULT_RED_COLOR = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
let CARD_POLL_INTERVAL: TimeInterval = 1
let PLACEHOLDER_DATE = Date()
#if targetEnvironment(simulator)
let CURRENT_DEVICE = Device.current.realDevice
#else
let CURRENT_DEVICE = Device.current
#endif
let CURRENT_DEVICE_IS_IPAD = CURRENT_DEVICE.isOneOf(Device.allPads)
let CURRENT_DEVICE_HAS_ROUNDED_CORNERS = CURRENT_DEVICE.isOneOf(Device.allDevicesWithRoundedDisplayCorners)
let MEMORIZE_AI_BASE_URL = "https://memorize.ai"
let MEMORIZE_AI_SUPPORT_EMAIL = "support@memorize.ai"
let PLACEHOLDER_FIELD_VALUE = "x"
let APP_VERSION = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
