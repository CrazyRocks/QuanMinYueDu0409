//
//  GLAsyncMessageController.h
//  LogicBook
//
//  Created by iMac001 on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


@interface GLAsyncMessageController : UIViewController
{
    IBOutlet UILabel *messageLB;
}
+(GLAsyncMessageController *)sharedInstance;
-(void)showMessage:(NSString *)msg autoClose:(BOOL)autoClose;

@end
