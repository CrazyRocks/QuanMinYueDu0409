//
//  LYMagazineInfoManager.h
//  LYService
//
//  Created by grenlight on 15/1/8.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYMagazineManager.h"

@interface LYMagazineInfoManager : NSObject


@property (nonatomic, strong) LYMagazineTableCellData *magazineInfo;
//所有年份列表
@property (nonatomic, strong) NSArray *yearList;


-(void)getIssueList:(NSInteger)pageIndex
         completion:(GLHttpRequstResult)completionBlock
              fault:(GLHttpRequstFault)faultBlock;

@end
