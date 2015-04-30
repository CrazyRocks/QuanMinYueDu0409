//
//  MagazineSearchCellData.h
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-23.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYMagazineTableCellData.h"

@interface LYMagazineSearchCellData : LYMagazineTableCellData

@property (nonatomic, retain) NSString * sortID;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSString * summary;

@property (nonatomic, assign) CGRect    textRect;

//缓存列表项高度
- (float)cellHeight;

@end
