#
#  Be sure to run `pod spec lint NSURL+QueryParser.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name          = "NSURL+QueryParser"
  spec.version       = "1.0.1"
  spec.summary       = "Extensions working with URL, UrlString query"
  spec.description   = "NSURL, NSString and NSDictionary categories to deal with query part"
  spec.homepage      = "https://github.com/lane128/NSURL-QueryParser"
  spec.license       = { :type => 'MIT', :file => 'LICENSE' }
  spec.author        = { "Adam Wang" => "lane128@gmail.com" }
  spec.source        = { :git => "https://github.com/lane128/NSURL-QueryParser.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = '7.0'
  spec.osx.deployment_target = '10.9'
  spec.watchos.deployment_target = '2.0'
  spec.tvos.deployment_target = '9.0'
  spec.source_files  = spec.name + '/*.{h,m}'
  spec.frameworks    = 'Foundation'
end
