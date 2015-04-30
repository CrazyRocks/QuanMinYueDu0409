//
//  Catelogue.h
//  LYBookStore
//
//  Created by grenlight on 14/7/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Catalogue : NSManagedObject
{
   float _cellHeight;
}
@property (nonatomic, retain) NSString * bookID;
@property (nonatomic, retain) NSNumber * children;
@property (nonatomic, retain) NSNumber * cID;
@property (nonatomic, retain) NSString * cName;
@property (nonatomic, retain) NSNumber * depth;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * isAlbum;
@property (nonatomic, retain) NSNumber * navIndex;
@property (nonatomic, retain) NSDictionary * pageCounts;
@property (nonatomic, retain) NSDictionary * startPages;

- (float)cellHeight:(float)width;

@end
