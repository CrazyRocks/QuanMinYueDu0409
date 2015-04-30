//
//  LYArticle.h
//  LYService
//
//  Created by grenlight on 12/25/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LYArticle : NSManagedObject

@property (nonatomic, retain) NSDate * accessTime;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * canRead;
@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) id images;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * magFormattedIssue;
@property (nonatomic, retain) NSString * magGUID;
@property (nonatomic, retain) NSString * magIcon;
@property (nonatomic, retain) NSNumber * magIssue;
@property (nonatomic, retain) NSString * magName;
@property (nonatomic, retain) NSNumber * magYear;
@property (nonatomic, retain) NSNumber * publishDate;
@property (nonatomic, retain) NSString * subTitle;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleID;
@property (nonatomic, retain) NSString * webURL;
@property (nonatomic, retain) NSString * favoriteID;

@end
