platform :ios, '13.0'

inhibit_all_warnings!

target 'memorize.ai' do
	use_frameworks!
	
	pod 'Firebase/Analytics'
	pod 'Firebase/Auth'
	pod 'Firebase/Firestore'
	pod 'Firebase/Storage'
	
	pod 'GoogleSignIn'
	
	target 'memorize.aiTests' do
		inherit! :search_paths
	end
end
