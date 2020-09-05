#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'games_services'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin to support game center and google play games services.'
  s.description      = <<-DESC
A new Flutter plugin to support game center and google play games services.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.swift_version = '5.0'

  s.ios.deployment_target = '11.0'
end

