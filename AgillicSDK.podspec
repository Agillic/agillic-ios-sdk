Pod::Spec.new do |s|
  s.name             = 'AgillicSDK'
  s.version          = '0.7.0'
  s.summary          = 'Agillic SDK for iOS'
  s.homepage         = 'https://github.com/agillic/agillic-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Agillic' => 'info@agillic.com' }
  s.source           = { :git => 'https://github.com/agillic/agillic-ios-sdk.git', :tag => s.version.to_s }
  s.swift_version    = '5.1'

  s.ios.deployment_target = '11.0'

  s.source_files = 'src/AgillicSDK/*'

  s.frameworks = 'UIFoundation'

  s.dependency 'SnowplowTracker'

end
