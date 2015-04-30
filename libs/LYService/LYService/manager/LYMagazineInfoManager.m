//
//  LYMagazineInfoManager.m
//  LYService
//
//  Created by grenlight on 15/1/8.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "LYMagazineInfoManager.h"
#import "LYUtilityManager.h"

@implementation LYMagazineInfoManager

- (void)getIssueList:(NSInteger)pageIndex
         completion:(GLHttpRequstResult)completionBlock
              fault:(GLHttpRequstFault)faultBlock
{
    if (pageIndex == 1) {
        [self getInfo:completionBlock fault:faultBlock];
    }
    else {
        [self reqestIssueList:pageIndex completion:completionBlock fault:faultBlock];
    }
}

- (void)getInfo:(GLHttpRequstResult)completionBlock
          fault:(GLHttpRequstFault)faultBlock
{
    NSDictionary *params = @{@"magazineguid":self.magazineInfo.magGUID};
    __weak typeof (self) weakSelf = self;
    [CommonNetworkingManager GET:MAGAZINE_INFO_API parameters:params
                      completeBlock:^(NSDictionary *result) {
                          NSDictionary *mag = result[@"Data"];
                          weakSelf.magazineInfo.summary = [LYUtilityManager stringByTrimmingAllSpaces:mag[@"Note"]];
                          weakSelf.magazineInfo.cycle = mag[@"Cycle"];
                          weakSelf.magazineInfo.issn = mag[@"ISSN"];
                          [weakSelf getYearList:completionBlock fault:faultBlock];
                      } faultBlock:^(NSString *msg) {
                          faultBlock(msg);
                      }];
}

- (void)getYearList:(GLHttpRequstResult)completionBlock
              fault:(GLHttpRequstFault)faultBlock
{
    NSDictionary *params = @{@"magazineguid":self.magazineInfo.magGUID,
                             @"magazinetype":@(2)};
    __weak typeof (self) weakSelf = self;
    [CommonNetworkingManager GET:MAGAZINE_YEAR_LIST_API parameters:params
                   completeBlock:^(NSDictionary *result) {
                       weakSelf.yearList = result[@"Data"];
                       [weakSelf reqestIssueList:1 completion:completionBlock fault:faultBlock];
                   } faultBlock:^(NSString *msg) {
                       faultBlock(msg);
                   }];
}

- (void)reqestIssueList:(NSInteger)pageIndex
          completion:(GLHttpRequstResult)completionBlock
               fault:(GLHttpRequstFault)faultBlock
{
    NSDictionary *params = @{@"magazineguid":self.magazineInfo.magGUID,
                             @"magazinetype":@(2),
                             @"year":self.yearList[pageIndex-1]};
    [CommonNetworkingManager GET:MAGAZINE_ISSUE_LIST_API parameters:params
                   completeBlock:^(NSDictionary *result) {
                       NSArray *arr = result[@"Data"];
                       NSMutableArray *newList = [[NSMutableArray alloc] init];
                       for (NSDictionary *info in arr) {
                           LYMagazineTableCellData *cellData = [LYMagazineManager parseMagazineTableCellData:info];
                           cellData.magName = [NSString stringWithFormat:@"%@年第%@期",cellData.year, cellData.issue];
                           [newList addObject:cellData];
                       }
                       completionBlock(newList);
                       
                   } faultBlock:^(NSString *msg) {
                       faultBlock(msg);
                   }];
}

@end
