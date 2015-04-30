//
//  SettingViewController.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-30.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableCell.h"
#import "SettingTableFooter.h"
#import "PwdModifyController.h"
#import "LoginViewController.h"
#import "WYCoreDataDelegate.h"

@interface SettingViewController ()
{
    NSArray *sections ;
    NSArray *sectionData1;
    NSArray *sectionData2;
    NSArray *sectionData3;
    NSArray *sectionData4;

    UIImage *fontSelectedIcon;

    SettingTableFooter *footerView;
}
@end

@implementation SettingViewController


-(void)releaseData
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [_tableView removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!needShowNavigationBar) {
        [navBar removeFromSuperview];
        navBar = Nil;
        
        [_tableView setFrame:self.view.bounds];
    }
    else {
        [navBar setTitle:@"设置"];   
    }
    
    self.view.backgroundColor = _tableView.backgroundColor = [OWColor colorWithHex:loginBackground];
   
    sections = @[@"字号设置",@"离线设置",@"关于", @"帐号设置"];
    
    sectionData1 = @[@"字体适中",@"大字体"];
    sectionData2 = @[@"同步收藏夹",@"在WiFi状态下自动下载"];
    sectionData3 = @[@"版本"];
    sectionData4 = @[@"修改登录密码"];
    
    fontSelectedIcon = [OWImage imageWithName:@"ok"];
    
    _tableView.delegate = self;
    
    footerView = [[NSBundle mainBundle] loadNibNamed:@"SettingTableFooter" owner:self options:nil][0];
    footerView.backgroundColor = [UIColor clearColor];
    footerView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _tableView.dataSource = self;
    _tableView.tableFooterView = footerView;
    [_tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num;
    switch (section) {
        case 0:
            num = sectionData1.count;
            break;
        case 1:
            num =  sectionData2.count;
            break;
        case 2:
            num =  sectionData3.count;
            break;
        default:
            num =  sectionData4.count;
            break;

    }
    return num;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *str = sections[section];
    return str;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingTableCell *cell = [[NSBundle mainBundle]loadNibNamed:@"SettingTableCell" owner:self options:nil][0];
    NSString *lableString ;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    if(indexPath.section ==0){
        lableString = sectionData1[indexPath.row];
        [cell setImageView:nil];

        switch (indexPath.row) {
            case 0:
                if( [userDefaults floatForKey:APP_FONTSIZE]==appFontsize_normal)
                {
                    [cell setImageView:fontSelectedIcon];
                }
                break;
            case 1:
                if( [userDefaults floatForKey:APP_FONTSIZE]==appFontsize_large)
                {
                    [cell setImageView:fontSelectedIcon];
                }
                break;
        }
    }
    else if (indexPath.section ==1) {
        lableString = sectionData2[indexPath.row];
        if (indexPath.row == 0) {
            [cell setSwitchByUserDefaultKey: OFFLINE_FAVORITE];
        }
        else {
            [cell setSwitchByUserDefaultKey:AUTO_DOWNLOAD];
        }
    }
    else if (indexPath.section ==2) {
        lableString = sectionData3[indexPath.row];
        [cell showRightLable];
    }
    else {
        lableString = sectionData4[indexPath.row];
        [cell setImageView:nil];
    }
    
    [cell.customLable setText:lableString];
    return cell;
}

-(void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingTableCell *cell = (id)[aTableView cellForRowAtIndexPath:indexPath];
    
    if(indexPath.section ==0){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [cell setImageView: fontSelectedIcon];
        NSIndexPath *path ;
        SettingTableCell *otherCell;
        if(indexPath.row == 0){
            [userDefaults setFloat:appFontsize_normal forKey:APP_FONTSIZE];
            path = [NSIndexPath indexPathForRow:1 inSection:0];
        }
        else {
            [userDefaults setFloat:appFontsize_large forKey:APP_FONTSIZE];
            path = [NSIndexPath indexPathForRow:0 inSection:0];
        }
        otherCell = (id)[aTableView cellForRowAtIndexPath:path];
        [otherCell setImageView: nil];
        [userDefaults synchronize];
    }
    else if (indexPath.section == 3) {
        [self modifyPwd];
    }
}

- (void)modifyPwd
{
    PwdModifyController *modalViewController = [PwdModifyController new];
    [[OWModalViewAnimator animator] presenting:modalViewController from:self];
}

- (void)comeback:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark FooterDelegate
- (void)settingTableFooterTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [LYAccountManager logOut];
    
    UINavigationController *navController = [AppDelegate sharedInstance].navController;
    for (UIViewController *controller in navController.viewControllers) {
        if ([controller isKindOfClass:[LoginViewController class]]) {
            [navController popToViewController:controller animated:YES];
        }
    }
    
    //退出登录后，清空资讯分类
    [[WYCoreDataDelegate sharedInstance] deleteObjects:@"WYArticleCategory"];

}
@end
