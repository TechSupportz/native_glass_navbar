#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_glass_navbar.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_glass_navbar'
  s.version          = '1.0.2.1'
  s.summary          = 'A native iOS Liquid Glass navigation bar for Flutter.'
  s.description      = <<-DESC
Renders a native UITabBar with the iOS Liquid Glass appearance inside Flutter.
                       DESC
  s.homepage         = 'https://github.com/TechSupportz/native_glass_navbar'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'TechSupportz'
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {'native_glass_navbar_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
