//
//  OWBottomAlignImageView.h
//  OWKit
//
//  Created by grenlight on 14/8/7.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWBottomAlignImageView : UIImageView
{
    //底边y坐标
    float   coverBottomY;
    float   originalHeight;
}

- (void)setImageWithURL:(NSString *)url;

@end
