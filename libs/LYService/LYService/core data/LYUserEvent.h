//
//  LYUserEvent.h
//  LYService
//
//  Created by grenlight on 12/25/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LYUserEvent : NSManagedObject

@property (nonatomic, retain) NSString * cID;
@property (nonatomic, retain) NSNumber * eventType;
@property (nonatomic, retain) NSDate * operationTime;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;

@end
