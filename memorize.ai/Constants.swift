import SwiftUI

let SIDE_BAR_ANIMATION = Animation.easeOut(duration: 0.2)

let FIREBASE_STORAGE_MAX_FILE_SIZE: Int64 = 50 * 1024 * 1024

let APP_SEARCH_API_ENDPOINT = "https://host-fig55q.api.swiftype.com"

let DECKS_ENGINE_NAME = "memorize-ai-decks"
let DECKS_SEARCH_KEY = "search-no3fo2msypcfjc1p14upkg1c"

let HTML_ELEMENTS = ["a", "abbr", "acronym", "abbr", "address", "applet", "object", "article", "aside", "audio", "b", "basefont", "bdi", "bdo", "big", "blockquote", "body", "button", "canvas", "caption", "center", "cite", "code", "colgroup", "data", "datalist", "dd", "del", "details", "dfn", "dialog", "dir", "ul", "div", "dl", "dt", "em", "fieldset", "figcaption", "figure", "font", "footer", "form", "frame", "frameset", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "html", "i", "iframe", "ins", "kbd", "label", "legend", "li", "main", "map", "mark", "meter", "nav", "noframes", "noscript", "object", "ol", "optgroup", "option", "output", "p", "picture", "pre", "progress", "q", "rp", "rt", "ruby", "s", "samp", "script", "section", "select", "small", "span", "strike", "del", "s", "strong", "style", "sub", "summary", "sup", "svg", "table", "tbody", "td", "template", "textarea", "tfoot", "th", "thead", "time", "title", "tr", "tt", "u", "ul", "var", "video"]
let HTML_VOID_ELEMENTS = ["area", "base", "br", "col", "command", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr"]

let IMAGE_COMPRESSION_QUALITY: CGFloat = 0.5

let APP_STORE_URL = "https://apps.apple.com/us/app/memorize-ai/id1462251805"

#if DEBUG
let WEB_URL = "https://memorize.ai" // "https://memorize-ai-dev.web.app"
#else
let WEB_URL = "https://memorize.ai"
#endif
