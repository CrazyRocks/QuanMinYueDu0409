//
//  LYMagazineTableCellData.h
//  LYMagazineService
//
//  Created by grenlight on 13-12-24.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYMagazineTableCellData : NSObject

@property (nonatomic, retain) NSString * issue;
@property (nonatomic, retain) NSNumber * isUserFocused;
@property (nonatomic, retain) NSNumber * isUserSubscription;
@property (nonatomic, retain) NSString * cover;

@property (nonatomic, retain) NSString * magGUID;
@property (nonatomic, retain) NSNumber * concernID;//关注id

@property (nonatomic, retain) NSString * magIconURL;
@property (nonatomic, retain) NSString * magName;
@property (nonatomic, retain) NSString * sortID;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSDate   * addDate;

@property (nonatomic, strong) NSString *catName;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSNumber *cycle;
@property (nonatomic, strong) NSString *issn;

@end
