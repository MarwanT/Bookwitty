# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

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
      "BookwittyGoogleAnalyticsIdentifier",
      "BookwittyIFramelyKey"
    ]
  }

  # Pods for Bookwitty
  pod 'Moya', '8.0.5'
  pod 'Fabric', '1.6.11'
  pod 'Crashlytics', '3.8.4'
  pod 'GoogleAnalytics', '3.17.0'
  pod 'FacebookCore', '0.3.0'
  pod 'FacebookLogin', '0.3.0'
  pod 'FacebookShare', '0.3.0'
  pod 'FLKAutoLayout', '1.0.0'
  pod 'SwiftMessages', '3.1.4'
  pod 'EMCCountryPickerController', :git => 'https://github.com/Keeward/EMCCountryPickerController', :tag => '1.4.0'
  pod 'TTTAttributedLabel', '2.0.0'
  pod 'SwiftyJSON', '3.1.4'
  pod 'ALCameraViewController', '1.2.7'
  pod 'Spine', :git => 'https://github.com/Keeward/Spine.git', :tag => '0.3.2'
  pod 'AsyncDisplayKit', '2.2'
  pod 'SwiftLinkPreview', '2.0.0'
  pod 'SDWebImage', '4.0.0'
  pod 'UIImageViewAlignedSwift', '0.3.1'
  pod 'Segmentio', '2.1.2'
  pod 'DTCoreText', '1.6.21'
  pod 'SwiftLoader', :git => 'https://github.com/keeward/SwiftLoader', :tag => '0.3.1'
  pod 'Version', :git => 'https://github.com/opwoco/Version'
  pod 'ReachabilitySwift', '3'
  pod 'GSImageViewerController', '1.2.1'
  pod 'RichEditorView', :git => 'git@github.com:Keeward/RichEditorView.git', :branch => 'web-kit'
  pod 'WSTagsField', :git => 'https://github.com/Keeward/WSTagsField.git', :branch => 'more-tag'
  pod 'MobileEditor', :git => 'git@gitlab.help-counter.com:ios-libraries/ContentEditor.git', :branch => 'tinymce', :submodules => true
  pod 'AKImageCropperView', '2.0.0'
  pod 'GoogleSignIn', '4.1.2'

  target 'BookwittyTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'GoogleAnalytics', '3.17.0'
  end

end
