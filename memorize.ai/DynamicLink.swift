import Foundation

func createDynamicLink(_ ext: String? = nil, title: String, description: String, imageURL imageUrl: String, minimumVersion: String = "1.0") -> URL? {
	return URL(string: "\(DYNAMIC_LINK_BASE_URL)/?link=\(MEMORIZE_AI_BASE_URL)\(ext == nil ? "" : "/\(ext ?? "")")&ibi=ai.memorize.memorize-ai&ipbi=ai.memorize.memorize-ai&isi=1462251805&imv=\(minimumVersion)&st=\(title)&sd=\(description)&si=\(imageUrl)")
}

func createLink(_ ext: String? = nil) -> URL? {
	return URL(string: "\(MEMORIZE_AI_BASE_URL)\(ext == nil ? "" : "/\(ext ?? "")")")
}
