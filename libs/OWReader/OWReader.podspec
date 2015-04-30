Pod::Spec.new do |s|
s.name     = 'OWReader'
s.version  = '0.0.3'
s.license  = 'MIT'
s.summary  = 'A OWReader framework.'
s.homepage = 'http://www.xplays.com'
s.author   = { 'grenlight' => 'grenlight@icloud.com' }
s.source   = { :path => 'OWReader'}

non_arc_files       = 'OWReader/zip/ZipArchive.{h,m}', 'OWReader/zip/zip.{c,h}', 'OWReader/zip/unzip.{c,h}', 'OWReader/zip/mztools.{c,h}'
s.source_files      = 'OWReader/*.{c,h,m}', 'OWReader/**/*.{c,h,m}'
s.exclude_files     = non_arc_files
s.requires_arc      = true

s.subspec 'NoARC' do |noarc|
noarc.source_files = non_arc_files
noarc.requires_arc = false
end

s.preserve_paths    = '**/*.a'

s.platform = :ios , "6.0"
s.frameworks = 'CoreGraphics', 'QuartzCore', 'CoreData', 'CoreText'
s.libraries  = 'z', 'xml2.2'
s.xcconfig   = { 'HEADER_SEARCH_PATHS' => '$SDKROOT/usr/include/libxml2'}

s.resources = "OWReader/**/*.xib", "OWReader/**/*.xcdatamodeld"

s.prefix_header_contents = <<-EOS
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>

#endif /* __OBJC__*/
EOS


end