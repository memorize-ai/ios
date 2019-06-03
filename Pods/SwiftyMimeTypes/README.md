# SwiftyMimeTypes

[![CI Status](http://img.shields.io/travis/tiwoc/SwiftyMimeTypes.svg?style=flat)](https://travis-ci.org/tiwoc/SwiftyMimeTypes)
[![Version](https://img.shields.io/cocoapods/v/SwiftyMimeTypes.svg?style=flat)](http://cocoapods.org/pods/SwiftyMimeTypes)
[![License](https://img.shields.io/cocoapods/l/SwiftyMimeTypes.svg?style=flat)](http://cocoapods.org/pods/SwiftyMimeTypes)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyMimeTypes.svg?style=flat)](http://cocoapods.org/pods/SwiftyMimeTypes)

SwiftyMimeTypes is a database of MIME types and filename extensions.
Use it if you need to know the appropriate MIME type for a given filename
or the extensions associated with a given MIME type.

## Example

SwiftyMimeTypes is a really small library with a simple interface.

### Get a filename extension for a given MIME type

```swift
// prints "js"
print(MimeTypes.filenameExtension(forType: "application/javascript"))
```

### Get all known filename extensions for a given MIME type

```swift
// prints ["md", "markdown"]
print(MimeTypes.filenameExtensions(forType: "text/markdown"))
```

### Get the MIME type for a given filename extension

```swift
// prints "application/javascript"
print(MimeTypes.mimeType(forExtension: "js"))
```

## Requirements

Xcode 9.x and Swift 4.x (use version 1.x or the `swift3` branch for Xcode 8 and Swift 3 compatibility)

## Installation

SwiftyMimeTypes is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftyMimeTypes"
```

### Swift Package Manager (SPM)

There's no SPM support yet, as there's currently no way to include resources (the mime.types file) with targets. See [bug SR-2866](https://bugs.swift.org/browse/SR-2866) for details.

## Author

Daniel Seither, d@fdseither.de

## License

```
Copyright 2016, 2017, 2018 Daniel Seither <d@fdseither.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
