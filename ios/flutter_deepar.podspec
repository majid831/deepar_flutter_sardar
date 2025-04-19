#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_deepar.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_deepar'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.ios.vendored_frameworks = 'Frameworks/DeepAR.xcframework'
  s.user_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7s arm64e' }
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7s arm64e' }
#  s.public_header_files = 'Frameworks/DeepAR.framework/Headers/*.h'
end
