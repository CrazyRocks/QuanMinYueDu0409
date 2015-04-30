//
//  WYArticleCategory.h
//  PublicLibrary
//
//  Created by grenlight on 14/8/7.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WYArticleCategory : NSManagedObject

@property (nonatomic, retain) NSString * catID;
@property (nonatomic, retain) NSString * catName;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSNumber * sort;

@end
