/*
 Copyright 2016, 2017 Daniel Seither <d@fdseither.de>

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

class MimeType {
    let mimeType: String
    let extensions: [String]

    init(mimeType: String, extensions: [String]) {
        precondition(extensions.count > 0, "MIME type must have one or more extensions")

        self.mimeType = mimeType
        self.extensions = extensions
    }
}

/// Simple interface to the MIME type database
public class MimeTypes {

    /// Returns an appropriate filename extension for the given MIME type
    public class func filenameExtension(forType type: String) -> String? {
        return MimeTypes.shared.filenameExtension(forType: type)
    }

    /// Returns all known filename extension for the given MIME type
    public class func filenameExtensions(forType type: String) -> [String] {
        return MimeTypes.shared.filenameExtensions(forType: type)
    }

    /// Returns the MIME type for the given filename extension
    public class func mimeType(forExtension ext: String) -> String? {
        return MimeTypes.shared.mimeType(forExtension: ext)
    }

    private static let shared = MimeTypes()

    private var byType = [String: MimeType]()
    private var byExtension = [String: MimeType]()

    private init() {
        let dbText = MimeTypes.readDBFromBundle()
        dbText.enumerateLines { line, _ in
            let fields = line.components(separatedBy: " ")
            if fields.count < 2 { return }
            let type = MimeType(mimeType: fields[0], extensions: Array(fields.suffix(from: 1)))

            self.byType[type.mimeType] = type
            for ext in type.extensions {
                self.byExtension[ext] = type
            }
        }
    }

    func filenameExtension(forType type: String) -> String? {
        return byType[type]?.extensions.first
    }

    func filenameExtensions(forType type: String) -> [String] {
        return byType[type]?.extensions ?? []
    }

    func mimeType(forExtension ext: String) -> String? {
        return byExtension[ext]?.mimeType
    }

    private static func readDBFromBundle() -> String {
        let toplevelBundle = Bundle(for: MimeType.self)

        guard let assetBundleUrl = toplevelBundle.url(forResource: "SwiftyMimeTypes", withExtension: "bundle") else {
            preconditionFailure("SwiftyMimeTypes bundle not found")
        }

        guard let assetBundle = Bundle(url: assetBundleUrl) else {
            preconditionFailure("SwiftyMimeTypes bundle could not be loaded")
        }

        guard let dbUrl = assetBundle.url(forResource: "mime", withExtension: "types") else {
            preconditionFailure("mime.types could not be found")
        }

        do {
            return try String(contentsOf: dbUrl, encoding: String.Encoding.utf8)
        } catch _ {
            preconditionFailure("mime.types could not be loaded")
        }
    }
}
