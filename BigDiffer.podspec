Pod::Spec.new do |s|
  s.name             = 'BigDiffer'
  s.version          = '0.1.0'
  s.summary          = 'reconciliation optimizer for diff-and-patch libs on UIKit & AppKit'
  s.description      = <<-DESC
  BigDiffer optimize the diffs to patch on UITableView and other Views to avoid performance issue especially for usecase where there is big number of diffs
                       DESC
  s.homepage         = 'https://github.com/banjun/BigDiffer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'banjun' => 'banjun@gmail.com' }
  s.source           = { :git => 'https://github.com/banjun/BigDiffer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/banjun'

  s.ios.deployment_target = '10.0'
  # s.osx.deployment_target = '10.12'

  s.swift_version = '4.1'

  s.subspec 'Core' do |ss|
    ss.source_files = 'BigDiffer/Classes/Core/**/*.swift'
  end

  s.subspec 'BigDiffer' do |ss|
    ss.source_files = 'BigDiffer/Classes/BigDiffer/**/*.swift'
    ss.dependency 'BigDiffer/Core'
    ss.dependency 'ListDiff'
  end

  s.subspec 'Differ' do |ss|
    ss.source_files = 'BigDiffer/Classes/Differ/**/*.swift'
    ss.dependency 'BigDiffer/Core'
    ss.dependency 'Differ'
  end

  s.subspec 'HeckelDiff' do |ss|
    ss.source_files = 'BigDiffer/Classes/HeckelDiff/**/*.swift'
    ss.dependency 'BigDiffer/Core'
    ss.dependency 'HeckelDiff'
  end

  s.subspec 'DeepDiff' do |ss|
    ss.source_files = 'BigDiffer/Classes/DeepDiff/**/*.swift'
    ss.dependency 'BigDiffer/Core'
    ss.dependency 'DeepDiff'
  end
end
