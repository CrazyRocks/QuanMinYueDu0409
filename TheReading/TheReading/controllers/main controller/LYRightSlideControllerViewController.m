//
//  LYRightSlideControllerViewController.m
//  TheReading
//
//  Created by grenlight on 12/6/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import "LYRightSlideControllerViewController.h"
#import "MainMenuCell.h"
#import "SettingViewController.h"
#import "WYContentCanvasController.h"
#import <SDWebImage/UIImageView+WebCache.h> 
#import <LYService/LYAccountManager.h> 
#import "WYRootController_iPad.h"

@interface LYRightSlideControllerViewController ()

@end

@implementation LYRightSlideControllerViewController

- (void)awakeFromNib
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (isPad) {
        bgLeftConstraint.constant = appWidth-255;
        self.view.backgroundColor = [UIColor clearColor];
        _tableView.backgroundColor = [OWColor colorWithHexString:@"#22000000"];
    }
    else {
        self.view.backgroundColor = [UIColor grayColor];
        _tableView.backgroundColor = [UIColor clearColor];
    }
    headerView.backgroundColor = [UIColor clearColor];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:LOGIN_SUCCESSED object:nil];
    
    [self updateUI];
}

- (void)updateUI
{
    if (![self isViewLoaded]) {
        return;
    }
    [headerBgImageView sd_setImageWithURL:[NSURL URLWithString:[LYAccountManager getValueByKey:ACCOUNT_HEADER_BG]]];
    [logoImageView sd_setImageWithURL:[NSURL URLWithString:[LYAccountManager getValueByKey:LOGO_URL]]];
    unitNameLB.text = [LYAccountManager getValueByKey:UNIT_NAME];
    displayNameLB.text = [LYAccountManager getValueByKey:DISPLAY_NAME];
    cellPhoneLB.text = [LYAccountManager getValueByKey:CELL_PHONE];
}

- (Class)cellClass
{
    return [MainMenuCell class];
}

- (void)configCell:(MainMenuCell *)cell data:(LYMenuData *)item indexPath:(NSIndexPath *)indexPath
{
    cell.needRenderForiPad = NO;
    [cell setContent:item];
}

- (void)excuteRequest
{
    [statusManageView stopRequest];

    NSArray *arr = @[@{@"MenuValue":@"favorite:", @"MenuName":@"收藏"},
                     @{@"MenuValue":@"offline:", @"MenuName":@"离线书架"},
                     @{@"MenuValue":@"setting:", @"MenuName":@"设置"}];
    NSMutableArray *list = [NSMutableArray new];
    for (NSInteger i=0; i<arr.count; i++) {
        LYMenuData *md = [MTLJSONAdapter modelOfClass:[LYMenuData class] fromJSONDictionary:arr[i] error:nil];
        [list addObject:md];
    }
    
    dataSource = [[OWTableViewDataSource alloc] initWithItems:list configureCellBlock:cellConfigBlock];
    _tableView.dataSource = dataSource;
    _tableView.delegate = self;
    _tableView.tableHeaderView = headerView;
    [_tableView reloadData];
}

#pragma mark table delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self.contentCanvasController intoFavoriteList];
            break;
        
        case 1:
            [self.contentCanvasController intoOffline];
            break;
            
        default:
            [self intoSetting:nil];
            break;
    }
    if (isPad) {
        WYRootController_iPad *padController = (WYRootController_iPad *)self.parentViewController;
        if (padController) {
            [padController performSelector:@selector(intoAccountView)];
        }
    }
}

- (void)intoSetting:(id)sender
{
    [self presentViewController:[[SettingViewController alloc] init] animated:YES completion:nil];
}

- (IBAction)blanckClick:(id)sender {
    if (isPad) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view.center = CGPointMake(appWidth + 255/2.0f, appHeight/2.0f);
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    }
}

@end
