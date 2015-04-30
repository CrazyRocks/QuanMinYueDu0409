//
//  MyBook.h
//  LYBookStore
//
//  Created by grenlight on 14/8/14.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MyBook : NSManagedObject

@property (nonatomic, retain) NSDate * accessDate;
@property (nonatomic, retain) NSDate * addDate;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * bookID;
@property (nonatomic, retain) NSString * bookName;
@property (nonatomic, retain) NSString * bookName_EN;
@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) NSString * categoryName;
@property (nonatomic, retain) NSString * cycle;
@property (nonatomic, retain) NSNumber * downloadingProgress;
@property (nonatomic, retain) NSNumber * downloadingSortID;
@property (nonatomic, retain) NSString * downloadURL;
@property (nonatomic, retain) NSNumber * expiringDate;
@property (nonatomic, retain) NSString * expiringMessage;
@property (nonatomic, retain) NSString * introduce;
@property (nonatomic, retain) NSNumber * isBook;
@property (nonatomic, retain) NSNumber * isDownloaded;
@property (nonatomic, retain) NSNumber * isInCloud;
@property (nonatomic, retain) NSNumber * isPageParsed;
@property (nonatomic, retain) NSString * issueString;
@property (nonatomic, retain) NSNumber * lastReadCID;
@property (nonatomic, retain) NSNumber * lastReadPosition;
@property (nonatomic, retain) id pageCounts;
@property (nonatomic, retain) NSString * publishName;
@property (nonatomic, retain) NSNumber * readProgress;
@property (nonatomic, retain) NSString * smallCover;
@property (nonatomic, retain) NSNumber * sortID;
@property (nonatomic, retain) NSString * unitDomain;
@property (nonatomic, retain) NSString * unitName;
@property (nonatomic, retain) NSNumber * usedFontSizeScale;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * bookJRID;

@property (nonatomic, retain) NSString * bookType;
@property (nonatomic, retain) NSString * opsPath;
@property (nonatomic, retain) NSString * catPath;

@end
