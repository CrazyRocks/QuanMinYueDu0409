//
//  GLCoreDataDelegate.h
//  DragonSource
//
//  Created by  on 11-11-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Catalogue.h"
#import "Bookmark.h"
#import "BookDigest.h"


@interface BSCoreDataDelegate : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSManagedObjectContext *parentMOC;

- (void)saveContext;
- (NSString *)applicationDocumentsDirectory;
- (NSString *)cacheDocumentsDirectory;

+ (BSCoreDataDelegate *)sharedInstance;


-(NSArray *)getCoreDataList:(NSString *)className byFetchLimit:(uint)limit predicate:(NSPredicate *)predicate;
-(NSArray *)getCoreDataList:(NSString *)className byContext:(NSManagedObjectContext *)context fetchLimit:(uint)limit predicate:(NSPredicate *)predicate;

-(NSArray *)getCoreDataList:(NSString *)className byPredicate:(NSPredicate *)predicate sort:(NSArray *)aSort;

-(NSArray *)getCoreDataList:(NSString *)className byContext:(NSManagedObjectContext *)context predicate:(NSPredicate *)predicate sort:(NSArray *)aSort;

- (void)deleteObjects:(NSString *)className;

- (void)deleteObjects:(NSString *)className
            predicate:(NSPredicate *)predicate
                 sort:(NSArray *)aSort
          fetchOffset:(uint)offset
           fetchLimit:(uint)limit;

@end
