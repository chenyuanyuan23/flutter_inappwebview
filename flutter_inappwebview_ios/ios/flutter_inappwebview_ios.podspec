#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutterplugintest.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_inappwebview_ios'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { '' => '' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_inappwebview_ios/Sources/flutter_inappwebview_ios_internal/**/*.{h,m}', 'flutter_inappwebview_ios/Sources/flutter_inappwebview_ios/**/*.swift'
  s.resources = 'flutter_inappwebview_ios/Sources/flutter_inappwebview_ios/Resources/**/*.storyboard'
  s.public_header_files = 'flutter_inappwebview_ios/Sources/flutter_inappwebview_ios_internal/include/*.h'
  s.dependency 'Flutter'
  s.resource_bundles = {'flutter_inappwebview_ios_privacy' => ['flutter_inappwebview_ios/Sources/flutter_inappwebview_ios/Resources/PrivacyInfo.xcprivacy']}

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.libraries = 'swiftCoreGraphics'

  s.xcconfig = {
      'LIBRARY_SEARCH_PATHS' => '$(SDKROOT)/usr/lib/swift',
  }

  s.swift_version = '5.0'

  s.platforms = { :ios => '12.0' }
  s.dependency 'OrderedSet', '~>6.0.3'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.platform = :ios, '12.0'
  end
end
