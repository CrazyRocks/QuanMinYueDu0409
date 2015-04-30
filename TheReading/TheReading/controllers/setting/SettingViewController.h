//
//  SettingViewController.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-30.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "SettingTableFooter.h"

@interface SettingViewController : XibAdaptToScreenController<UITableViewDelegate,UITableViewDataSource, STFDelegate>
{
    __weak IBOutlet UITableView  *_tableView;
    
}
@end
