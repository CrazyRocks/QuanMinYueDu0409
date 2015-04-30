//
//  LYSettingViewCell.m
//  LYBookStore
//
//  Created by grenlight on 14/8/28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYSettingViewCell.h"
#import <LYService/LYUpdateManager.h>

@implementation LYSettingViewCell

@synthesize nextView, titleLable;
@synthesize cellBlock, indexPath;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    UIView *selectedBg = [[UIView alloc] initWithFrame:self.bounds];
    selectedBg.backgroundColor = [OWColor colorWithHexString:@"#0c000000"];
    self.selectedBackgroundView = selectedBg;
    
    [titleLable setTextColor:[OWColor colorWithHexString:@"#333333"]];
    [titleLable setHighlightedTextColor:[OWColor colorWithHexString:@"#63b8e5"]];
}

- (void)renderStyleByTable:(UITableView *)tableView indexPath:(NSIndexPath *)_indexPath
{
    [_indicatorView stopAnimating];
    [_indicatorView setHidden:YES];
    self.messageLB.hidden = YES;
    
    indexPath = _indexPath;
    
    if (_indexPath.row == 1) {
//        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
//        titleLable.text = [NSString stringWithFormat:@"当前版本：%@", version];
        
    }
    
}

- (void)checkUpdate
{
    [_indicatorView setHidden:NO];
    _indicatorView.color = [UIColor blackColor];
    _indicatorView.steps = 12;
    [_indicatorView startAnimating];
    self.messageLB.hidden = NO;
    self.messageLB.text = @"正在检测更新";
    self.messageLB.textAlignment = NSTextAlignmentLeft;
    nextView.hidden = YES;
    
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"ServerConfig" ofType:@"strings"];
    NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:configPath];
    __weak typeof (self) weakSelf = self;
    [[LYUpdateManager sharedInstance] checkUpdate:d[@"AppID"] complete:^{
        [weakSelf showMessage:@"检测到有更新"];
    } fault:^{
        [weakSelf showMessage:@"已经是最新的版本了"];
    }];
}

- (void)showMessage:(NSString *)msg
{
    self.messageLB.hidden = NO;
    self.messageLB.text = msg;
    self.messageLB.textAlignment = NSTextAlignmentRight;
    [self.indicatorView stopAnimating];
    [self.indicatorView setHidden:YES];
}
@end
