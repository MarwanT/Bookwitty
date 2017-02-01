# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Bookwitty' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  plugin 'cocoapods-keys', {
    :project => "Bookwitty",
    :keys => [
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
  pod 'EMCCountryPickerController', '1.3.3'

  target 'BookwittyTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
