//
//  GLCoreDataDelegate.h
//  DragonSource
//
//  Created by  on 11-11-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WYCoreDataDelegate : NSObject

@property (strong, nonatomic) NSManagedObjectContext *parentMOC;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;

+(WYCoreDataDelegate *) sharedInstance;

- (void)saveParentMOC;

- (id)generateManagedObject:(Class)className;

-(NSArray *)getCoreDataList:(NSString *)className;

-(NSArray *)getCoreDataList:(NSString *)className
                byPredicate:(NSPredicate *)predicate
                       sort:(NSArray *)aSort;

-(NSArray *)getCoreDataList:(NSString *)className
                byPredicate:(NSPredicate *)predicate
                       sort:(NSArray *)aSort
                 fetchLimit:(uint)limit
                fetchOffset:(uint)offset;

-(NSArray *)getCoreDataList:(NSString *)className
                byPredicate:(NSPredicate *)predicate
                       sort:(NSArray *)aSort
                 fetchLimit:(uint)limit
                fetchOffset:(uint)offset
                    context:(NSManagedObjectContext *)context;

- (void)deleteObjects:(NSString *)className;

- (void)deleteObjects:(NSString *)className
            predicate:(NSPredicate *)predicate
                 sort:(NSArray *)aSort
          fetchOffset:(uint)offset
           fetchLimit:(uint)limit;

@end
