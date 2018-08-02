Pod::Spec.new do |s|
  s.name             = 'BigDiffer'
  s.version          = '0.4.0'
  s.summary          = 'diff & patch for multi-section UITableView with large number of rows (changes between 0~5000)'
  s.description      = <<-DESC
  * Multi section diff & patch for UITableView
  * Fast linear complexity diff algorithm a.k.a. Heckel, by making use of ListDiff
  * Optimize diff with some heuristics for large number of rows
  * Skip diffing for currently invisible sections (use reload)
    * Section-wise diff for currently (partially or completely) visible sections
    * Skip applying diff when many deletions detected (> 300), for each section
                       DESC
  s.homepage         = 'https://github.com/banjun/BigDiffer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'banjun' => 'banjun@gmail.com' }
  s.source           = { :git => 'https://github.com/banjun/BigDiffer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/banjun'

  s.ios.deployment_target = '10.0'
  # s.osx.deployment_target = '10.12'

  s.swift_version = '4.1'
  s.default_subspec = 'BigDiffer'

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

  s.subspec 'EditDistance' do |ss|
    ss.source_files = 'BigDiffer/Classes/EditDistance/**/*.swift'
    ss.dependency 'BigDiffer/Core'
    ss.dependency 'EditDistance'
  end
end
