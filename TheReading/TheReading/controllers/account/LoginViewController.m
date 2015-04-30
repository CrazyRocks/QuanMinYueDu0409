//
//  LoginViewController.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-12.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "LoginViewController.h"
#import "GlobalManager.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "WYMenuManager.h"
#import "UnitSelectionController.h"

@interface LoginViewController ()
{
}
@end

@implementation LoginViewController

- (id)init
{
    self = [super initWithNibName:@"LoginViewController" bundle:nil];
    if (self) {
        requestManager = [[LYAccountManager alloc] init];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(handleKeyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
        //注册通知，监听键盘消失事件
        [nc addObserver:self
               selector:@selector(handleKeyboardDidHidden)
                   name:UIKeyboardWillHideNotification
                 object:nil];
    }
    return self;
}

- (void)releaseData
{
    userNameField.delegate = nil;
    pwdField.delegate = nil;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.popTimes = 1;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    userNameField.delegate = self;
    pwdField.delegate = self;
    userNameField.returnKeyType = UIReturnKeyNext;
    pwdField.returnKeyType = UIReturnKeyJoin;

    float offsetY = 0;
//    bgImgView.image = [UIImage imageNamed:@"login_bg_img"];
  
    CGPoint slogonCenter = slogon.center;
    slogonCenter.y += offsetY;
    [slogon setCenter:slogonCenter];
    
    homeCenter = panelView.center;
    schoolCenter = CGPointMake(homeCenter.x, homeCenter.y - 155-offsetY);
    schoolCenter.y  -= 30;

    [self animateIn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    [self performSelector:@selector(removePanGesture) withObject:Nil afterDelay:1];
}

- (void)removePanGesture
{
    for (UIGestureRecognizer *gestureRecognizer in self.view.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self.view removeGestureRecognizer:gestureRecognizer];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.view removeFromSuperview];
    self.view = nil;
}

- (void)animateIn
{
    [slogon setAlpha:0];
    [userNameField setAlpha:0];
    [pwdField setAlpha:0];
    [callButton setAlpha:0];
    [cellPhoneLB setAlpha:0];
   
    [self fadeIn:slogon duration:0.4 disdanceY:-20 delay:0.2];
    [self fadeIn:userNameField duration:0.55 disdanceY:45 delay:0.5];
    [self fadeIn:pwdField duration:0.55 disdanceY:45 delay:1.0];
    [self fadeIn:cellPhoneLB duration:0.3 disdanceY:0 delay:1.65];
    [self fadeIn:callButton duration:0.3 disdanceY:0 delay:1.8];

}

- (void)fadeIn:(UIView *)v duration:(float)duration disdanceY:(float)dis delay:(float)delay
{
    CGPoint originCenter = v.center;
    CGPoint currentCenter = originCenter;
    currentCenter.y += dis;
    [v setCenter:currentCenter];
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [v setAlpha:1];
                         [v setCenter:originCenter];
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark action
-(void)login:(id)sender
{
    NSString *userName = [userNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *pwd = [pwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if(!userName ||[userName isEqualToString:@""]) {
        [userNameField becomeFirstResponder];
        return;
    }

    if(!pwd || [pwd isEqualToString:@""]) {
        [pwdField becomeFirstResponder];
        return;
    }
    [loginButton setTitle:@"正在登录..." forState:UIControlStateDisabled];
    loginButton.enabled = NO;
    
    [self endEditing];
    
    __unsafe_unretained typeof (self) weakSelf = self;
    GLParamBlock failedCallBack = ^(NSString *message){
        weakSelf->loginButton.enabled = YES;
        [weakSelf->loginButton setTitle:@"登录失败" forState:UIControlStateNormal];

        if (message && message.length > 1) {
            [[OWMessageView sharedInstance] showMessage:message autoClose:YES];
        }
    };
    GLHttpRequstResult successCallBack = ^(id result){
        //返回回来的是单位通道列表，也有可能是左边栏的数组
        if ([result isKindOfClass:[NSArray class]] &&
             [result[0] isKindOfClass:[NSDictionary class]]) {
            [weakSelf pushSelectionController:result];
        }
        else {
            weakSelf.loginCompleteBlock();
        }
    };
    
    [requestManager loginByUserName:userName
                                pwd:pwd
                         completion:successCallBack
                              fault:failedCallBack];
}

- (void)pushSelectionController:(NSArray *)arr
{
    UnitSelectionController *selectionController = [[UnitSelectionController alloc] init];
    selectionController.units = arr;
    selectionController.loginCompleteBlock = self.loginCompleteBlock;
    [self.navigationController pushViewController:selectionController animated:YES];
}

- (void)endEditing
{
    [userNameField resignFirstResponder];
    [pwdField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == userNameField) {
        [pwdField becomeFirstResponder];
    }
    else {
        [self login:nil];
    }
    return YES;
}

- (IBAction)call:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:4006565456"]];
}

#pragma mark keyboard event
- (void)handleKeyboardDidShow:(NSNotification*)paramNotification
{
    //获取键盘高度
    NSValue *keyboardRectAsObject=[[paramNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect;
    [keyboardRectAsObject getValue:&keyboardRect];
    float offset = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(loginButton.frame);
    float constraint = CGRectGetHeight(keyboardRect) +2 - offset;
    [UIView animateWithDuration:0.2 animations:^{
        bottomConstraint.constant = constraint;
        topConstraint.constant = -constraint;
        [self.view layoutIfNeeded];
    }];
}

- (void)handleKeyboardDidHidden
{
    bottomConstraint.constant = 0;
    topConstraint.constant = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
@end
