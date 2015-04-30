//
//  FunctionModuleManager.m
//  PublicLibrary
//
//  Created by 龙源 on 13-11-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "LYFunctionModuleManager.h"
#import "LYFunctionModule.h"

@implementation LYFunctionModuleManager

+ (LYFunctionModuleManager *)sharedInstance
{
    static LYFunctionModuleManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYFunctionModuleManager alloc] init];
        [instance setup];
    });
    return instance;
}

- (void)setup
{
    
}

- (NSArray *)getFunctionModules
{
    NSArray *fms = [self getFMFromLocal];
    
    if (!fms || fms.count == 0) {
        [self createData];
        fms = [self getFMFromLocal];
    }
    
    return fms;
}

- (NSArray *)getFMFromLocal
{
    __block NSArray *fms;
    [cdd.parentMOC performBlockAndWait:^{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

        fms = [cdd getCoreDataList:@"LYFunctionModule" byPredicate:nil
                              sort:sortDescriptors
                        fetchLimit:0 fetchOffset:0
                           context:cdd.parentMOC];
    }];
    return fms;
}

- (void)createData
{
//    NSArray *funcNames = @[@"图书",@"期刊",@"精选文章",@"新闻综述",
//                         @"读者",@"创业必读",@"每日故事",@"每日笑话",
//                         @"文学欣赏",@"旅游",@"军事迷",@"健康必读",
//                         @"党员学习",@"图书馆动态",@"文库搜索",@"收藏"];
//    
//    NSArray *funcCodes = @[@"book", @"magazine", @"0002", @"0019",
//                           @"0018", @"0020", @"0021", @"0022",
//                           @"0011", @"0009", @"0008", @"0006",
//                           @"0023", @"0024", @"search", @"favorite"];
    
    NSArray *funcNames = self.moduleNames();
    NSArray *funcCodes = self.moduleCodes();
    NSArray *funcIcons = self.moduleIcons();
    
    [cdd.parentMOC performBlockAndWait:^{
        for (NSInteger i=0; i< funcNames.count; i++) {
            LYFunctionModule *fm = [NSEntityDescription insertNewObjectForEntityForName:@"LYFunctionModule"
                                                               inManagedObjectContext:cdd.parentMOC];
            fm.funcName = funcNames[i];
            fm.sort = [NSNumber numberWithInteger:i];
            fm.code = funcCodes[i];
            fm.iconName = funcIcons[i];
        }
        [cdd.parentMOC save:nil];
    }];
}

- (void)updateModulesSequence:(NSArray *)modules
{
    [cdd.parentMOC performBlock:^{
        for (NSInteger i = 0; i < modules.count; i++) {
            LYFunctionModule *fm = modules[i];
            fm.sort = [NSNumber numberWithInteger:i];
        }
        [cdd.parentMOC save:nil];
    }];
}

@end
