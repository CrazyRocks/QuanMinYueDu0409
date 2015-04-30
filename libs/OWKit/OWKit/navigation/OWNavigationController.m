//
//  UINavigationController+SlideEffect.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-23.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "OWNavigationController.h"
#import "OWViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIPanGestureRecognizer+Cancel.h"
#import "OWColor.h"

#define MIN_SCALE 0.90
#define DURATION 0.45
#define DURATION2 0.6
#define   ROTATE_Y 1.0

CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ)
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ)
{
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}

@interface OWNavigationController()
{
    NSMutableArray *controllers;
}
@end

@implementation OWNavigationController

+ (OWNavigationController *)sharedInstance
{
    static OWNavigationController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OWNavigationController alloc] init];
        instance.canMoveByPanGesture = YES;
    });
    return instance;
}

- (void)releaseAllControllers
{
    for (OWViewController *controller in controllers) {
        if ([controller isViewLoaded]) {
            [controller.view removeFromSuperview];
            controller.view = nil;
        }
        [controller removeFromParentViewController];
    }
    [controllers removeAllObjects];
}

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appWidth, appHeight)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    isAnimating = NO;
    
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(panGestureRecognizer:)];
    pan.delegate = self;
    
    touchSchoolCenter = CGPointMake(appWidth / 2.0f + appWidth, appHeight/2.0f);
    touchHomeCenter = CGPointMake(appWidth / 2.0f, appHeight/2.0f);
    
    touchHomeCenter.y += viewFrameOffsetY;
    touchSchoolCenter.y += viewFrameOffsetY;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!isiOS7 && self.view.superview.frame.size.height == appHeight) {
        CGPoint center = CGPointMake(appWidth / 2.0f, appHeight/2.0f);
        center.y -= viewFrameOffsetY;
        [self.view setCenter:center];
    }
}

- (UIViewController *)topViewController
{
    if (controllers && controllers.count > 0)
        return [controllers lastObject];
    else
        return self;
}

- (void)setRooController:(OWViewController *)viewController
{
    controllers = [[NSMutableArray alloc] init];
    [controllers addObject:viewController];
    [self addChildViewController:viewController];
    
    frame = CGRectMake(0, viewFrameOffsetY, appWidth, appHeight);
    
    UIView *customView = viewController.view;
    
    /*
     需要先添加进视图渲染树再设置setTranslatesAutoresizingMaskIntoConstraints，
     最后调整frame 才有效。
     */
    [self.view addSubview:customView];
    [customView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [customView setFrame:frame];
    
    //    [self addConstraintWithItem:customView];
    //    [self addConstraintWithItem:customView];
}

- (void)addConstraintWithItem:(UIView *)customView
{
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:customView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:appHeight]];
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:customView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:customView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    if (isiOS7) {
        [self.view addConstraint:
         [NSLayoutConstraint constraintWithItem:customView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    }
    else {
        [self.view addConstraint:
         [NSLayoutConstraint constraintWithItem:customView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:-20]];
    }
    
    //    [self.view updateConstraintsIfNeeded];
    
    //    NSLog(@"constrains:%i", self.view.constraints.count);
}

- (OWViewController *)pushControllerToStack:(OWViewController *)viewController
{
    OWViewController *lastController = [controllers lastObject];
    
    if (lastController == viewController) {
        return nil;
    }
    
    [self addChildViewController:viewController];
    [controllers addObject:viewController];
    
    [pan cancel];
    [lastController.view removeGestureRecognizer:pan];
    [viewController.view addGestureRecognizer:pan];
    
    return lastController;
}

- (OWViewController *)popControllerFromStack
{
    [controllers removeLastObject];
    return [controllers lastObject];
}


- (void)pushViewController:(OWViewController *)viewController
{
    [self pushViewController:viewController animationType:owNavAnimationTypeSlideFromRight];
}

- (void)pushViewController:(OWViewController *)viewController animationType:(OWNavigationAnimationType)animationType
{
    if (isAnimating || !viewController) return;
    
    toController = viewController;
    fromController = [self pushControllerToStack:toController];
    if (!fromController) return;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    isAnimating = YES;
    
    switch (animationType) {
        case owNavAnimationTypeDegressPathEffect:
            [self excuteDegressPathPushAnimation:animationType];
            break;
            
        default:
            [self pushBySlideIn_ScaleOutEffect:animationType releaseDelay:0];
            break;
    }
}

- (void)pushViewController:(OWViewController *)viewController animated:(BOOL)animated
{
    if (animated) {
        
    }
    else {
        toController = viewController;
        fromController = [self pushControllerToStack:viewController];
        if (!fromController) return;
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        [self pushBySlideIn_ScaleOutEffect:owNavAnimationTypeBasic releaseDelay:0.6];

    }
}

- (void)pushBySlideIn_ScaleOutEffect:(OWNavigationAnimationType)animationType releaseDelay:(NSTimeInterval)delay
{
    mask = [self maskView];
    [mask setAlpha:0];
    [mask setFrame:frame];
    [self.view addSubview:mask];
    
    CGPoint homeCenter = CGPointMake(appWidth / 2.0f, (appHeight/2.0f) + viewFrameOffsetY);
    
    
    CGPoint schoolCenter = homeCenter;
    if (animationType == owNavAnimationTypeSlideFromBottom)
        schoolCenter.y += appHeight;
    
    else if (animationType == owNavAnimationTypeSlideFromLeft)
        schoolCenter.x -= appWidth;
    
    else if (animationType == owNavAnimationTypeBasic)
        schoolCenter.x -= 0;
    else
        schoolCenter.x += appWidth;
    
    [self.view addSubview:toController.view];
    [toController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    [toController.view setFrame:frame];
    [toController.view setCenter:schoolCenter];
    
    CGAffineTransform transform = CGAffineTransformMakeScale(MIN_SCALE, MIN_SCALE);
    [UIView animateWithDuration:DURATION
                     animations:^{
                         [mask setAlpha:1];
                         
                         [toController.view setCenter:homeCenter];
                         fromController.view.transform = transform;
                     }
                     completion:^(BOOL finished) {
                         [mask removeFromSuperview];
                         fromController.view.transform = CGAffineTransformIdentity;
                         [fromController.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:delay];
                         [toController updateStatusBarStyle];
                         [self performSelector:@selector(enableInteraction) withObject:nil afterDelay:(delay + 0.3)];
                     }];
}

-(UIView *)maskView
{
    UIView *maskView =[[UIView alloc] initWithFrame:CGRectMake(0, viewFrameOffsetY, appWidth, appHeight)];
    
    maskView.backgroundColor = [OWColor colorWithHex:0x000000 alpha:0.85];
    return maskView;
}

- (void)popViewController
{
    [self popViewController:owNavAnimationTypeSlideToRight];
}

- (void)popViewController:(OWNavigationAnimationType)animationType
{
    [self popByNumberOfTimes:1 animationType:animationType];   
}

- (void)popToViewController:(Class)className
              animationType:(OWNavigationAnimationType)animationType
{
    if (isAnimating) return;
    
    isAnimating = YES;
    fromController = [controllers lastObject];

    toController = [self getControllerByClassName:className];
    [self popByAnimationType:animationType];
}

- (OWViewController *)getControllerByClassName:(Class)className
{
    OWViewController *tempController = [self popControllerFromStack];
    if (![tempController isKindOfClass:className]) {
        [tempController releaseData];
        if ([tempController isViewLoaded]) {
            [tempController.view removeFromSuperview];
            tempController.view = nil;
        }
        [tempController removeFromParentViewController];
        tempController = nil;
        
        return [self getControllerByClassName:className];
    }
    else {
        return tempController;
    }
}

- (void)popByNumberOfTimes:(NSInteger)times
              animationType:(OWNavigationAnimationType)animationType
{
    if (isAnimating || controllers.count <= 1) return;
    
    isAnimating = YES;

    fromController = [controllers lastObject];

    for (NSInteger i=(times-1); i>=0; i--) {
        toController = [self popControllerFromStack];
        if (i>0) {
            [toController releaseData];
            if ([toController isViewLoaded]) {
                [toController.view removeFromSuperview];
                toController.view = nil;
            }
            [toController removeFromParentViewController];
            toController = nil;
        }
    }
    [self popByAnimationType:animationType];
}

- (void)popViewControllerWithNoneAnimation:(float)duration
{
    if (isAnimating) return;
    
    isAnimating = YES;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    fromController = [controllers lastObject];
    toController = [self popControllerFromStack];
    
    [self popBySlideOut_ScaleInEffect:owNavAnimationTypeBasic releaseDelay:duration];
    
}

- (void)popByAnimationType:(OWNavigationAnimationType)animationType
{
    if (!fromController || !toController || toController == fromController) {
        isAnimating = NO;
        return ;
    }
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    switch (animationType) {
        case owNavAnimationTypeDegressPathEffect:
            [self excuteDegressPathPopAnimation:animationType];
            break;
            
        default:
            [self popBySlideOut_ScaleInEffect:animationType releaseDelay:0];
            break;
    }
}

- (void )popBySlideOut_ScaleInEffect:(OWNavigationAnimationType)animationType releaseDelay:(NSTimeInterval)delay
{
    mask = [self maskView];
    [mask setAlpha:1];
    [self.view insertSubview:mask belowSubview:fromController.view];
    
    CGPoint fViewCenter = CGPointMake(appWidth / 2.0f, appHeight/2.0f);
    
    if (!isiOS7)
        fViewCenter.y -= 20;
    
    if(animationType == owNavAnimationTypeSlideToBottom)
        fViewCenter.y += appHeight;
    
    else if (animationType == owNavAnimationTypeSlideToLeft)
        fViewCenter.x -= appWidth;
    
    else if (animationType == owNavAnimationTypeBasic)
        fViewCenter.x -= 0;
    
    else
        fViewCenter.x += appWidth;
    
    [self.view insertSubview:toController.view belowSubview:mask];
    [toController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    [toController.view setFrame:frame];
    
    toController.view.transform = CGAffineTransformMakeScale(MIN_SCALE, MIN_SCALE);
    CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateWithDuration:DURATION delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [mask setAlpha:0];
                         [fromController.view setCenter:fViewCenter];
                         toController.view.transform = transform;
                     } completion:^(BOOL finished) {
                         [self popAnimationComplete:delay];
                     } ];
    
    
}

- (void)excuteDegressPathPushAnimation:(OWNavigationAnimationType)effect
{
    UIView *fromView = fromController.view;
    
    mask = [self maskView];
    [mask setFrame:CGRectMake(0, 0, appWidth, appHeight)];
    
    CATransform3D transform1 = fromView.layer.transform;
    transform1 = CATransform3DRotate(transform1, +ROTATE_Y, 0, 1, 0);
    transform1 = CATransform3DTranslate(transform1, CGRectGetWidth(fromView.frame)/2, 0, -300);
    transform1 = CATransform3DPerspect(transform1,CGPointMake(0, 0.5), 300);
    
    
    CATransform3D transloate = CATransform3DMakeTranslation(CGRectGetWidth(fromView.frame)*3/5, 0, 200);
    
    CATransform3D transform2 = toController.view.layer.transform;
    transform2 = CATransform3DRotate(transform2, 0.1, 1, 0, 1);
    transform2 = CATransform3DRotate(transform2, -ROTATE_Y, 0, 1, 0);
    CATransform3D mat = CATransform3DConcat(transform2, transloate);
    transform2 = CATransform3DPerspect(mat,CGPointMake(0.5, 0.5), 200);
    
    UIView *superView = toController.view.superview;
    CATransform3D fromeTransform;
    float  maskAlphaTo ;
    
    if (effect == owNavAnimationTypeDegressPathEffect) {
        [mask setAlpha:0];
        maskAlphaTo = 0.9;
        
        [fromView addSubview:mask];
        [superView insertSubview:fromView belowSubview:toController.view];
        toController.view.layer.transform = transform2;
        fromeTransform = transform1;
    }
    else {
        [mask setAlpha:1];
        maskAlphaTo = 0;
        [toController.view addSubview:mask];
        [superView addSubview:fromView];
        toController.view.layer.transform = transform1;
        fromeTransform = transform2;
    }
    [self.view addSubview:toController.view];
    [toController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    [toController.view setFrame:frame];
    
    [UIView animateWithDuration:DURATION2 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [mask setAlpha:maskAlphaTo];
                         toController.view.layer.transform = CATransform3DIdentity;
                         fromView.layer.transform = fromeTransform;
                     }
                     completion:^(BOOL finished) {
                         [mask removeFromSuperview];
                         fromView.transform = CGAffineTransformIdentity;
                         [fromView removeFromSuperview];
                         [self performSelector:@selector(enableInteraction) withObject:nil afterDelay:0.3];
                     }];
}

- (void)excuteDegressPathPopAnimation:(OWNavigationAnimationType)effect
{
    mask = [self maskView];
    UIView *fromView = fromController.view;
    
    CATransform3D transform1 = toController.view.layer.transform;
    transform1 = CATransform3DRotate(transform1, +ROTATE_Y, 0, 1, 0);
    transform1 = CATransform3DTranslate(transform1, CGRectGetWidth(fromView.frame)/2, 0, -300);
    transform1 = CATransform3DPerspect(transform1,CGPointMake(0, 0.5), 300);
    
    CATransform3D transloate = CATransform3DMakeTranslation(CGRectGetWidth(fromView.frame)*3.5/5, 0, 400);
    
    CATransform3D transform2 = fromView.layer.transform;
    transform2 = CATransform3DRotate(transform2, 0.1, 1, 0, 1);
    transform2 = CATransform3DRotate(transform2, -ROTATE_Y, 0, 1, 0);
    CATransform3D mat = CATransform3DConcat(transform2, transloate);
    
    transform2 = CATransform3DPerspect(mat,CGPointMake(0.5, 0.5), 550);
    
    UIView *superView = self.view;
    CATransform3D fromeTransform;
    float  maskAlphaTo ;
    
    if (effect == owNavAnimationTypeDegressPathEffect) {
        [mask setAlpha:1];
        maskAlphaTo = 0;
        [toController.view addSubview:mask];
        toController.view.layer.transform = transform1;
        fromeTransform = transform2;
    }
    else {
        [mask setAlpha:0];
        maskAlphaTo = 0.9;
        [fromView addSubview:mask];
        [superView insertSubview:fromView belowSubview:toController.view];
        toController.view.layer.transform = transform2;
        fromeTransform = transform1;
        
    }
    [toController.view setFrame:frame];
    [self.view insertSubview:toController.view belowSubview:fromView];
    
    //    [fromView setAlpha:0];
    [UIView animateWithDuration:DURATION2 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [mask setAlpha:maskAlphaTo];
                         toController.view.layer.transform = CATransform3DIdentity;
                         fromView.layer.transform = fromeTransform;
                     }
                     completion:^(BOOL finished) {
                         [self popAnimationComplete:0];
                     }];
    
}

#pragma mark gesture
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (isAnimating || !self.canMoveByPanGesture) return;
    
    switch ([gestureRecognizer state]) {
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateBegan:
            [self gestureRecognizeBegan:gestureRecognizer];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self gestureRecognizeChanged:gestureRecognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self gestureRecognizeEnded:gestureRecognizer];
            break;
            
        default:
            [self gestureRecognizeCancelled:gestureRecognizer];
            
            break;
    }
    
}

- (void)gestureRecognizeBegan:(UIPanGestureRecognizer *)gestureRecognizer
{
    isTouchBegin = YES;
    
    if (isAnimating || controllers.count < 2)
        [pan cancel];
    else
        startPoint = [gestureRecognizer translationInView:[UIApplication sharedApplication].keyWindow];
}

- (void)gestureRecognizeChanged:(UIPanGestureRecognizer *)gestureRecognizer
{
    currentPoint = [gestureRecognizer translationInView:[UIApplication sharedApplication].keyWindow];
    
    if (isTouchBegin) {
        isTouchBegin = NO;
        fromController = [controllers lastObject];
        toController = controllers[controllers.count-2];
        int offsetX = currentPoint.x - startPoint.x;
        
        if (offsetX > 0 && offsetX > abs(currentPoint.y - startPoint.y)) {
            mask = [self maskView];
            [mask setAlpha:1];
            [self.view insertSubview:mask belowSubview:fromController.view];
            
            [self.view insertSubview:toController.view belowSubview:mask];
            [toController.view setTranslatesAutoresizingMaskIntoConstraints:YES];
            [toController.view setFrame:frame];
            toController.view.transform = CGAffineTransformMakeScale(MIN_SCALE, MIN_SCALE);
        }
        else {
            [pan cancel];
        }
    }
    else {
        if (currentPoint.x < startPoint.x) return;
        
        float scale = (currentPoint.x - startPoint.x)/appWidth;
        
        CGPoint fViewCenter = CGPointMake(appWidth / 2.0f, appHeight/2.0f);
        if (!isiOS7)
            fViewCenter.y -= 20;
        fViewCenter.x += currentPoint.x - startPoint.x;
        
        float transScale = MIN_SCALE+(1-MIN_SCALE)*scale;
        CGAffineTransform transform = CGAffineTransformMakeScale(transScale, transScale);
        [UIView animateWithDuration:0.2
                         animations:^{
                             [mask setAlpha:1-scale];
                             [fromController.view setCenter:fViewCenter];
                             toController.view.transform = transform;
                         }];
        
    }
}

- (void)gestureRecognizeEnded:(UIPanGestureRecognizer *)gestureRecognizer
{
    //有时会没有change事件就end了，需要在end处也计算controller
    fromController = [controllers lastObject];
    toController = controllers[controllers.count-2];
    
    if (currentPoint.x - startPoint.x > 80) {
        CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
        [UIView animateWithDuration:0.25
                         animations:^{
                             [mask setAlpha:0];
                             [fromController.view setCenter:touchSchoolCenter];
                             toController.view.transform = transform;
                         }
                         completion:^(BOOL finished) {
                             [controllers removeLastObject];
                             [self popAnimationComplete:0];
                         }];
    }
    else {
        
        CGAffineTransform transform = CGAffineTransformMakeScale(MIN_SCALE, MIN_SCALE);
        [UIView animateWithDuration:0.25
                         animations:^{
                             [mask setAlpha:1];
                             [fromController.view setCenter:touchHomeCenter];
                             toController.view.transform = transform;
                         }
                         completion:^(BOOL finished) {
                             toController.view.transform = CGAffineTransformMakeScale(1, 1);
                             [toController.view removeFromSuperview];
                             [mask removeFromSuperview];
                             
                         }];
    }
}

- (void)gestureRecognizeCancelled:(UIPanGestureRecognizer *)gestureRecognizer
{
    [fromController.view setCenter:touchHomeCenter];
    if ([toController isViewLoaded]) {
        [toController.view removeFromSuperview];
        [mask removeFromSuperview];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)popAnimationComplete:(NSTimeInterval)releaseDelay
{
    [mask removeFromSuperview];
    [fromController.view removeGestureRecognizer:pan];
    [self performSelector:@selector(removePopView) withObject:nil afterDelay:releaseDelay];
    
    if (controllers.count >1)
        [toController.view addGestureRecognizer:pan];
    
    [toController updateStatusBarStyle];
    
}

- (void)removePopView
{
    [fromController releaseData];
    
    if ([fromController isViewLoaded]) {
        [fromController.view removeFromSuperview];
        fromController.view = nil;
    }
    
    [fromController removeFromParentViewController];
    fromController = nil;
    
    [self performSelector:@selector(enableInteraction) withObject:nil afterDelay:0.1];
}

- (void)enableInteraction
{
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    isAnimating = NO;
}


@end
