//
//  OWTiledView.m
//  OWUIKit
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWTiledView.h"

@implementation OWTiledView
+ (Class)layerClass
{
    return [CATiledLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];

    }
    return self;
}

-(id)initWithFrame:(CGRect)frame tiledHeight:(float)height{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];

    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.backgroundColor = [UIColor clearColor];
    contentLayer = (id)[self layer];
    contentLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = mainScreen.scale;
    
    CGSize tileSize = CGSizeMake(mainScreen.bounds.size.width*scale, mainScreen.bounds.size.height * scale);
    contentLayer.tileSize = tileSize;
}

-(void)setDrawBlock:(DrawLayerBlock)block{
    drawBlock = [block copy];
    
}


-(void)drawLayer{
    [contentLayer setNeedsDisplay];
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    if(drawBlock)
        drawBlock(ctx);
}

-(void)clearContents{
    contentLayer.contents = nil;
}

@end
