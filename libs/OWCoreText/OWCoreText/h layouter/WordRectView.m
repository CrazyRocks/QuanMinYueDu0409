//
//  WordRectView.m
//  OWCoreText
//
//  Created by grenlight on 14/10/27.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "WordRectView.h"
#import "RunObject.h"
#import "OWColor.h"

@implementation WordRectView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        rects = [[NSMutableArray alloc]init];
        allRunRect = [[NSMutableArray alloc]init];
        
    }
    
    return self;
    
}


//初始设置
-(void)setAllRunRect:(NSMutableArray *)array withEdgeInsets:(UIEdgeInsets)edge;
{
    if (array != nil) {
        allRunRect = array;
    }
    
    edgeInsets = edge;
}

//绘制选择文字范围
-(void)drawRectChooseWordWithStart:(int)startNumber End:(int)endNumber;
{
    start = startNumber;
    end = endNumber;
    
    [self setNeedsDisplay];
}

//绘制摘要
-(void)drawBookDigest:(NSMutableArray *)array
{
    if (array.count > 0) {
        rects = array;
    }
    
    [self setNeedsDisplay];
}


//清除选择的文字
-(void)clearChooseLine
{
    start = 0;
    end = 0;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    [self drawChooseLines];
    //画下横线
    [self drawDigest];
}

-(void)drawChooseLines
{
    
    if (start == end && end != 0) {
        
        NSValue *rectValue = [allRunRect objectAtIndex:start];
        
        CGRect rect = [rectValue CGRectValue];
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(ctx, rect.size.height);
        // 设置线段头尾部的样式
        CGContextSetLineCap(ctx, kCGLineCapButt);
        
        // 设置线段转折点的样式
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        /**  第1根线段  **/
        // 设置颜色
        CGContextSetRGBStrokeColor(ctx, 0, 180.0f/0.0f, 214.0f/0.0f, 0.4);
        
        CGContextMoveToPoint(ctx, rect.origin.x +
                             edgeInsets.left, rect.origin.y + edgeInsets.top + rect.size.height/2);
        
            CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width + edgeInsets.left ,rect.origin.y+ edgeInsets.top + rect.size.height/2);
        
        CGContextStrokePath(ctx);
        
    }
    else{
        if (!allRunRect || allRunRect.count == 0) {
            return;
        }
        for (NSInteger i = start; i < end ; i++) {
            NSValue *rectValue = [allRunRect objectAtIndex:i];
            
            CGRect rect = [rectValue CGRectValue];
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            
            CGContextSetLineWidth(ctx, rect.size.height);
            // 设置线段头尾部的样式
            CGContextSetLineCap(ctx, kCGLineCapButt);
            
            // 设置线段转折点的样式
            CGContextSetLineJoin(ctx, kCGLineJoinRound);
            /**  第1根线段  **/
            // 设置颜色
            CGContextSetRGBStrokeColor(ctx, 167.0f/255.0f, 134.0f/255.0f, 117.0f/255.0f,0.4);
            
            
            CGContextMoveToPoint(ctx, rect.origin.x + edgeInsets.left, rect.origin.y + edgeInsets.top + rect.size.height/2);
            
            CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width + edgeInsets.left ,rect.origin.y+ edgeInsets.top + rect.size.height/2);
            
            CGContextStrokePath(ctx);
        }
        
    }
    
//    [self showSlider];
}

//画下横线
-(void)drawDigest
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if (rects.count == 0) {
        return;
    }
    
    for (RunObject  *runObj in rects) {
        
        CGRect rect = [runObj.rectValue CGRectValue];
        
        CGContextSetLineWidth(ctx, 2.0f);
        // 设置线段头尾部的样式
        CGContextSetLineCap(ctx, kCGLineCapButt);
        
        // 设置线段转折点的样式
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        // 设置颜色
        if (runObj.color!= nil && ![runObj.color isEqualToString:@""]) {
            
            [[OWColor colorWithHexString:runObj.color] setStroke];
        }
        else{
            
            [[UIColor orangeColor] setStroke];
        }
        
        CGContextBeginPath(ctx);
        
        CGContextMoveToPoint(ctx, rect.origin.x + edgeInsets.left, rect.origin.y + edgeInsets.top + rect.size.height+3);
        
        CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width + edgeInsets.left ,rect.origin.y+ edgeInsets.top + rect.size.height+3);
        
        CGContextStrokePath(ctx);
        
    }
    
}



@end
