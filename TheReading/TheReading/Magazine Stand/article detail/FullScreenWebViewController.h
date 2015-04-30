//
//  FullScreenWebViewController.h
//  GoodSui
//
//  Created by grenlight on 14-2-14.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FULLSCREEN_HTML    @"<html><head>\
<style>\
html{margin:0px; padding:0px;}\
img{margin:auto; padding:auto; width:320px; border:0px;\
position:absolute; top:50%; bottom:50%; left:0px;}\
</style></head>\
<body style=\"margin:0px; padding:0px; background-color:#000000;\">\
\
<img src='%@' />\
\
</body></html>"

@interface FullScreenWebViewController : UIViewController<UIGestureRecognizerDelegate>
{
    __weak IBOutlet UIWebView *webView;
    UITapGestureRecognizer *tapGesture;
}
+ (FullScreenWebViewController *)sharedInstance;

- (void)showImage:(NSString *)url;

@end
