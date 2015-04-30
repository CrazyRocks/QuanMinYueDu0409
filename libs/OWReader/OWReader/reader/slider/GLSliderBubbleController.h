//
//  GLSliderBubbleController.h
//  GLFunction
//
//  Created by iMac001 on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLSliderBubbleController : UIViewController{
   
}
//设置汽泡的位置
-(void)resetTitle:(NSString *)title pageNumber:(NSString *)page andAnglePoint:(CGPoint)point;
-(void)removeFromSupperview;
@end
