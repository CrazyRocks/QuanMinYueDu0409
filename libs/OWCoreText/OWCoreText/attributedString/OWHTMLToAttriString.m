//
//  OWHTMLToAttriString.m
//  OWCoreText
//
//  Created by 龙源 on 13-7-19.
//
//

#import "OWHTMLToAttriString.h"
#import "CSSParser.h"
#import "HTMLNode.h"
#import "HTMLParser.h"
#import "OWTextAttachment.h"
#import "NSAttributedStringRunDelegates.h"
#import <CoreText/CoreText.h>
#import "OWCoreTextLayouter.h"
#import "OWInfiniteCoreTextLayouter.h"

#define UNICODE_OBJECT_PLACEHOLDER @"\ufffc"

typedef void(^TagHandleBlock)(HTMLNode *) ;

static CGFloat ascentCallback( void *ref )
{
//    NSLog(@"afdas:%@",ref);
    if (ref && [(__bridge id)ref isKindOfClass:[NSDictionary class]]) {
        return [((__bridge NSDictionary *)ref)[@"height"] floatValue];
    }
    return 0;
}

static CGFloat descentCallback( void *ref )
{
    if (ref && [(__bridge id)ref isKindOfClass:[NSDictionary class]]) {
        return [((__bridge NSDictionary *)ref)[@"descent"] floatValue];
    }
    return 0;
}

static CGFloat widthCallback( void* ref )
{
    if (ref && [(__bridge id)ref isKindOfClass:[NSDictionary class]]) {
        return [((__bridge NSDictionary *)ref)[@"width"] floatValue];
    }
    return 0;
}


@implementation OWHTMLToAttriString
{
    NSString    *currentCSSName, *appendCSSName;
}
@synthesize attributedString;
@synthesize imageSize;
@synthesize imageBasicPath;

+ (OWHTMLToAttriString *)sharedInstance
{
    static OWHTMLToAttriString *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OWHTMLToAttriString alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

-(void)setUp
{
    fontScale = 1;
    layouter = [[OWInfiniteCoreTextLayouter alloc] init];
    [self regMarkupBlock];
    
}

-(void)dealloc
{
    [tagHandlers removeAllObjects];
    tagHandlers = nil;
    attributedString = nil;
}

- (void)setCSS:(NSString *)fileName
{
    [self generateCssDictionary:fileName];
}

- (void)generateCssDictionary:(NSString *)fileName
{
    if (currentCSSName && [currentCSSName isEqualToString:fileName])
        return;
    
    currentCSSName = fileName;
    
    [self updateCSS];
}

- (void)setCSS:(NSString *)fileName fontSizeScale:(float)scale
{
    fontScale = scale;
    [self generateCssDictionary:fileName];
}

- (void)scaleFontSize:(float)scale
{
    fontScale = scale;
    if (cssDictionary) {
        [self updateCSS];
    }
}

- (void)setFontName:(NSString *)fontName
{
    _fontName = fontName;
    if (cssDictionary) {
        [self updateCSS];
    }
}

- (void)updateCSS
{
    CSSParser *parser = [[CSSParser alloc] init];
    parser.fontSizeScale = fontScale;
    parser.fontName = _fontName;
    parser.bundle = self.bundle;
    
//    NSLog(@"update CSS: %f, %@", fontScale, _fontName);
    
    [cssDictionary removeAllObjects];
    cssDictionary = [NSMutableDictionary dictionaryWithDictionary:[parser parseCSS:currentCSSName]];
}

- (void)appendCSS:(NSString *)fileName
{
    if ([appendCSSName isEqualToString:fileName]) {
        return;
    }
    appendCSSName = fileName;
    if (!cssDictionary) {
        cssDictionary = [[NSMutableDictionary alloc] init];
    }
    NSDictionary *dict = [[[CSSParser alloc] init] parseCSS:appendCSSName];
    for (NSString *key in dict) {
        [cssDictionary setObject:dict[key] forKey:key];
    }
}

- (float)convertHTML:(NSString *)html width:(float)width toLine:(NSArray *__autoreleasing *)lines
{
    return [self convertHTML:html width:width maxLine:0 toLine:lines];
}

- (float)convertHTML:(NSString *)html width:(float)width maxLine:(int)maxLine
              toLine:(NSArray *__autoreleasing *)lines
{
    
    return [self convertHTML:html startPoint:CGPointZero width:width maxLine:maxLine toLine:lines];
}

- (float)convertHTML:(NSString *)html
          startPoint:(CGPoint)point
               width:(float)width
             maxLine:(int)maxLine
              toLine:(NSArray **)lines
{
    [self generateAttriStringWithHTML:html];
    
    float height;
    *lines = [layouter generateLines:attributedString
                            maxLines:maxLine
                       startPosition:point
                               width:width
                           getHeight:&height];
    return height;

}

- (void)generateAttriStringWithHTML:(NSString *)html
{
    attributedString = nil;
    attributedString = [[NSMutableAttributedString alloc] init];
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error ];
    if(error){
        return;
    }
    HTMLNode *body = [parser body];
    NSArray *nodes = [body children];
    for (HTMLNode *node in nodes) {
        if([node.tagName isEqualToString:@"text"]) {
            [self appendString:[self pureString:[node allContents]] withAttributes:
             [self generateNodeAttributes:node parentAttributes:nil]];
        }
        else {
            [self parseNode:node parentAttributes:nil];
        }
    };
    [self appendString:@"\n" ];
    
//    NSLog(@"html:%@",attributedString);

}

- (NSDictionary *)generateNodeAttributes:(HTMLNode *)node
                        parentAttributes:(NSDictionary *)parentAttri
{
    NSDictionary *attributes;
    if ([node className]) {
        attributes = cssDictionary[node.className];
    }
    else {
        attributes = cssDictionary[node.tagName];
    }
    
    if (!attributes) {
        attributes = cssDictionary[@"p"];
    }
   
    return attributes;
}

-(void)parseNode:(HTMLNode *)node parentAttributes:(NSDictionary *)attributes
{
    parentAttributes = attributes;
    NSString * tagName = node.tagName;
//    NSLog(@"tagName:%@",tagName);
    TagHandleBlock tagHandle = [tagHandlers objectForKey:tagName];
    if(tagHandle){
        tagHandle(node);
    }
}

-(NSString *)pureString:(NSString *)str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)nodeLoop:(HTMLNode *)node attributes:(NSDictionary *)attributes
{
    NSArray *children = [node children];
    for (HTMLNode *child in children) {
        if([child.tagName isEqualToString:@"text"])
            [self appendString:[self pureString:[child allContents]] withAttributes:attributes];
        else 
            [self parseNode:child parentAttributes:attributes];
    }
}

//生成占位符
-(void)placeHolderWidth:(float)width
                 height:(float)height
         attachmentType:(OWTextAttachment *)attachmentType
{
    OWTextAttachment *attachment = attachmentType ;
    
    if (!attachmentType) {
        attachment = [[OWTextAttachment alloc]init];
        attachment.contentType = OWTextAttachmentTypeGeneric;
    }
    attachment.displaySize = CGSizeMake(width, height);

    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    
    //NSDictionary 这两个实例化方法会导致图片渲染结果不一样
//    NSDictionary *attr = @{@"width":@(width), @"height":@(height)};

    NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          @(width), @"width",
                          @(height), @"height", nil] ;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(attr));
    NSMutableDictionary *attrDictionary = [@{@"NSAttachmentAttributeName":attachment,
      (id)kCTRunDelegateAttributeName:(__bridge id)delegate} mutableCopy];

    if (parentAttributes) {
        [attrDictionary addEntriesFromDictionary:parentAttributes];
    }
    NSMutableAttributedString *tmpString = [[NSMutableAttributedString alloc] initWithString:@"\ufffc" attributes:attrDictionary];
    [attributedString appendAttributedString:tmpString];
    
//   CFRelease(delegate);
}

- (NSDictionary *)getParentAttrigutes
{
    return parentAttributes;
}

- (CGSize)getImageSize
{
    return imageSize;
}

-(void)regMarkupBlock
{
    tagHandlers = [[NSMutableDictionary alloc]init ];
    __weak OWHTMLToAttriString *weakSelf = self;
    
    void(^pBlock)(HTMLNode *) = ^(HTMLNode *node){
        [weakSelf nodeLoop:node attributes:[weakSelf generateNodeAttributes:node parentAttributes:[weakSelf getParentAttrigutes]]];
        [weakSelf appendString:@"\n" ];

    };
    [tagHandlers setObject:[pBlock copy] forKey:@"p"];
    
    void(^textBlock)(HTMLNode *) = ^(HTMLNode *node){
        [weakSelf appendString:[weakSelf pureString:[node allContents]]
            withAttributes:[weakSelf generateNodeAttributes:node parentAttributes:[weakSelf getParentAttrigutes]]];
    };
    [tagHandlers setObject:[textBlock copy] forKey:@"text"];
    
    void(^hBlock)(HTMLNode *) = ^(HTMLNode *node){
        if ([node children].count == 1 ){
            NSString *cnt = [node allContents];
            [weakSelf appendString:cnt withAttributes:
             [weakSelf generateNodeAttributes:node parentAttributes:[weakSelf getParentAttrigutes]]];
        }
        else {
            [weakSelf nodeLoop:node attributes:[weakSelf generateNodeAttributes:node parentAttributes:[weakSelf getParentAttrigutes]]];
        }
       
        [weakSelf appendString:@"\n" ];
    };
    [tagHandlers setObject:[hBlock copy] forKey:@"h1"];
    [tagHandlers setObject:[hBlock copy] forKey:@"h2"];
    [tagHandlers setObject:[hBlock copy] forKey:@"h3"];
    [tagHandlers setObject:[hBlock copy] forKey:@"h4"];
    [tagHandlers setObject:[hBlock copy] forKey:@"h5"];
    [tagHandlers setObject:[hBlock copy] forKey:@"blockquote"];
    [tagHandlers setObject:[hBlock copy] forKey:@"hgroup"];

    void(^brBlock)(HTMLNode *)=^(HTMLNode *node){
        [weakSelf appendString:@"\n" ];//行分割符
        
    };
    [tagHandlers setObject:[brBlock copy] forKey:@"br"];
    

    void(^spanBlock)(HTMLNode *) = ^(HTMLNode *node){
        NSString *cnt = [node allContents];
        if([node.className isEqualToString:@"fnote"]){

            OWTextAttachment *annotationAttachment = [[OWTextAttachment alloc] init];
            annotationAttachment.contentType = OWTextAttachmentTypeAnnotation;
            annotationAttachment.contents = cnt;
            [weakSelf placeHolderWidth:20 height:16 attachmentType:annotationAttachment];
        }
        else {
            [weakSelf appendString:cnt withAttributes:
             [weakSelf generateNodeAttributes:node parentAttributes:[weakSelf getParentAttrigutes]]];
        }
        
    };
    [tagHandlers setObject:[spanBlock copy] forKey:@"span"];
    
    //注释
    void(^abbrBlock)(HTMLNode *)=^(HTMLNode *node)
    {
        //继承样式
        NSDictionary *annotationAttributes;
        annotationAttributes = [weakSelf generateNodeAttributes:node
                                               parentAttributes:[weakSelf getParentAttrigutes]];
        
        [weakSelf nodeLoop:node attributes:annotationAttributes];
        
        OWTextAttachment *annotationAttachment = [[OWTextAttachment alloc]init];
        annotationAttachment.contentType = OWTextAttachmentTypeAnnotation;
        annotationAttachment.contents = [node getAttributeNamed:@"title"];
        [weakSelf placeHolderWidth:20 height:16 attachmentType:annotationAttachment];
    };
    [tagHandlers setObject:[abbrBlock copy] forKey:@"abbr"];
    
    
    void(^audioBlock)(HTMLNode *)=^(HTMLNode *node)
    {
        NSString *path = [node getAttributeNamed:@"src"];
        
        OWTextAttachment *videoAttachment = [[OWTextAttachment alloc]init];
        videoAttachment.contentType = OWTextAttachmentTypeAudioURL;
        [weakSelf appendString:@"\n"];
        
        if (isPad) {
            [weakSelf placeHolderWidth:(appWidth - 60)/2 height:(appWidth - 60)*3/4/2 attachmentType:videoAttachment];
        }else{
            [weakSelf placeHolderWidth:(appWidth - 60) height:(appWidth - 60)*3/4 attachmentType:videoAttachment];
        }
        
        
        
        [weakSelf appendString:@"\n"];
        //        NSLog(@"video path === %@",path);
        
        if (weakSelf.imageBasicPath) {
            path = [path stringByReplacingOccurrencesOfString:@"../" withString:@"/"];
            path = [weakSelf.imageBasicPath stringByAppendingPathComponent:path];
        }
        
        //        NSLog(@"video path === %@",path);
        
        NSString *newPath = [NSString stringWithFormat:@"file://%@",path];
        
//        NSLog(@"video path === %@",newPath);
        
        videoAttachment.contents = newPath;
    };
    
    [tagHandlers setObject:[audioBlock copy] forKey:@"audio"];
    
    
    //视频节点
    void(^videoBlock)(HTMLNode *)=^(HTMLNode *node)
    {
        NSString *path = [node getAttributeNamed:@"src"];
        
        OWTextAttachment *videoAttachment = [[OWTextAttachment alloc]init];
        videoAttachment.contentType = OWTextAttachmentTypeVideoURL;
        [weakSelf appendString:@"\n"];
        
        if (isPad) {
            [weakSelf placeHolderWidth:(appWidth - 60)/2 height:(appWidth - 60)*3/4/2 attachmentType:videoAttachment];
        }else{
            [weakSelf placeHolderWidth:(appWidth - 60) height:(appWidth - 60)*3/4 attachmentType:videoAttachment];
        }
        
        [weakSelf appendString:@"\n"];
//        NSLog(@"video path === %@",path);
        
        if (weakSelf.imageBasicPath) {
            path = [path stringByReplacingOccurrencesOfString:@"../" withString:@"/"];
            path = [weakSelf.imageBasicPath stringByAppendingPathComponent:path];
        }
        
//        NSLog(@"video path === %@",path);
        
        NSString *newPath = [NSString stringWithFormat:@"file://%@",path];
        
//        NSLog(@"video path === %@",newPath);
        
        videoAttachment.contents = newPath;
    };

    [tagHandlers setObject:[videoBlock copy] forKey:@"video"];
    
    void(^imgBlock)(HTMLNode *)=^(HTMLNode *node) {
        NSString *path = [node getAttributeNamed:@"src"];

        OWTextAttachment *imgAttachment = [[OWTextAttachment alloc]init];
        imgAttachment.contentType = OWTextAttachmentTypeImage;
        
        float imageW, imageH;

        imageW = [[node getAttributeNamed:@"width"] floatValue];
        imageH = [[node getAttributeNamed:@"height"] floatValue];
        if (imageW < 1.0f || imageH < 1.0f) {
            UIImage *image;
            
            if ([path hasPrefix:@"http"] || [path hasPrefix:@"www"]) {
//                image = [imageManager getImageByURL:path];
            }
            else {
                
//                NSLog(@"weakSelf.imageBasicPath path === %@",weakSelf.imageBasicPath);
                
                if (weakSelf.imageBasicPath) {
                    path = [path stringByReplacingOccurrencesOfString:@"../" withString:@"/"];
                    path = [weakSelf.imageBasicPath stringByAppendingPathComponent:path];
                    
                    
//                    if ([path hasPrefix:@"http"] || [path hasPrefix:@"www"])
//                        image = [imageManager getImageByURL:path];
                }
                
                if (!image)
                    image = [OWHTMLToAttriString decryptImage:path];// [UIImage imageWithContentsOfFile:path];
                
                if (!image) {
                    NSString *imageName = [path  componentsSeparatedByString:@"/"].lastObject;
                    path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
                    image = [OWHTMLToAttriString decryptImage:path]; //[UIImage imageWithContentsOfFile:path];
                }
               
            }
            imgAttachment.contents = path;

            if (image) {
                float scaleW = [weakSelf getImageSize].width/image.size.width;
                float scaleH = [weakSelf getImageSize].height/image.size.height;
                //                if(scaleW * image.size.height < weakSelf->imageSize.height){

                if(scaleW < scaleH){
                    imageW = [weakSelf getImageSize].width;
                    imageH = image.size.height * scaleW;
                }
                else {
                    imageW = image.size.width * scaleH;
                    imageH = imageSize.height;
                }
            }
            else {
                imageW = 0;
                imageH = 0;
            }
        }
        //拼接到占位
        [weakSelf placeHolderWidth:imageW height:imageH attachmentType:imgAttachment];

//        if (imageW > 0 && imageH > 0) {
//
//            if ([node className]) {
//                [weakSelf appendString:@" " withAttributes:cssDictionary[@"cover"]];
//                [weakSelf appendString:@"\n"];
//                //            NSLog(@"fdaa:%@",cssDictionary[@"cover"]);
//            }
//            else {
//            }
//        }
    };
    [tagHandlers setObject:[imgBlock copy] forKey:@"img"];
    
    void(^figureBlock)(HTMLNode *)=^(HTMLNode *node){
        [weakSelf parseNode:[node findChildWithTag:@"img" ]
           parentAttributes:nil];
        
        HTMLNode *figcaption = [node findChildWithTag:@"figcaption"];
        if (figcaption)
            [weakSelf parseNode:figcaption parentAttributes:nil];
        
    };
    [tagHandlers setObject:[figureBlock copy] forKey:@"figure"];
    
    void(^figcaptionBlock)(HTMLNode *)=^(HTMLNode *node){
        NSString *cnt = [node allContents];
        [weakSelf appendString:@"\n"];

        [weakSelf appendString:cnt withAttributes:
         [weakSelf generateNodeAttributes:node parentAttributes:nil]];
        [weakSelf appendString:@"\n"];

    };
    [tagHandlers setObject:[figcaptionBlock copy] forKey:@"figcaption"];
    
    
    void(^divBlock)(HTMLNode *)=^(HTMLNode *node){
        [weakSelf nodeLoop:node attributes:[weakSelf generateNodeAttributes:node parentAttributes:[weakSelf getParentAttrigutes]]];
    };
    [tagHandlers setObject:[divBlock copy] forKey:@"div"];
    
    
    void(^ulBlock)(HTMLNode *)=^(HTMLNode *node){
        //继承样式
        [weakSelf appendString:@"\n"];
        
        NSArray *children = [node findChildrenWithTag:@"li"];
        for(HTMLNode *child in children){
            [weakSelf nodeLoop:child attributes:
             [weakSelf generateNodeAttributes:node parentAttributes:[weakSelf getParentAttrigutes]]];
            [weakSelf appendString:@"\n"];
        }
        
    };
    [tagHandlers setObject:[ulBlock copy] forKey:@"ul"];
    
    void(^strongBlock)(HTMLNode *)=^(HTMLNode *node){
        [weakSelf appendString:[node allContents] withAttributes:[weakSelf generateNodeAttributes:node parentAttributes:[weakSelf getParentAttrigutes]]];
        
    };
    [tagHandlers setObject:[strongBlock copy] forKey:@"strong"];
    [tagHandlers setObject:[strongBlock copy] forKey:@"b"];
    
    void(^footerBlock)(HTMLNode *)=^(HTMLNode *node){
        NSMutableString *content = [[NSMutableString alloc]init ];
        [content appendString:@"\n"];
        [content appendString:[node allContents]];
        
        [weakSelf appendString:content withAttributes:
         [weakSelf generateNodeAttributes:node parentAttributes:[weakSelf getParentAttrigutes]]];
        
    };
    [tagHandlers setObject:[footerBlock copy] forKey:@"footer"];
    
}


//拼接NSAttributedString
- (void)appendString:(NSString *)string
{
    if([string isEqualToString:@"\n"] && [self isEndWithLineBreak]){
        return;
    }
	NSAttributedString *tmpString = [[NSAttributedString alloc] initWithString:string ];
	[attributedString appendAttributedString:tmpString];
}

- (void)appendString:(NSString *)string
  withParagraphStyle:(CTParagraphStyleRef)pStyle
      fontDescriptor:(CTFontRef)fontDescriptor fontColor:(UIColor *)fontColor;
{
    if(!string) return;
    
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(string == nil ||string.length==0) return;
    
    NSAttributedString *aString;
    if(pStyle){
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        
        [attributes setObject:(__bridge id)pStyle forKey:(id)kCTParagraphStyleAttributeName];
        
        [attributes setObject:(__bridge id)fontDescriptor forKey:(id)kCTFontAttributeName];
        if(fontColor)
            [attributes setObject:(__bridge id)fontColor.CGColor forKey:(id)kCTForegroundColorAttributeName];
        
        aString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    }else {
        aString = [[NSAttributedString alloc] initWithString:string];
    }
	
	[attributedString appendAttributedString:aString];
}

- (void)appendString:(NSString *)string withAttributes:(NSDictionary *)attributes
{
    if(!string) return;
    
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(string == nil ||string.length==0) return;
    NSAttributedString *attriStr;
    if (globalAttributes != nil) {
        NSMutableDictionary *multAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
        if ([globalAttributes objectForKey:(id)kCTForegroundColorAttributeName]) {
            [multAttributes setObject:[globalAttributes objectForKey:(id)kCTForegroundColorAttributeName] forKey:(id)kCTForegroundColorAttributeName];
            [multAttributes setObject:[globalAttributes objectForKey:(id)kCTFontAttributeName] forKey:(id)kCTFontAttributeName];
        }
        if([globalAttributes objectForKey:(id)kCTParagraphStyleAttributeName]) {
            [multAttributes setObject:[globalAttributes objectForKey:(id)kCTParagraphStyleAttributeName] forKey:(id)kCTParagraphStyleAttributeName];
        }
        attriStr = [[NSAttributedString alloc]initWithString:string attributes:multAttributes];
    }
    else {
        attriStr = [[NSAttributedString alloc]initWithString:string attributes:attributes];
    }
    
    [attributedString appendAttributedString:attriStr];
}

-(BOOL)isEndWithLineBreak
{
    return  [[attributedString string] hasSuffix:@"\n"];
}

+ (UIImage *)decryptImage:(NSString *)inputPath
{
    NSString *text = [NSString stringWithContentsOfFile:inputPath encoding:NSUTF8StringEncoding error:nil];
    NSData *imgData = [[NSData alloc] initWithBase64EncodedString:text options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:imgData];
}
@end
