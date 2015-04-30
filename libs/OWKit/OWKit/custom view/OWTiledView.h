//
//  OWTiledView.h
//  OWUIKit
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OWBlockDefine.h"

@interface OWTiledView : UIView
{
    CATiledLayer                 *contentLayer;
    DrawLayerBlock               drawBlock;
}

-(id)initWithFrame:(CGRect)frame tiledHeight:(float)height;
-(void)setDrawBlock:(DrawLayerBlock)block;
-(void)drawLayer;

-(void)clearContents;

@end
