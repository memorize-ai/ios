import Foundation

protocol Linkable {
	var dynamicLink: URL? { get }
	var link: URL? { get }
}

func createDynamicLink(_ ext: String? = nil) -> URL? {
	return URL(string: "\(DYNAMIC_LINK_BASE_URL)\(ext == nil ? "" : "/\(ext ?? "")")")
}

func createLink(_ ext: String? = nil) -> URL? {
	return URL(string: "\(MEMORIZE_AI_BASE_URL)\(ext == nil ? "" : "/\(ext ?? "")")")
}
