//
//  LYFavorite.h
//  LYService
//
//  Created by grenlight on 12/25/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LYFavorite : NSManagedObject

@property (nonatomic, retain) NSDate * addDate;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * contentDownloaded;
@property (nonatomic, retain) NSString * favoriteID;
@property (nonatomic, retain) NSNumber * kind;
@property (nonatomic, retain) NSNumber * isAlreadySync;
@property (nonatomic, retain) NSString * magazineIconURL;
@property (nonatomic, retain) NSString * magGUID;
@property (nonatomic, retain) NSString * magIssue;
@property (nonatomic, retain) NSString * magName;
@property (nonatomic, retain) NSString * magYear;
@property (nonatomic, retain) NSDate * publishDate;
@property (nonatomic, retain) NSString * publishDateFormatString;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleID;
@property (nonatomic, retain) NSString * userName;

@end
