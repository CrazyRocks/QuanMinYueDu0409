//
//  GLCoreDataDelegate.m
//  DragonSource
//
//  Created by  on 11-11-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WYCoreDataDelegate.h"


@interface WYCoreDataDelegate()

@end


@implementation WYCoreDataDelegate

static WYCoreDataDelegate *sharedInstance = nil;

@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (id) init
{
    self = [super init];
    if(self)
    {

    }
    return(self);
}

- (void) initializeSharedInstance
{
    self.parentMOC = [[NSManagedObjectContext alloc]
                      initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.parentMOC setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    
}

+ (WYCoreDataDelegate *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WYCoreDataDelegate alloc] init];
        [sharedInstance initializeSharedInstance];
    });
    return sharedInstance;
}

- (id)generateManagedObject:(Class)className
{
    return [NSEntityDescription insertNewObjectForEntityForName:
            [NSString stringWithFormat:@"%@", className]
                                         inManagedObjectContext:self.parentMOC];
}

#pragma mark - Core Data stack

- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    // 在framework模式中，这里要手动改成对应的版本
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"wy" withExtension:@"momd"];
    if (!modelURL) {
        modelURL = [[NSBundle mainBundle] URLForResource:@"wy" withExtension:@"mom"];
    }
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"wy.sqlite"];

    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    NSError *error = nil;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                              NSInferMappingModelAutomaticallyOption:@YES};
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        [self fixUpgradeBug];
    }
    return __persistentStoreCoordinator;
}


//由于数据库版本不一致会导致app升级后无法使用，
//需要先删除已经存在的数据库文件，重新生成。
- (void)fixUpgradeBug
{
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"wy.sqlite"];
    
    //先删除已经存在的数据库
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:storePath])
        [fileManager removeItemAtPath:storePath error:Nil];
    
    
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    NSError *error = nil;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                              NSInferMappingModelAutomaticallyOption:@YES};
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        NSLog(@"persistentStoreCoordinator error %@, %@", error, [error userInfo]);
        abort();
    }
}
#pragma mark - Application's Documents directory


- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSArray *)getCoreDataList:(NSString *)className
{
  return [self getCoreDataList:className
                   byPredicate:nil
                          sort:nil
                    fetchLimit:0
                   fetchOffset:0
                       context:self.parentMOC];
}

- (NSArray *)getCoreDataList:(NSString *)className byPredicate:(NSPredicate *)predicate sort:(NSArray *)aSort
{
    return [self getCoreDataList:className
                     byPredicate:predicate
                            sort:aSort
                      fetchLimit:0
                     fetchOffset:0
                         context:self.parentMOC];
}

-(NSArray *)getCoreDataList:(NSString *)className
                byPredicate:(NSPredicate *)predicate
                       sort:(NSArray *)aSort
                 fetchLimit:(uint)limit
                fetchOffset:(uint)offset
{
    return [self getCoreDataList:className byPredicate:predicate sort:aSort fetchLimit:limit fetchOffset:offset context:self.parentMOC];
}

-(NSArray *)getCoreDataList:(NSString *)className
                byPredicate:(NSPredicate *)predicate
                       sort:(NSArray *)aSort
                 fetchLimit:(uint)limit
                fetchOffset:(uint)offset
                    context:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:context];
	[request setEntity:entity];
    [request setPredicate:predicate];
    [request setSortDescriptors:aSort];
    [request setFetchLimit:limit];
    [request setFetchOffset:offset];
    
	NSError *error = nil;
	NSArray *fetchResults;
    fetchResults = [context executeFetchRequest:request error:&error];
    
    if(error) return nil;
    
    return fetchResults;
}

- (void)deleteObjects:(NSString *)className
{
    [self deleteObjects:className predicate:nil sort:nil fetchOffset:0 fetchLimit:0];
}

-(void)deleteObjects:(NSString *)className
           predicate:(NSPredicate *)predicate
                sort:(NSArray *)aSort
         fetchOffset:(uint)offset
          fetchLimit:(uint)limit
{
    NSArray *arr = [self getCoreDataList:className byPredicate:predicate sort:aSort fetchLimit:limit fetchOffset:offset context:self.parentMOC];
    
    if(arr == nil || arr.count == 0) return;
    
    for (id item in arr) {
        if (item)
            [self.parentMOC deleteObject:item];
    }
    [self.parentMOC save:nil];
}

- (void)saveParentMOC
{
    [self.parentMOC performBlock:^{
        [self.parentMOC save:nil];
    }];
}

@end
