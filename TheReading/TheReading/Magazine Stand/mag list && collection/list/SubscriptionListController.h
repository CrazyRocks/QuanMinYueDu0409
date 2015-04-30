//
//  SubscriptionListController.h
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-11.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@interface SubscriptionListController : OWCommonTableViewController
{
    IBOutlet UILabel *messageLB;
}

- (void)requesLocalData;

- (void)requestDataSource:(BOOL)isFetchLatest;

@end
