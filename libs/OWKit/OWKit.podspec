Pod::Spec.new do |s|
  s.name     = 'OWKit'
  s.version  = '0.0.6'
  s.license  = 'MIT'
  s.summary  = 'A OOOOWW UIKit framework.'
  s.homepage = 'http://www.xplays.com'
  s.author  = { 'grenlight' => 'grenlight@icloud.com' }
  s.source   = { :path => 'OWkit'}
    s.source_files = 'OWKit/*.{h,m}', 'OWKit/**/*.{h,m}'
    s.preserve_paths = '**/*.a'
    s.requires_arc = true

    s.platform = :ios , "6.0"
    s.frameworks = 'CoreGraphics', 'QuartzCore'
    s.resources = "OWKit/**/*.png", "OWKit/**/*.xib"

    s.prefix_header_contents = <<-EOS
    #ifdef __OBJC__
        #import <UIKit/UIKit.h>
        #import <Foundation/Foundation.h>
        #import "OWKitGlobal.h"
        #import <Masonry/Masonry.h>

    #endif /* __OBJC__*/
    EOS

end