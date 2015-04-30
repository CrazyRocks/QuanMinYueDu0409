//
//  MagzineInfo.h
//  LongYuanYueDu
//
//  Created by 龙源 on 13-7-17.
//  Copyright (c) 2013年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYMagazineInfo : NSObject

@property (nonatomic, strong) NSString *coverURL;
@property (nonatomic, strong) NSString *magazineName;
@property (nonatomic, strong) NSString *FormattedIssue;
@property (nonatomic, retain) NSNumber *cycle;//刊类型，如：半月刊
@property (nonatomic, retain) NSString *magazineCategory;//刊所属分类
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *issue;
@property (nonatomic, strong) NSString *magGUID;

@property (nonatomic, strong) NSString *catName;
@property (nonatomic, strong) NSString *summary;


@end
