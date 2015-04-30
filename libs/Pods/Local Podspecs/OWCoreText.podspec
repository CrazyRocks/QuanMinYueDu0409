Pod::Spec.new do |s|
  s.name     = 'OWCoreText'
  s.version  = '0.0.2'
  s.license  = 'MIT'
  s.summary  = 'A CoreText framework.'
  s.homepage = 'http://www.xplays.com'
  s.author   = { 'grenlight' => 'grenlight@icloud.com' }
  s.source   = { :path => '~/Desktop/CocoaPods2/OWCoreText'}

    non_arc_files       = 'OWCoreText/html_parser/*.{h,m}'
    s.source_files      = 'OWCoreText/*.{h,m}', 'OWCoreText/**/*.{h,m}'
    s.exclude_files     = non_arc_files
    s.requires_arc      = true

    s.preserve_paths    = '**/*.a'

    s.subspec 'NoARC' do |noarc|
        noarc.source_files = non_arc_files
        noarc.requires_arc = false
    end
  

    s.xcconfig          = { 'HEADER_SEARCH_PATHS' => '$SDKROOT/usr/include/libxml2'}

    s.platform          = :ios , "6.0"
    s.frameworks        = 'CoreGraphics', 'QuartzCore', 'CoreText'
    s.libraries         = 'z', 'xml2.2'
    
s.prefix_header_contents = "#import <Foundation/Foundation.h>", "#import <UIKit/UIKit.h>","#import <AVFoundation/AVFoundation.h>","#import <AVFoundation/AVFoundation.h>","#import <CoreMedia/CoreMedia.h>"

    s.resources         = "OWCoreText/**/*.xib"
    

end