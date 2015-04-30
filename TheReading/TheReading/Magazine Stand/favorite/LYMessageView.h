//
//  GLMessageView.h
//  LogicBook
//
//  Created by iMac001 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYMessageView : UIView{
    UIView *panelV;
    UILabel *messageLB;
}

+(LYMessageView *)sharedInstance;
-(void)showMessage:(NSString *)msg autoClose:(BOOL)autoClose;

@end
