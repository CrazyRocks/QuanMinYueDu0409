//
//  LoginViewController.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-12.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalManager.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@interface LoginViewController : XibAdaptToScreenController<UITextFieldDelegate>
{
    __weak IBOutlet UIView *panelView;
    __weak IBOutlet UITextField  *userNameField;
    __weak IBOutlet UITextField  *pwdField;
        
    __weak IBOutlet UIImageView    *bgImgView, *slogon;
    __weak IBOutlet UIButton   *callButton, *settingButton, *loginButton;
    __weak IBOutlet UILabel    *cellPhoneLB;
    
    __weak IBOutlet NSLayoutConstraint  *bottomConstraint, *topConstraint;
    
    CGPoint homeCenter, schoolCenter;
    
    LYAccountManager *requestManager;

}
@property (nonatomic, copy) GLNoneParamBlock loginCompleteBlock;
//弹出层级，默认是一级，从设置退出后重新登，是两级；
@property (nonatomic, assign) NSInteger popTimes;

-(IBAction)login:(id)sender;
- (IBAction)call:(id)sender;

@end
