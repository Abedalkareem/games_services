#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'games_services'
  s.version          = '4.1.0'
  s.summary          = 'A Flutter plugin to support Game Center and Google Play Games services.'
  s.description      = <<-DESC
A Flutter plugin to support Game Center and Google Play Games services.
                       DESC
  s.homepage         = 'https://github.com/Abedalkareem/games_services'
  s.license          = { :file => '../LICENSE' }
  s.author           = { '' => 'abedalkareem.omreyh@yahoo.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.swift_version = '5.0'

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.4'
  s.osx.deployment_target = '11.0'
end

