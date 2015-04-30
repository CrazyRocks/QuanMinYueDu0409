//
//  BubbleView.h
//  气泡控件
//
//  Created by iMac001 on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface GLBubble : UIView
{

}
@property(nonatomic,assign)float anglePointX;//尖角位置

-(id)initWithFrame:(CGRect)frame andAnglePoint:(float)apx;

//通过尖角位置及气泡宽度重绘
-(void)drawView:(float)apX :(float)width;
@end

