//
//  CategoryCellData.m
//  LongYuanYueDu
//
//  Created by 龙源 on 13-8-5.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import "LYCategoryCellData.h"

@implementation LYCategoryCellData

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.categoryID forKey:@"categoryID"];
    [aCoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder: (NSCoder *)coder {
    if (self = [super init]) {
        self.categoryID = [coder decodeObjectForKey:@"categoryID"];
        self.name = [coder decodeObjectForKey:@"name"];
    }
    return self;
}

@end
