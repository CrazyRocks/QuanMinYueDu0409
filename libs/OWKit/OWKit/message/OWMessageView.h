//
//  GLMessageView.h
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWMessageView : UIView{
    UIView *panelV;
    UILabel *messageLB;
    
    BOOL    isClosing;
}

+ (OWMessageView *)sharedInstance;
- (void)showMessage:(NSString *)msg autoClose:(BOOL)autoClose;
- (void)close;

@end
