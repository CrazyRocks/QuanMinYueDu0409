//
//  LYArticleCategory.h
//  LYService
//
//  Created by grenlight on 12/25/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LYArticleCategory : NSManagedObject

@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) NSString * fillColor;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) NSString * strokeColor;

@end
