#if DEBUG

import SwiftUI

fileprivate let DEFAULT_PREVIEW_DEVICES = [
	"iPhone 8",
	"iPhone 8 Plus",
	"iPhone SE",
	"iPhone XS",
	"iPhone XS Max",
	"iPhone XR",
	"iPad Pro (9.7-inch)",
	"iPad Pro (10.5-inch)",
	"iPad Pro (12.9-inch)",
	"iPad Pro (12.9-inch) (3rd generation)"
]

func previewForDevices<Content: View>(
	_ devices: [String] = DEFAULT_PREVIEW_DEVICES,
	content: () -> Content
) -> some View {
	let view = content()
	return ForEach(devices, id: \.self) { deviceName in
		view
			.previewDevice(.init(rawValue: deviceName))
			.previewDisplayName(deviceName)
	}
}

let PREVIEW_CURRENT_STORE: CurrentStore = {
	let failedDeck = Deck(
		id: "6",
		topics: [],
		hasImage: true,
		name: "Geometry Prep #7",
		subtitle: "Angles, lines, triangles and other polygons",
		numberOfViews: 1000000000,
		numberOfUniqueViews: 200000,
		numberOfRatings: 12400,
		averageRating: 4.5,
		numberOfDownloads: 196400,
		dateCreated: .init(),
		dateLastUpdated: .init(),
		userData: .init(
			dateAdded: .init(),
			isFavorite: true,
			numberOfDueCards: 12
		)
	)
	failedDeck.imageLoadingState.fail(message: "Self-invoked")
	let currentStore = CurrentStore(user: .init(
		id: "0",
		name: "Ken Mueller",
		email: "kenmueller0@gmail.com",
		interests: [
			"0",
			"1",
			"2",
			"3"
		],
		numberOfDecks: 7,
		xp: 930,
		decks: [
			.init(
				id: "0",
				topics: [],
				hasImage: true,
				image: .init("GeometryPrepDeck"),
				name: "Geometry Prep #1",
				subtitle: "Angles, lines, triangles and other polygons",
				numberOfViews: 1000000000,
				numberOfUniqueViews: 200000,
				numberOfRatings: 12400,
				averageRating: 4.5,
				numberOfDownloads: 196400,
				dateCreated: .init(),
				dateLastUpdated: .init(),
				userData: .init(
					dateAdded: .init(),
					isFavorite: false,
					numberOfDueCards: 23
				)
			),
			.init(
				id: "1",
				topics: [],
				hasImage: true,
				image: .init("GeometryPrepDeck"),
				name: "Geometry Prep #2",
				subtitle: "Angles, lines, triangles and other polygons",
				numberOfViews: 1000000000,
				numberOfUniqueViews: 200000,
				numberOfRatings: 12400,
				averageRating: 4.5,
				numberOfDownloads: 196400,
				dateCreated: .init(),
				dateLastUpdated: .init(),
				userData: .init(
					dateAdded: .init(),
					isFavorite: true,
					numberOfDueCards: 0
				)
			),
			.init(
				id: "2",
				topics: [],
				hasImage: true,
				image: .init("GeometryPrepDeck"),
				name: "Geometry Prep #3",
				subtitle: "Angles, lines, triangles and other polygons",
				numberOfViews: 1000000000,
				numberOfUniqueViews: 200000,
				numberOfRatings: 12400,
				averageRating: 4.5,
				numberOfDownloads: 196400,
				dateCreated: .init(),
				dateLastUpdated: .init()
			),
			.init(
				id: "3",
				topics: [],
				hasImage: true,
				image: .init("GeometryPrepDeck"),
				name: "Geometry Prep #4",
				subtitle: "Angles, lines, triangles and other polygons",
				numberOfViews: 1000000000,
				numberOfUniqueViews: 200000,
				numberOfRatings: 12400,
				averageRating: 4.5,
				numberOfDownloads: 196400,
				dateCreated: .init(),
				dateLastUpdated: .init(),
				userData: .init(
					dateAdded: .init(),
					isFavorite: true,
					numberOfDueCards: 36
				)
			),
			.init(
				id: "4",
				topics: [],
				hasImage: false,
				name: "Geometry Prep #5",
				subtitle: "Angles, lines, triangles and other polygons",
				numberOfViews: 1000000000,
				numberOfUniqueViews: 200000,
				numberOfRatings: 12400,
				averageRating: 4.5,
				numberOfDownloads: 196400,
				dateCreated: .init(),
				dateLastUpdated: .init(),
				userData: .init(
					dateAdded: .init(),
					isFavorite: false,
					numberOfDueCards: 568
				)
			),
			.init(
				id: "5",
				topics: [],
				hasImage: true,
				name: "Geometry Prep #6",
				subtitle: "Angles, lines, triangles and other polygons",
				numberOfViews: 1000000000,
				numberOfUniqueViews: 200000,
				numberOfRatings: 12400,
				averageRating: 4.5,
				numberOfDownloads: 196400,
				dateCreated: .init(),
				dateLastUpdated: .init(),
				userData: .init(
					dateAdded: .init(),
					isFavorite: true,
					numberOfDueCards: 1
				)
			),
			failedDeck
		]
	))
	currentStore.topics = [
		.init(
			id: "0",
			name: "Math",
			image: .init("HTMLTopic")
		),
		.init(
			id: "1",
			name: "Geometry",
			image: .init("GeographyTopic")
		),
		.init(
			id: "2",
			name: "History",
			image: .init("HTMLTopic")
		),
		.init(
			id: "3",
			name: "Web Dev",
			image: .init("GeographyTopic")
		)
	]
	currentStore.recommendedDecks = [
		.init(
			id: "0",
			topics: [],
			hasImage: true,
			image: .init("GeometryPrepDeck"),
			name: "Geometry Prep #1",
			subtitle: "Angles, lines, triangles and other polygons",
			numberOfViews: 1000000000,
			numberOfUniqueViews: 200000,
			numberOfRatings: 12400,
			averageRating: 4.5,
			numberOfDownloads: 196400,
			dateCreated: .init(),
			dateLastUpdated: .init(),
			userData: .init(
				dateAdded: .init(),
				isFavorite: false,
				numberOfDueCards: 23
			)
		),
		.init(
			id: "1",
			topics: [],
			hasImage: true,
			image: .init("GeometryPrepDeck"),
			name: "Geometry Prep #2",
			subtitle: "Angles, lines, triangles and other polygons",
			numberOfViews: 1000000000,
			numberOfUniqueViews: 200000,
			numberOfRatings: 12400,
			averageRating: 4.5,
			numberOfDownloads: 196400,
			dateCreated: .init(),
			dateLastUpdated: .init(),
			userData: .init(
				dateAdded: .init(),
				isFavorite: true,
				numberOfDueCards: 0
			)
		),
		.init(
			id: "2",
			topics: [],
			hasImage: true,
			image: .init("GeometryPrepDeck"),
			name: "Geometry Prep #3",
			subtitle: "Angles, lines, triangles and other polygons",
			numberOfViews: 1000000000,
			numberOfUniqueViews: 200000,
			numberOfRatings: 12400,
			averageRating: 4.5,
			numberOfDownloads: 196400,
			dateCreated: .init(),
			dateLastUpdated: .init()
		),
		.init(
			id: "3",
			topics: [],
			hasImage: true,
			image: .init("GeometryPrepDeck"),
			name: "Geometry Prep #4",
			subtitle: "Angles, lines, triangles and other polygons",
			numberOfViews: 1000000000,
			numberOfUniqueViews: 200000,
			numberOfRatings: 12400,
			averageRating: 4.5,
			numberOfDownloads: 196400,
			dateCreated: .init(),
			dateLastUpdated: .init(),
			userData: .init(
				dateAdded: .init(),
				isFavorite: true,
				numberOfDueCards: 36
			)
		),
		.init(
			id: "4",
			topics: [],
			hasImage: false,
			name: "Geometry Prep #5",
			subtitle: "Angles, lines, triangles and other polygons",
			numberOfViews: 1000000000,
			numberOfUniqueViews: 200000,
			numberOfRatings: 12400,
			averageRating: 4.5,
			numberOfDownloads: 196400,
			dateCreated: .init(),
			dateLastUpdated: .init(),
			userData: .init(
				dateAdded: .init(),
				isFavorite: false,
				numberOfDueCards: 568
			)
		),
		.init(
			id: "5",
			topics: [],
			hasImage: true,
			name: "Geometry Prep #6",
			subtitle: "Angles, lines, triangles and other polygons",
			numberOfViews: 1000000000,
			numberOfUniqueViews: 200000,
			numberOfRatings: 12400,
			averageRating: 4.5,
			numberOfDownloads: 196400,
			dateCreated: .init(),
			dateLastUpdated: .init(),
			userData: .init(
				dateAdded: .init(),
				isFavorite: true,
				numberOfDueCards: 1
			)
		)
	]
	return currentStore
}()

#endif
