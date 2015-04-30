//
//  OWViewController.m
//  KWFBooks
//
//  Created by 龙源 on 13-6-28.
//
//

#import "OWViewController.h"
#import "OWNavigationController.h"
#import "OWColor.h"
#import "OWImage.h"

@interface OWViewController ()
{
}
@end

@implementation OWViewController

- (id)init
{
    self = [super init];
    if (self) {
        needShowNavigationBar = YES;
        needRestoreLayout = NO;        
    }
    return self;
}

- (id)initWithNoneNavigationBar
{
    self = [super init];
    if(self) {
        needShowNavigationBar = NO;
    }
    return self;
}

#pragma mark shimmering view
- (void)createStatusManageView
{
    if (![self isViewLoaded]) {
        return;
    }
    if (!statusManageView) {
        statusManageView = [[RequestStatusManageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds),200)];
        statusManageView.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0f,  CGRectGetHeight(self.view.bounds)/2.0f);
        statusManageView.loadingMessage = [self loadingMessage];
        statusManageView.errorMessage = [self errorMessage];
        statusManageView.parentViewController = self;
        
        statusManageView.frontColor = [self shimmeringColor];
        [self.view addSubview:statusManageView];
    }
    
    [statusManageView startRequest];
}

- (void)showFaultStatusManageView
{
    if (!statusManageView) {
        [self createStatusManageView];
    }
    [statusManageView requestFault];
}

- (NSString *)loadingMessage
{
    return @"正在加载...";
}

- (NSString *)errorMessage
{
    return @"内容加载失败，点击重新加载";
}

- (UIColor *)shimmeringColor
{
    return [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [OWColor colorWithHexString:@"#fafafa"];

	// Do any additional setup after loading the view.
}

- (void)dealloc
{
    [self releaseData];
    [self removeFromParentViewController];
    statusManageView = nil;
//    NSLog(@"dealloc:%@",[self class]);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (httpRequest && [httpRequest isPaused]) {
        [httpRequest resume];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (httpRequest) {
        [httpRequest pause];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

//    if ([self isViewLoaded] && (self.view.window == nil || NULL == self.view.superview)) {
//
//        [self releaseData];
//
//        //释放根视图的逻辑不放到 releaseData,是因为releaseData会在dealloc里调用，而可能此
//        [self.view removeFromSuperview];
//        self.view = nil;
//    }
}

- (void)releaseData
{
    [statusManageView stopRequest];

    if (httpRequest && [httpRequest respondsToSelector:@selector(cancel)]) {
        [httpRequest cancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloading:(id)sender
{
    
}

- (void)networkMessageViewTapped
{
    [self reloading:nil];
}

- (void)transitionFromViewController:(UIViewController *)fromViewController
                    toViewController:(UIViewController *)toViewController
                       withViewFrame:(CGRect)viewFrame
{
    [toViewController.view setFrame:viewFrame];
    [toViewController.view setAlpha:1];
    [self.view insertSubview:toViewController.view atIndex:0];
    
    if ([fromViewController isViewLoaded]) {
        [UIView animateWithDuration:0.25 animations:^{
            [fromViewController.view setAlpha:0];
        } completion:^(BOOL finished) {
            [fromViewController.view removeFromSuperview];
        }];
        
    }
}

- (IBAction)comeback:(id)sender
{
    self.view.userInteractionEnabled = NO;
    [[OWNavigationController sharedInstance] popViewController:owNavAnimationTypeDegressPathEffect];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (void)updateStatusBarStyle
{

}

- (UIImage *)captureViewImage
{
    return [OWImage CompositeImage:self.view];
}

- (void)setBackgroundColor:(UIColor *)color
{
    
}

- (void)intoFreeze
{
    self.view.userInteractionEnabled = NO;
}

- (void)outFreeze
{
    self.view.userInteractionEnabled = YES;
}

- (void)removePanGesture
{
    for (UIGestureRecognizer *gestureRecognizer in self.view.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self.view removeGestureRecognizer:gestureRecognizer];
        }
    }
    self.view.userInteractionEnabled = YES;
}


@end
