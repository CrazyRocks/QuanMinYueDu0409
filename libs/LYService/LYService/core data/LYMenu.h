//
//  LYMenu.h
//  LYService
//
//  Created by grenlight on 12/25/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LYMenu : NSManagedObject

@property (nonatomic, retain) NSString * childs;
@property (nonatomic, retain) NSString * descript;
@property (nonatomic, retain) NSString * imageDisplayMode;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSString * menuCode;
@property (nonatomic, retain) NSString * menuName;
@property (nonatomic, retain) NSString * menuValue;
@property (nonatomic, retain) NSString * openMode;
@property (nonatomic, retain) NSString * orderNumber;

@end
