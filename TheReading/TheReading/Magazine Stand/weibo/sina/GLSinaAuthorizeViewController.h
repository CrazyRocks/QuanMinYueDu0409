//
//  SinaAuthorizeViewController.h
//  WeiBo_Test
//
//  Created by iMac001 on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LYSinaAuthorizeViewControllerDelegate;
@class KWFNavigationBar_DayModel;

@interface GLSinaAuthorizeViewController : UIViewController<UIWebViewDelegate>
{
    UIActivityIndicatorView *indicatorView;
    
	IBOutlet UIWebView *webView;
    IBOutlet KWFNavigationBar_DayModel *navBar;
}

@property (nonatomic, assign) id<LYSinaAuthorizeViewControllerDelegate> delegate;

   
- (void)loadRequestWithURL:(NSURL *)url;

- (void)show:(BOOL)animated;

- (void)hide;
- (IBAction)quit:(id)sender;

@end


@protocol LYSinaAuthorizeViewControllerDelegate <NSObject>

@required
- (void)authorizeCompleted;

- (void)authorizeView:(id)authView didRecieveAuthorizationCode:(NSString *)code;
- (void)authorizeView:(id)authView didFailWithErrorInfo:(NSDictionary *)errorInfo;
- (void)authorizeViewDidCancel:(id)authView;

@end