#
# Be sure to run `pod lib lint FitpoloSDK-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FitpoloSDK-iOS'
  s.version          = '0.1.1'
  s.summary          = 'A short description of FitpoloSDK-iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Fitpolo/FitpoloSDK-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chengang' => 'chengang@mokotechnology.com' }
  s.source           = { :git => 'https://github.com/Fitpolo/FitpoloSDK-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'FitpoloSDK-iOS/Classes/mk_fitpoloCentralGlobalHeader.h'
  
  s.subspec 'header' do |ss|
    ss.source_files = 'FitpoloSDK-iOS/Classes/header/**'
  end
  
  s.subspec 'adopter' do |ss|
    ss.source_files = 'FitpoloSDK-iOS/Classes/adopter/**'
    ss.dependency 'FitpoloSDK-iOS/header'
  end
  
  s.subspec 'log' do |ss|
    ss.source_files = 'FitpoloSDK-iOS/Classes/log/**'
    ss.dependency 'FitpoloSDK-iOS/header'
  end
  
  s.subspec 'category' do |ss|
    ss.source_files = 'FitpoloSDK-iOS/Classes/category/**'
  end
  
  s.subspec 'task' do |ss|
    ss.subspec 'fitpolo701' do |sss|
      sss.source_files = 'FitpoloSDK-iOS/Classes/task/fitpolo701/**'
      sss.dependency 'FitpoloSDK-iOS/header'
      sss.dependency 'FitpoloSDK-iOS/adopter'
      sss.dependency 'FitpoloSDK-iOS/log'
    end
    ss.subspec 'fitpoloCurrent' do |sss|
      sss.source_files = 'FitpoloSDK-iOS/Classes/task/fitpoloCurrent/**'
      sss.dependency 'FitpoloSDK-iOS/header'
      sss.dependency 'FitpoloSDK-iOS/adopter'
      sss.dependency 'FitpoloSDK-iOS/log'
    end
    ss.subspec 'operation' do |sss|
      sss.source_files = 'FitpoloSDK-iOS/Classes/task/operation/**'
      sss.dependency 'FitpoloSDK-iOS/header'
      sss.dependency 'FitpoloSDK-iOS/task/fitpolo701'
      sss.dependency 'FitpoloSDK-iOS/task/fitpoloCurrent'
    end
  end
  
  s.subspec 'centralManager' do |ss|
    ss.source_files = 'FitpoloSDK-iOS/Classes/centralManager/**'
    ss.dependency 'FitpoloSDK-iOS/header'
    ss.dependency 'FitpoloSDK-iOS/adopter'
    ss.dependency 'FitpoloSDK-iOS/category'
    ss.dependency 'FitpoloSDK-iOS/log'
    ss.dependency 'FitpoloSDK-iOS/task/operation'
  end
  
  s.subspec 'interface' do |ss|
    ss.subspec 'device' do |sss|
      sss.source_files = 'FitpoloSDK-iOS/Classes/interface/device/**'
    end
    ss.subspec 'userData' do |sss|
      sss.source_files = 'FitpoloSDK-iOS/Classes/interface/userData/**'
    end
    
    ss.dependency 'FitpoloSDK-iOS/header'
    ss.dependency 'FitpoloSDK-iOS/adopter'
    ss.dependency 'FitpoloSDK-iOS/category'
    ss.dependency 'FitpoloSDK-iOS/log'
    ss.dependency 'FitpoloSDK-iOS/task/operation'
    ss.dependency 'FitpoloSDK-iOS/centralManager'
  end
  
end
