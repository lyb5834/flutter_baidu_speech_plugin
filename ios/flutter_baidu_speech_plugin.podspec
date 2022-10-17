#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_baidu_speech_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_baidu_speech_plugin'
  s.version          = '0.0.1'
  s.summary          = '百度语音识别、唤醒 flutter 插件'
  s.description      = <<-DESC
百度语音识别、唤醒 flutter 插件
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'
  # s.vendored_libraries = 'Libs/BDSClientLib/libBaiduSpeechSDK.a'
  s.resources = ['Assets/*']

  s.frameworks = 'AudioToolbox',
  'AVFoundation',
  'CFNetwork',
  'CoreLocation',
  'CoreTelephony',
  'SystemConfiguration',
  'GLKit'

  s.libraries = 'bz2','c++','iconv','resolv','z','sqlite3.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
