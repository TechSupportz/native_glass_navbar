#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_glass_navbar.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_glass_navbar'
  s.version          = '1.0.2'
  s.summary          = 'A Flutter plugin that brings the native iOS Liquid Glass style navigation bar to your Flutter apps.'
  s.description      = <<-DESC
A Flutter plugin that brings the native iOS Liquid Glass style navigation bar to your Flutter apps.
                       DESC
  s.homepage         = 'https://github.com/TechSupportz/native_glass_navbar'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'TechSupportz' => 'https://github.com/TechSupportz' }
  s.source           = { :path => '.' }
  s.source_files = 'native_glass_navbar/Sources/native_glass_navbar/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Privacy manifest, shared with the Swift Package Manager target.
  # See https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'native_glass_navbar_privacy' => ['native_glass_navbar/Sources/native_glass_navbar/PrivacyInfo.xcprivacy']}
end
