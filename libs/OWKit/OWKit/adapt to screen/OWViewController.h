//
//  OWViewController.h
//  KWFBooks
//
//  Created by 龙源 on 13-6-28.
//
//

#import <UIKit/UIKit.h>
#import "OWNavigationController.h"
#import "OWNavigationBar.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "RequestStatusManageView.h"
#import "OWModalViewAnimator.h"


@interface OWViewController : UIViewController<UIGestureRecognizerDelegate>
{
     __weak IBOutlet OWNavigationBar *navBar;

    //是否需要显示导航条
    BOOL needShowNavigationBar;
    
    //是否需要恢复布局？（返回至上一级时，上一级视图就处于恢复模式）
    BOOL needRestoreLayout;
    
    AFHTTPRequestOperation  *httpRequest;
    IBOutlet RequestStatusManageView *statusManageView;
    
}

- (id)initWithNoneNavigationBar;

//状态视图
- (void)createStatusManageView;
- (void)showFaultStatusManageView;

- (NSString *)loadingMessage;
- (NSString *)errorMessage;
- (UIColor *)shimmeringColor;

- (void)releaseData;

- (IBAction)reloading:(id)sender;

- (void)transitionFromViewController:(UIViewController *)fromViewController
                    toViewController:(UIViewController *)toViewController
                       withViewFrame:(CGRect)viewFrame;

- (IBAction)comeback:(id)sender;

- (void)updateStatusBarStyle;

- (UIImage *)captureViewImage;

//由父级传递背景过来，避免改动时需要更新多处
- (void)setBackgroundColor:(UIColor *)color;

/*
 在PathStyleGestureController中，用于除了导航，不响应其它事件
 */
- (void)intoFreeze;
- (void)outFreeze;
- (void)removePanGesture;

@end
