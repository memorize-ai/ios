import Foundation
import FirebaseDynamicLinks

var dynamicLinkHandler: ((DynamicLinkType) -> Void)?
var loadedDynamicLink: DynamicLinkType?

@discardableResult
func createDynamicLink(_ ext: String? = nil, title: String, description: String, imageURL imageUrl: URL, minimumVersion: String = "1.0", completion: @escaping (URL?) -> Void) -> URL? {
	guard let link = URL(string: "\(MEMORIZE_AI_BASE_URL)\(ext == nil ? "" : "/\(ext ?? "")")"), let components = DynamicLinkComponents(link: link, domainURIPrefix: DYNAMIC_LINK_BASE_URL) else { return nil }
	components.iOSParameters = DynamicLinkIOSParameters(bundleID: "ai.memorize.memorize-ai")
	components.iOSParameters?.appStoreID = "1462251805"
	components.iOSParameters?.minimumAppVersion = minimumVersion
	components.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
	components.socialMetaTagParameters?.title = title
	components.socialMetaTagParameters?.descriptionText = description
	components.socialMetaTagParameters?.imageURL = imageUrl
	components.shorten { completion($2 == nil ? $0 : nil) }
	return components.url
}

func createLink(_ ext: String? = nil) -> URL? {
	return URL(string: "\(MEMORIZE_AI_BASE_URL)\(ext == nil ? "" : "/\(ext ?? "")")")
}

func callDynamicLinkHandler(_ type: DynamicLinkType) {
	dynamicLinkHandler?(type)
	loadedDynamicLink = type
}

enum DynamicLinkType {
	case deck(id: String, hasImage: Bool)
	case user(id: String)
}
