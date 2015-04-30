//
//  FunctionModule.h
//  LYService
//
//  Created by grenlight on 12/25/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FunctionModule : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * funcName;
@property (nonatomic, retain) NSString * iconName;
@property (nonatomic, retain) NSNumber * sort;

@end
