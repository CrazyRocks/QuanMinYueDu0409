//
//  FrostedGlassBackgroundView.h
//  PublicLibrary
//
//  Created by grenlight on 13-12-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrostedGlassBackgroundView : UIView
{
}
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) UIView  *frostesView;
//为避免导航动画时卡，在导航开始时，就移除模糊遮罩层

- (void)generateFrostedGlassImage;

@end
