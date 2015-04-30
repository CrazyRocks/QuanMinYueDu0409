//
//  PwdModifyController.h
//  ZhangShangZhongYuan
//
//  Created by grenlight on 14/7/3.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "PasswordStrengthIndicatorView.h"
#import <OWKit/OWKit.h>

@interface PwdModifyController : OWViewController<UITextFieldDelegate>
{
    __weak IBOutlet UITextField    *firstTF, *secondTF;
    __weak IBOutlet UILabel        *msgLabel;
    __weak IBOutlet UIButton       *closeButton;
    
    __weak IBOutlet PasswordStrengthIndicatorView  *indicatorView;
    
    __weak IBOutlet UIView         *panel;

}
- (IBAction)close:(id)sender;

@end
