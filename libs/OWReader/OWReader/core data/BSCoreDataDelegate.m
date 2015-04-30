//
//  GLCoreDataDelegate.m
//  DragonSource
//
//  Created by  on 11-11-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSCoreDataDelegate.h"
#import "BSConfig.h"

@interface BSCoreDataDelegate()

@end


@implementation BSCoreDataDelegate

static BSCoreDataDelegate *sharedInstance = nil;

@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (id)init
{
    self = [super init];
    
    if(self != nil){
        
        
       
    }
    return(self);
}

- (void) initializeSharedInstance
{
    self.parentMOC = [[NSManagedObjectContext alloc]
                      initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.parentMOC setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    
}

+ (BSCoreDataDelegate *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance initializeSharedInstance];
    });
    return(sharedInstance);
}


- (void)saveContext
{
   [self.parentMOC performBlock:^{
       [self.parentMOC save:Nil];
   }];
}

#pragma mark - Core Data stack

- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    // 在framework模式中，这里要手动改成对应的版本
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"LogicBook" withExtension:@"momd"];
    if (!modelURL) {
        modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"LogicBook" withExtension:@"mom"];
    }
//    NSLog(@"book_modelURL:%@",modelURL.absoluteString);

    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"LogicBook.sqlite"];

    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    //设置core data 自动数据迁移选项。
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
    {
        NSLog(@"persistentStoreCoordinator error %@, %@", error, [error userInfo]);
        abort();
    }

    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)cacheDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

-(NSArray *)getCoreDataList:(NSString *)className byFetchLimit:(uint)limit predicate:(NSPredicate *)predicate
{
    
    return [self getCoreDataList:className byContext:self.parentMOC
                      fetchLimit:limit predicate:predicate];
}

-(NSArray *)getCoreDataList:(NSString *)className byContext:(NSManagedObjectContext *)context fetchLimit:(uint)limit predicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:context];
	[request setEntity:entity];
    
    if(limit > 0)  [request setFetchLimit:limit];
    
    if(predicate) [request setPredicate:predicate];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSArray *mutableFetchResults = [context executeFetchRequest:request error:&error];
	
    return mutableFetchResults;
}

-(NSArray *)getCoreDataList:(NSString *)className
                       byPredicate:(NSPredicate *)predicate
                              sort:(NSArray *)aSort
{
    return [self getCoreDataList:className byContext:self.parentMOC
                       predicate:predicate sort:aSort];
}

-(NSArray *)getCoreDataList:(NSString *)className
                         byContext:(NSManagedObjectContext *)context
                         predicate:(NSPredicate *)predicate
                              sort:(NSArray *)aSort
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:context];
	[request setEntity:entity];
    
    if(predicate) [request setPredicate:predicate];
    [request setSortDescriptors:aSort];
    
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSArray *mutableFetchResults = [context executeFetchRequest:request error:&error];
    
    if(error) return nil;
   
    return mutableFetchResults;
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
    NSArray *arr = [self getCoreDataList:className byPredicate:predicate sort:aSort];
    
    if(arr == nil || arr.count == 0) return;
    
    for (id item in arr) {
        if (item)
            [self.parentMOC deleteObject:item];
    }
    [self.parentMOC save:nil];
}

@end
