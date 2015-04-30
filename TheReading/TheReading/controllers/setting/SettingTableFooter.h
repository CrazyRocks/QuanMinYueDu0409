//
//  SettingTableFooter.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-11-23.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STFDelegate;

@interface SettingTableFooter : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, assign) id<STFDelegate> delegate;

-(IBAction)loginOut:(id)sender;

@end

@protocol STFDelegate <NSObject>

@required
- (void)settingTableFooterTapped;

@end
