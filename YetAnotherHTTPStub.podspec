#
#  Be sure to run `pod spec lint YetAnotherHTTPStub.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "YetAnotherHTTPStub"
  s.version      = "1.6.2"
  s.summary      = "YetAnotherHTTPStub to mock the network response for unit test"

  s.description  = <<-DESC
  In many case, we need to mock the network response when we writing unit test that has network request, like calling an API.
  This framework utilizes the URLProcotol to intercept the request and reply the response preset by developer.
                   DESC

  s.homepage     = "https://github.com/kinwahlai/YetAnotherHTTPStub"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Darren Lai" => "kinwah.lai@gmail.com" }

  s.platform     = :ios

  s.source       = { :git => "https://github.com/kinwahlai/YetAnotherHTTPStub.git", :tag => "#{s.version}" }

  s.source_files  = "YetAnotherHTTPStub/**/*.{swift}"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  s.swift_version = "5.0"

end
