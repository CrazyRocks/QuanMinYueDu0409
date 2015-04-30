//
//  FunctionModule.h
//  PublicLibrary
//
//  Created by 龙源 on 13-11-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LYFunctionModule : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * funcName;
@property (nonatomic, retain) NSString * iconName;
@property (nonatomic, retain) NSNumber * sort;

@end
