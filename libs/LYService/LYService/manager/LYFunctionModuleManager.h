//
//  FunctionModuleManager.h
//  PublicLibrary
//
//  Created by 龙源 on 13-11-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWBasicHTTPRequest.h"

typedef NSArray *(^ModuleInfos)() ;

@interface LYFunctionModuleManager : OWBasicHTTPRequest

//模块名
@property (nonatomic, copy) ModuleInfos moduleNames;
@property (nonatomic, copy) ModuleInfos moduleCodes;
@property (nonatomic, copy) ModuleInfos moduleIcons;

+ (LYFunctionModuleManager *)sharedInstance;

- (void)createData;

- (NSArray *)getFunctionModules;
- (void)updateModulesSequence:(NSArray *)modules;

@end
