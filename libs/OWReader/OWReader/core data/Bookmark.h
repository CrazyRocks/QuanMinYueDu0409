//
//  Bookmark.h
//  LYBookStore
//
//  Created by grenlight on 14/7/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bookmark : NSManagedObject

@property (nonatomic, retain) NSDate * addDate;
@property (nonatomic, retain) NSString * bookID;
@property (nonatomic, retain) NSNumber * catIndex;//章节索引
@property (nonatomic, retain) NSString * catName;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSNumber * bookmarkid;

@end
