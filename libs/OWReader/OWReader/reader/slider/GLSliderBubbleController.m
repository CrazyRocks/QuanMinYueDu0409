//
//  GLSliderBubbleController.m
//  GLFunction
//
//  Created by iMac001 on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GLSliderBubbleController.h"
#import "GLBubble.h"

#define PADDING_LR 5

@interface GLSliderBubbleController ()
{
    IBOutlet GLBubble *bubble; 
    IBOutlet UILabel *titleLB;
    IBOutlet UILabel *pageNumberLB;
    
    CGRect _starFrame;
    CGRect _endFrame;
    CGPoint _point;//气泡尖尖的位置
}
@end

@implementation GLSliderBubbleController

- (id)init
{
    self = [super initWithNibName:@"GLSliderBubbleController" bundle:[NSBundle bundleForClass:[self class]]];
    if(self){
        _starFrame = CGRectZero;
        _endFrame = CGRectZero;

        self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(void)resetTitle:(NSString *)title pageNumber:(NSString *)page andAnglePoint:(CGPoint)point
{
    _endFrame.origin.x = point.x;
    titleLB.text =  title.length > 19 ? [title substringToIndex:19] :title;
    titleLB.clipsToBounds = YES;
    pageNumberLB.text = page;
    
    CGSize titleSize = CGSizeMake(270, 200);
    titleSize = [title sizeWithFont:titleLB.font constrainedToSize:titleSize 
                      lineBreakMode:NSLineBreakByWordWrapping];
    if(_starFrame.origin.y == 0 ){
        _starFrame = self.view.frame;
        _starFrame.size.height = 62;
        _starFrame.origin.y = point.y - (_starFrame.size.height + 20);
        _endFrame.origin.y = point.y - 10;

    }
    //触点位置小于左中心点或大于右中心点时，气泡保持不动，只调整尖角位置
    float width, leftCenterX, rightCenterX;
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    width = titleSize.width + 40;
    float maxWidth = [UIScreen mainScreen].bounds.size.width - PADDING_LR*2;
    if (width > maxWidth) width = maxWidth;
    else if(width < 40 + 50) width = 90;
    
    leftCenterX = width / 2 + PADDING_LR;
    rightCenterX = screenWidth - leftCenterX;
   
    float bubblePointX;//气泡坐标
    float anglePointX;//尖角的坐标
    if(point.x < leftCenterX){
        bubblePointX = PADDING_LR;
        anglePointX = point.x - PADDING_LR;
    }
    else if(point.x > rightCenterX){
        bubblePointX = screenWidth -(width + PADDING_LR);
        anglePointX = point.x - bubblePointX;
    }
    else{
        anglePointX = width / 2;
        bubblePointX = point.x - width / 2;
    }
    _starFrame.size.width = width;
    _starFrame.origin.x = bubblePointX;
    [bubble drawView:anglePointX :width];
    [self.view insertSubview:bubble atIndex:0];
    [self.view setFrame:_starFrame];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.layer.shouldRasterize = YES;

    [self.view setFrame:_endFrame];
    [self.view setAlpha:0.3];

    [UIView animateWithDuration:0.25f delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        [self.view setFrame:_starFrame];
        [self.view setAlpha:1];
    } completion:^(BOOL finished) {
        self.view.layer.shouldRasterize = NO;
    }];
}

-(void)removeFromSupperview
{
    [UIView animateWithDuration:0.20f delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        [self.view setFrame:_endFrame];
        [self.view setAlpha:0.2];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}


@end
