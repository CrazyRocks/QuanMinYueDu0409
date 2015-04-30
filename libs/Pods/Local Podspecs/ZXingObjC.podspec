Pod::Spec.new do |s|
  s.name     = 'ZXingObjC'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'A ZXingObjC framework.'
  s.homepage = 'http://www.xplays.com'
  s.author  = { 'grenlight' => 'grenlight@icloud.com' }
  s.source   = { :path => '~/Desktop/CocoaPods2/ZXingObjC'}
    s.source_files = 'ZXingObjC/*.{h,m}', 'ZXingObjC/**/*.{h,m}'
    s.preserve_paths = '**/*.a'
    s.requires_arc = true

    s.platform = :ios , "6.0"
    s.frameworks = 'CoreGraphics', 'QuartzCore'

end