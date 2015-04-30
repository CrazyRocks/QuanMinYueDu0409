//
//  LYCoverAnimationView.h
//  LYBookStore
//
//  Created by grenlight on 14-4-21.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "OWAnimateView.h"
#import "OWBlockDefine.h"

@interface OWCoverAnimationView : OWAnimateView
{
    
    UIImage     *coverImage;
    
    float translationX;
    float acceleration;
    float speed;
    bool _opened;
    
    GLNoneParamBlock closeCallBack;
    
}
@property (nonatomic, strong)  UIImageView *coverView, *coverMaskView;

- (void)viewWithImage:(UIImage *)img;
- (void)closeCover:(GLNoneParamBlock)callBack;

@end
