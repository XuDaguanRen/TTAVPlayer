
Pod::Spec.new do |spec|

  spec.name         = "TTAVPlayer"
  spec.version      = "1.0.0"
  spec.summary      = "一个简单的视频播放工具"
  spec.description  = <<-DESC
                            为了学习AVPlayer，实现了一个简单的视频播放工具。
                        DESC
  spec.homepage     = "https://github.com/XuDaguanRen/TTAVPlayer"
  #spec.license      = "MIT"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "許仙" => "xuxiandaguanren@gmail.com" }
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/XuDaguanRen/TTAVPlayer.git", :tag => spec.version }
  spec.source_files  = "TTAVPlayer", "TTAVPlayerSources/*.swift"
  spec.requires_arc = true

end
