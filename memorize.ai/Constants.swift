import UIKit
import Firebase
import DeviceKit

let MAX_FILE_SIZE: Int64 = 50 * 1024 * 1024
let COMPRESSION_QUALITY: CGFloat = 0.5
let JPEG_METADATA = StorageMetadata(mime: "image/jpeg")
let DEFAULT_E = 2.5
let DEFAULT_PROFILE_PICTURE = #imageLiteral(resourceName: "Person")
let DEFAULT_DECK_IMAGE = #imageLiteral(resourceName: "Gray Deck")
let UPLOAD_SOUND_ICON = #imageLiteral(resourceName: "Sound")
let DEFAULT_BLUE_COLOR = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
let DEFAULT_RED_COLOR = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
let CARD_POLL_INTERVAL: TimeInterval = 1
let PLACEHOLDER_DATE = Date()
let CURRENT_DEVICE = Device.realDevice(from: Device.current)
