//
//  OWContentView.m
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWInfiniteContentView.h"
#import "OWInfiniteCoreTextLayouter.h"
#import "OWCoreTextLayoutLine.h"
#import "OWCoreTextGlyphRun.h"
#import "OWCoreTextLayoutFrame.h"
#import <QuartzCore/QuartzCore.h>
#import "OWTextAttachment.h"
#import "PageImage.h"
#import "OWAnnotationButton.h"
#import "OWMagnifierView.h"

@interface GLTiledLayer : CATiledLayer

@end

@implementation GLTiledLayer

+ (CFTimeInterval)fadeDuration
{
    return 0;
}

@end

@implementation OWInfiniteContentView

@synthesize autoLayoutCustomSubviews;
@synthesize layouter;

+ (Class)layerClass
{
	return [GLTiledLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        _layoutFrame = [[OWInfiniteContentLayoutFrame alloc] init];
        self.contentMode = UIViewContentModeTopLeft; // to avoid bitmap scaling effect on resize
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self configLayer];
}

- (void)configLayer
{
    CATiledLayer *layer = (id)self.layer;
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = mainScreen.scale;
    
    CGSize tileSize = CGSizeMake(mainScreen.applicationFrame.size.width * scale, CGRectGetHeight(self.frame)* scale);
    layer.tileSize = tileSize;
}

-(OWCoreTextLayouter *)layouter
{
    return _layouter;
}

-(void)setLayouter:(OWCoreTextLayouter *)alayouter
{
    if (_layouter == alayouter)
        return;
    
    _layouter = alayouter;
    _layoutFrame.frame = _layouter.textRect;

    [self configLayer];
    self.layer.contents = nil;
    [self.layer setNeedsDisplay];
    
    [self drawAttachments];
}

- (void)layoutSubviewsInRect:(CGRect)rect {}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    if (!_layouter) {
        return;
    }
	CGRect rect = CGContextGetClipBoundingBox(context);
    CGContextSetFillColorWithColor(context, [self.backgroundColor CGColor]);
	CGContextFillRect(context, rect);
    if (_layouter && [_layouter respondsToSelector:@selector(linesVisibleInRect:)]) {
        visibleLines = [_layouter linesVisibleInRect:rect];
        _layoutFrame.lines = visibleLines;
        [_layoutFrame drawInContext:context drawImages:YES];
    }
}

//绘制附件
-(void)drawAttachments
{
    for (OWCoreTextLayoutLine *oneLine in _layouter.getAllLines) {
        for (OWCoreTextGlyphRun *oneRun in oneLine.glyphRuns) {
            OWTextAttachment *attachment = [oneRun attachment];
            
            if (attachment && attachment.contentType == OWTextAttachmentTypeAnnotation) {
                attachment.positionCenter = CGPointMake( CGRectGetMidX(oneRun.frame)+CGRectGetMinX(_layouter.textRect),  CGRectGetMidY(oneRun.frame)-2);
                CGRect frame = CGRectMake(0, 0, 30, 30);
                OWAnnotationButton *annotationBT = [[OWAnnotationButton alloc]initWithFrame:frame content:attachment.contents];
                [annotationBT setCenter:attachment.positionCenter];
                [self addSubview:annotationBT];
                [annotations addObject:annotationBT];
            }
        }
	}
}


//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    magnifierView = [[OWMagnifierView alloc]initWithFrame:CGRectMake(0, 0, 95, 95)];
//    CGPoint touchPoint = [[touches anyObject] locationInView:[UIApplication sharedApplication].keyWindow];
//    [magnifierView magnify:touchPoint viewChanged:YES];
//    [[UIApplication sharedApplication].keyWindow addSubview:magnifierView];
//
//}
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    CGPoint newPoint = [[touches anyObject] locationInView:[UIApplication sharedApplication].keyWindow];
//    [magnifierView magnify:newPoint viewChanged:NO];
//    
////    newPoint.y -= CGRectGetHeight(magnifierView.frame);
////    
////    [UIView animateWithDuration:0.2 animations:^{
////        [magnifierView setCenter:newPoint];
////    }];
//    
//}
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self removeMagnifierView];
//    
//}
//-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self removeMagnifierView];
//}
//
//-(void)removeMagnifierView{
//    [magnifierView removeFromSuperview];
//    magnifierView = nil;
//}

@end
