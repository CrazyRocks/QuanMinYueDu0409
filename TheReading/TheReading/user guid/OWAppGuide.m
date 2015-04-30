

#import "OWAppGuide.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@implementation OWAppGuide


#define Tag_appStartImageView 1314521

static UIWindow *startImageWindow = nil;

+ (void)show
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (![defaults boolForKey:@"initGuidAlready"]) {
        [defaults setBool:YES forKey:@"initGuidAlready"];//已初始化设置
        [defaults synchronize];
        
        if (startImageWindow == nil) {
            startImageWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            startImageWindow.backgroundColor = [UIColor clearColor];
            startImageWindow.userInteractionEnabled = YES;
            startImageWindow.windowLevel = UIWindowLevelStatusBar + 1;
        }
        
        CGRect frame = CGRectMake(0, 0, appWidth, appHeight);
        [[GuideViewController sharedInstance].view setFrame:frame];
        [GuideViewController sharedInstance].view.alpha = 0;
        [startImageWindow addSubview:[GuideViewController sharedInstance].view];
        
        [startImageWindow setHidden:NO];
        
        [UIView animateWithDuration:0.25 animations:^{
            [GuideViewController sharedInstance].view.alpha = 1;
        }];

    }
    
}


+ (void)clear
{
    [startImageWindow removeFromSuperview];
    startImageWindow = nil;
}


@end
