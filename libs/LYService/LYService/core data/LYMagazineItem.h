//
//  LYMagazineItem.h
//  LYService
//
//  Created by grenlight on 12/25/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LYMagazineItem : NSManagedObject

@property (nonatomic, retain) NSDate * addDate;
@property (nonatomic, retain) NSString * cover;
@property (nonatomic, retain) NSString * issue;
@property (nonatomic, retain) NSNumber * isUserFocused;
@property (nonatomic, retain) NSNumber * isUserSubscription;
@property (nonatomic, retain) NSString * magGUID;
@property (nonatomic, retain) NSString * magIconURL;
@property (nonatomic, retain) NSString * magName;
@property (nonatomic, retain) NSString * sortID;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * year;

@end
