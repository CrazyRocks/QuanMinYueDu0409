//
//  LYHelpViewController.h
//  LYBookStore
//
//  Created by grenlight on 14/8/28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "XibAdaptToScreenController.h"

@interface LYHelpViewController : XibAdaptToScreenController<UIWebViewDelegate>
{
    __weak IBOutlet UIWebView   *webView;
}
@end
