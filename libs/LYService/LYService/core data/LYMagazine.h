//
//  LYMagazine.h
//  LYService
//
//  Created by grenlight on 12/25/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LYMagazine : NSManagedObject

@property (nonatomic, retain) NSDate * addDate;
@property (nonatomic, retain) NSString * cover;
@property (nonatomic, retain) NSString * downloadingProgress;
@property (nonatomic, retain) NSNumber * isDownloaded;
@property (nonatomic, retain) NSNumber * issue;
@property (nonatomic, retain) NSString * magGUID;
@property (nonatomic, retain) NSString * magName;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSNumber * year;

@end
