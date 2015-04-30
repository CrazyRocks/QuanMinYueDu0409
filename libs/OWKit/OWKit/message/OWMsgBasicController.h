//
//  OWMessageController.h
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWMsgBasicController : UIViewController
{
    __weak IBOutlet UILabel *messageLB;
    __weak IBOutlet UIView  *messagePanel;

    //是否已经在显示列表，没在则添加到显示列表
    bool isShow;
}
-(void)showMessage:(NSString *)msg autoClose:(BOOL)autoClose;
-(void)closeMessage;

-(void)animatingOut;
@end
