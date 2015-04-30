//
//  BookshelfGradientBG.h
//  KWFBooks
//
//  Created by grenlight on 13-10-10.
//
//

#import <UIKit/UIKit.h>

@interface BookshelfGradientBG : UIView
{
    UIView *frontImageView, *backImageView;
    CGPoint frontCenter, backCenter;
    
    NSInteger offsetCount;
    
    float currentOffsetY;
}

- (void)setContentOffsetY:(float)offsetY;

@end
