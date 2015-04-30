//
//  SendingMessageController.h
//  GLWeiBo
//
//  Created by  iMac001 on 12-11-28.
//  Copyright (c) 2012年  iMac001. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendingMessageController : UIViewController
{
    IBOutlet UILabel *messageLB;
}
+(SendingMessageController *)sharedInstance;
-(void) setup;
-(void)showMessage:(NSString *)msg autoClose:(BOOL)autoClose;
@end
