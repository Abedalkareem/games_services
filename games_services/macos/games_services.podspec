#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'games_services'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin to support game center services.'
  s.description      = <<-DESC
  A new Flutter plugin to support game center services.
                       DESC
  s.homepage         = 'https://pub.dev/packages/games_services'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Abedalkareem' => 'https://github.com/Abedalkareem' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '11.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
