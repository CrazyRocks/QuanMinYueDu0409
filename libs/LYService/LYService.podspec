Pod::Spec.new do |s|
  s.name     = 'LYService'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'A LYService framework.'
  s.homepage = 'http://www.xplays.com'
  s.author  = { 'grenlight' => 'grenlight@icloud.com' }
  s.source   = { :path => '~/Desktop/CocoaPods2/LYService'}
    s.source_files = 'LYService/*.{h,m}', 'LYService/**/*.{h,m}'
    s.preserve_paths = '**/*.a'
    s.requires_arc = true

    s.platform = :ios , "6.0"
    s.frameworks = 'CoreGraphics', 'QuartzCore'
    
    s.resources = "LYService/**/*.png", "LYService/**/*.xib", "LYService/**/*.xcdatamodeld"

end