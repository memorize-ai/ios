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
	let failedDeck = Deck._new(
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
		numberOfCards: 19640,
		creatorId: "0",
		dateCreated: .now,
		dateLastUpdated: .now,
		userData: .init(
			dateAdded: .now,
			isFavorite: true,
			numberOfDueCards: 12
		)
	)
	failedDeck.imageLoadingState.fail(message: "Self-invoked")
	let selectedDeck = Deck._new(
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
		numberOfCards: 19640,
		creatorId: "0",
		dateCreated: .now,
		dateLastUpdated: .now,
		userData: .init(
			dateAdded: .now,
			isFavorite: true,
			numberOfDueCards: 0
		)
	)
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
			._new(
				id: "0",
				topics: [],
				hasImage: true,
				image: .init("GeometryPrepDeck"),
				name: "Geometry Prep #1",
				subtitle: "Angles, lines, triangles and other polygons",
				description: "This is a deck about angles, lines, triangles and other polygons. This is a deck about angles, lines, triangles and other polygons. This is a deck about angles, lines, triangles and other polygons.",
				numberOfViews: 1000000000,
				numberOfUniqueViews: 200000,
				numberOfRatings: 12400,
				numberOf1StarRatings: 100,
				numberOf2StarRatings: 100,
				numberOf3StarRatings: 100,
				numberOf4StarRatings: 200,
				numberOf5StarRatings: 11900,
				averageRating: 4.5,
				numberOfDownloads: 196400,
				numberOfCards: 19640,
				creatorId: "0",
				dateCreated: .now,
				dateLastUpdated: .now,
				userData: .init(
					dateAdded: .now,
					isFavorite: false,
					numberOfDueCards: 23
				),
				previewCards: [
					.init(
						id: "10",
						sectionId: "",
						front: "This is a card with some sound. <audio src=\"audio.wav\"></audio>",
						back: "This is the back.",
						numberOfViews: 0,
						numberOfSkips: 0
					),
					.init(
						id: "10",
						sectionId: "",
						front: "<h1>This is a card with an image.</h1><img src=\"https://www.desktopbackground.org/p/2010/11/29/118717_seashore-desktop-wallpapers-hd-images-jpg_2560x1600_h.jpg\"><ul><li>First element</li><li>Second element</li><li>Third element</li></ul>",
						back: "<b>This is the back.</b>",
						numberOfViews: 0,
						numberOfSkips: 0
					),
					.init(
						id: "10",
						sectionId: "",
						front: "<h1>This is a list</h1><ul><li>First element</li><li>Second element</li><li>Third element</li></ul><p><b>This is the end of the card</b></p>",
						back: "This is the back.",
						numberOfViews: 0,
						numberOfSkips: 0
					)
				]
			),
			selectedDeck,
			._new(
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
				numberOfCards: 19640,
				creatorId: "0",
				dateCreated: .now,
				dateLastUpdated: .now
			),
			._new(
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
				numberOfCards: 19640,
				creatorId: "0",
				dateCreated: .now,
				dateLastUpdated: .now,
				userData: .init(
					dateAdded: .now,
					isFavorite: true,
					numberOfDueCards: 36
				)
			),
			._new(
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
				numberOfCards: 19640,
				creatorId: "0",
				dateCreated: .now,
				dateLastUpdated: .now,
				userData: .init(
					dateAdded: .now,
					isFavorite: false,
					numberOfDueCards: 568
				)
			),
			._new(
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
				numberOfCards: 19640,
				creatorId: "0",
				dateCreated: .now,
				dateLastUpdated: .now,
				userData: .init(
					dateAdded: .now,
					isFavorite: true,
					numberOfDueCards: 1
				)
			),
			failedDeck
		]
	))
	currentStore.selectedDeck = selectedDeck
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
		._new(
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
			numberOfCards: 19640,
			creatorId: "0",
			dateCreated: .now,
			dateLastUpdated: .now,
			userData: .init(
				dateAdded: .now,
				isFavorite: false,
				numberOfDueCards: 23
			)
		),
		._new(
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
			numberOfCards: 19640,
			creatorId: "0",
			dateCreated: .now,
			dateLastUpdated: .now,
			userData: .init(
				dateAdded: .now,
				isFavorite: true,
				numberOfDueCards: 0
			)
		),
		._new(
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
			numberOfCards: 19640,
			creatorId: "0",
			dateCreated: .now,
			dateLastUpdated: .now
		),
		._new(
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
			numberOfCards: 19640,
			creatorId: "0",
			dateCreated: .now,
			dateLastUpdated: .now,
			userData: .init(
				dateAdded: .now,
				isFavorite: true,
				numberOfDueCards: 36
			)
		),
		._new(
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
			numberOfCards: 19640,
			creatorId: "0",
			dateCreated: .now,
			dateLastUpdated: .now,
			userData: .init(
				dateAdded: .now,
				isFavorite: false,
				numberOfDueCards: 568
			)
		),
		._new(
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
			numberOfCards: 19640,
			creatorId: "0",
			dateCreated: .now,
			dateLastUpdated: .now,
			userData: .init(
				dateAdded: .now,
				isFavorite: true,
				numberOfDueCards: 1
			)
		)
	]
	return currentStore
}()

#endif
