//
//  MaskBackgroundView.h
//  JRReader
//
//  Created by grenlight on 14/11/17.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaskBackgroundView : UIView




@end



@interface MaskBackgroundViewHeader : UIView
{
    CGFloat start;
}

-(id)initWithFrame:(CGRect)frame withStart:(CGFloat)number;

@end

