platform :ios, '12.1'

target 'memorize.ai' do
	use_frameworks!
	pod 'Firebase/Core'
	pod 'Firebase/Firestore'
	pod 'Firebase/Auth'
	pod 'Firebase/Storage'
	pod 'Firebase/Messaging'
	pod 'Firebase/Functions'
	pod 'InstantSearchClient'
	pod 'Down', :git => 'https://github.com/iwasrobbed/Down.git'
	pod 'SwiftyMimeTypes'
	pod 'SwiftySound'
	pod 'DeviceKit'
	pod 'SwiftGifOrigin'
	target 'memorize.aiTests' do
		inherit! :search_paths
	end
	target 'memorize.aiUITests' do
		inherit! :search_paths
	end
end
