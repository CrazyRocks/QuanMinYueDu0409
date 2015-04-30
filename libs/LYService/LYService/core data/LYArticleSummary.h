//
//  LYArticleSummary.h
//  LYService
//
//  Created by grenlight on 12/25/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LYArticleSummary : NSManagedObject

@property (nonatomic, retain) NSString * articleID;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) NSString * magazineGUID;
@property (nonatomic, retain) NSString * magazineIconURL;
@property (nonatomic, retain) NSString * magazineID;
@property (nonatomic, retain) NSString * magazineIssue;
@property (nonatomic, retain) NSString * magazineName;
@property (nonatomic, retain) NSString * magazineYear;
@property (nonatomic, retain) NSDate * publishDate;
@property (nonatomic, retain) NSString * publishDateFormatString;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * title;

@end
