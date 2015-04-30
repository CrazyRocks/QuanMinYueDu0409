//
//  BookshelfGradientBG.h
//  KWFBooks
//
//  Created by 龙源 on 13-10-10.
//
//

#import <UIKit/UIKit.h>

@interface MagsStandGradientBG : UIView
{
    UIImageView *frontImageView, *backImageView;
    CGPoint frontCenter, backCenter, originalCenter;
    
    int offsetCount;
    
    float currentOffsetY;
    
    
}

- (void)setContentOffsetY:(float)offsetY;

@end
