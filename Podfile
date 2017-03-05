# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Bookwitty' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  plugin 'cocoapods-keys', {
    :project => "Bookwitty",
    :keys => [
      "BookwittyAPIClientKey",
      "BookwittyAPIClientSecret",
      "BookwittyEnvironment",
      "BookwittyServerBaseURL",
      "BookwittyGoogleAnalyticsIdentifier"
    ]
  }

  # Pods for Bookwitty
  pod 'Moya', '8.0.0'
  pod 'Fabric', '1.6.11'
  pod 'Crashlytics', '3.8.3'
  pod 'Google/Analytics', '3.0.3'
  pod 'FacebookCore', '0.2.0'
  pod 'FacebookLogin', '0.2.0'
  pod 'FacebookShare', '0.2.0'
  pod 'FLKAutoLayout', '1.0.0'
  pod 'SwiftMessages', '3.1.4'
  pod 'EMCCountryPickerController', :git => 'https://github.com/Keeward/EMCCountryPickerController', :tag => '1.4.0'
  pod 'TTTAttributedLabel', '2.0.0'
  pod 'SwiftyJSON', '3.1.4'
  pod 'ALCameraViewController', '1.2.7'
  pod 'Spine', :git => 'https://github.com/Keeward/Spine.git'
  pod 'AsyncDisplayKit', '2.2'
  pod 'SwiftLinkPreview', '2.0.0'
  pod 'SDWebImage', '4.0.0'
  pod 'UIImageViewAlignedSwift', '0.3.1'

  target 'BookwittyTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Google/Analytics', '3.0.3'
  end

end
