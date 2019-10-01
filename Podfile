platform :ios, '13.0'

inhibit_all_warnings!

target 'memorize.ai' do
	use_frameworks!
	
	pod 'Firebase/Analytics'
	pod 'Firebase/Auth'
	pod 'Firebase/Firestore'
	pod 'Firebase/Storage'
	
	target 'memorize.aiTests' do
		inherit! :search_paths
	end
	
	target 'memorize.aiUITests' do
	end
end
