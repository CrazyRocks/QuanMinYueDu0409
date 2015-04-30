//
//  GLPhotoController.h
//  DragonSourceEPUB
//
//  Created by iMac001 on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class GLPhotoView;
@interface GLPhotoController : UIViewController
{
@private
    UIDeviceOrientation currentOrientation;
    CGRect portraitFrame;
    CGRect landscapeFrame;
    CGRect currentFrame;
    
    GLPhotoView *rootView;
    
    //正在关闭全屏的动画过程中,视图Frame也是在变化的,所以此时旋转设备的话视图frame是home
    BOOL closingFullScreen;
        
}
-(void)beginObserverOrientationChange;
-(void)removeObserverOrientationChange;
-(void)executeOrientationChange:(UIDeviceOrientation)orientation;
@end
