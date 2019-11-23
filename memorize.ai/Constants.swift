import SwiftUI

let SIDE_BAR_ANIMATION = Animation.easeOut(duration: 0.2)

let FIREBASE_STORAGE_MAX_FILE_SIZE: Int64 = 50 * 1024 * 1024

#if DEBUG
let FIREBASE_CLIENT_ID =
	"282248067698-skch2gq825n9oaeg9cji635suc47k9un.apps.googleusercontent.com"
#else
let FIREBASE_CLIENT_ID =
	"629763488334-it1ah74o98fl27f0nvjorjks5ms0auqu.apps.googleusercontent.com"
#endif

let APP_SEARCH_API_ENDPOINT = "https://host-fig55q.api.swiftype.com"

let DECKS_ENGINE_NAME = "memorize-ai-decks"
let DECKS_SEARCH_KEY = "search-no3fo2msypcfjc1p14upkg1c"
