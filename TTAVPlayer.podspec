
Pod::Spec.new do |spec|

    spec.name         = "TTAVPlayer"
    spec.version      = "1.0.2"
    spec.summary      = "一个简单的视频播放工具"
    spec.description  = <<-DESC
                        为了学习AVPlayer，实现了一个简单的视频播放工具。
    DESC
    spec.platform     = :ios, "10.0"
    spec.swift_version = "5.0"
    spec.homepage     = "https://github.com/XuDaguanRen/TTAVPlayer"
    spec.license      = "MIT"
    spec.author       = { "許仙" => "xuxiandaguanren@gmail.com" }
    spec.source       = { :git => "https://github.com/XuDaguanRen/TTAVPlayer.git", :tag => spec.version }
    spec.authors      = { "許仙" => "xuxiandaguanren@gmail.com" }
    spec.source_files  = "TTAVPlayerSources/*.swift", "TTAVPlayerSources/Tools/*.swift"
    spec.requires_arc = true


  # spec.social_media_url   = "https://twitter.com/許仙"
  # spec.platform     = :ios
  # spec.platform     = :ios, "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"
  # spec.exclude_files = "Classes/Exclude"
  # spec.public_header_files = "Classes/**/*.h"
  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"
  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"
  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"
  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"
  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
