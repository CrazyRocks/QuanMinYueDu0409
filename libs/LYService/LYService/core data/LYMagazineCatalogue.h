//
//  LYMagazineCatalogue.h
//  LYService
//
//  Created by grenlight on 12/25/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LYMagazineCatalogue : NSManagedObject

@property (nonatomic, retain) NSString * column;
@property (nonatomic, retain) NSString * magGUID;
@property (nonatomic, retain) NSNumber * magIssue;
@property (nonatomic, retain) NSNumber * magYear;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleID;
@property (nonatomic, retain) NSString * userID;

@end
