

#import "OWAppLaunch.h"
#import "OWImage.h"

@implementation OWAppLaunch


#define Tag_appStartImageView 1314521

static UIWindow *startImageWindow = nil;

+ (void)show
{
    if (startImageWindow == nil) {
//        startImageWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        startImageWindow.backgroundColor = [UIColor clearColor];
//        startImageWindow.userInteractionEnabled = NO;
//        startImageWindow.windowLevel = UIWindowLevelStatusBar - 1;
        startImageWindow = [UIApplication sharedApplication].keyWindow;
    }
//    [startImageWindow setHidden:NO];

    UIImageView *imageView = nil;
    
//iOS 7 SDK以下不支持用［UIImage imageNamed:]来显示适合4吋屏上的图片
    imageView = [[UIImageView alloc] initWithFrame:startImageWindow.bounds];
    NSString *imageName = @"LaunchImage@2x";
    if (CGSizeEqualToSize(CGSizeMake(320, 568), [UIScreen mainScreen].bounds.size)) {
        imageName = @"LaunchImage-700-568h@2x";
    }
    imageView.image = [OWImage imageWithName:imageName];
    imageView.tag = Tag_appStartImageView;
    [startImageWindow addSubview:imageView];
}

+ (void)hide
{
    [OWAppLaunch stopLoadingAnimation];
    UIImageView *imageView = (UIImageView *)[startImageWindow viewWithTag:Tag_appStartImageView];

    if (imageView) {
        [UIView animateWithDuration:0.6 delay:0 options:0
                         animations:^{
            [imageView setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
            [imageView setAlpha:0];
        } completion:^(BOOL finished) {
            [OWAppLaunch clear];
        }];
    }
}

+ (void)hideWithCustomBlock:(void (^)(UIImageView *))block
{
    UIImageView *imageView = (UIImageView *)[startImageWindow viewWithTag:Tag_appStartImageView];
    if (imageView) {
        if (block) {
            block(imageView);
        }
    }
}

+ (void)clear
{
    UIImageView *imageView = (UIImageView *)[startImageWindow viewWithTag:Tag_appStartImageView];
    [imageView removeFromSuperview];
    imageView = nil;
    
    [startImageWindow removeFromSuperview];
    startImageWindow = nil;
}

+ (void)stopLoadingAnimation
{
}

@end
