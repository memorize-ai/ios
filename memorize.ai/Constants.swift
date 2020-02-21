import SwiftUI
import HTML

let SIDE_BAR_ANIMATION = Animation.easeOut(duration: 0.2)

let FIREBASE_STORAGE_MAX_FILE_SIZE: Int64 = 50 * 1024 * 1024

let IMAGE_COMPRESSION_QUALITY: CGFloat = 0.5

let MAX_NUMBER_OF_VIEWABLE_CARDS_IN_SECTION = 50
let MAX_NUMBER_OF_VIEWABLE_SECTIONS = 50

let APP_SEARCH_API_ENDPOINT = "https://host-fig55q.api.swiftype.com"

let DECKS_ENGINE_NAME = "memorize-ai-decks"
let DECKS_SEARCH_KEY = "search-no3fo2msypcfjc1p14upkg1c"

let APP_STORE_URL = "https://apps.apple.com/us/app/memorize-ai/id1462251805"

#if DEBUG
let WEB_URL = "https://memorize.ai" // "https://memorize-ai-dev.web.app"
#else
let WEB_URL = "https://memorize.ai"
#endif

let SUPPORT_EMAIL = "support@memorize.ai"

let APP_VERSION = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

var VIEWPORT_META_TAG: HTMLElement {
	HTMLElement.meta
		.name("viewport")
		.content("width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1")
}
