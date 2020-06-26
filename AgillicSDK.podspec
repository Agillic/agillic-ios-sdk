#
# Be sure to run `pod lib lint agillic-ios-sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgillicSDK'
  s.version          = '0.1.0'
  s.summary          = 'A short description of agillic-ios-sdk.'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An Mobile SDK for the Agillic Platform. Registration of Application installation and tracking
                       DESC

  s.homepage         = 'https://staging-developers.agillic.com/mobilesdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dennis-agillic' => 'dennis.schafroth@agillic.com' }
  s.source           = { :git => 'git@gitlab.agillic.net:development-tools/agillic-ios-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'
  s.source_files = 'AgillicSDK/*'
  # s.resource_bundles = {
  #   'agillic-ios-sdk' => ['agillic-ios-sdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SnowplowTracker', '~> 1.3'
end
