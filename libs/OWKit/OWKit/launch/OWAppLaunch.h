
#import <Foundation/Foundation.h>


@interface OWAppLaunch : NSObject


+ (void)show;


+ (void)hide;


+ (void)hideWithCustomBlock:(void(^)(UIImageView *imageView))block;


+ (void)clear;

+ (void)stopLoadingAnimation;

@end
