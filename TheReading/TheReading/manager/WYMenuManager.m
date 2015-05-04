//
//  WYCategoryManager.m
//  PublicLibrary
//
//  Created by grenlight on 14-1-22.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "WYMenuManager.h"
#import "WYCoreDataDelegate.h"
#import "WYArticleCategory.h"
#import <LYService/CommonNetworkingManager.h> 
#import <LYAccountManager.h>

@implementation WYMenuManager

- (id)init
{
    if (self = [super init]) {
        wydd = [WYCoreDataDelegate sharedInstance];
    }
    return self;
}

- (void)dealloc
{
    [requestOperation cancel];
    requestOperation = nil;
}

- (void)getCategories:(LYMenuData *)menu completion:(GLParamBlock)completion fault:(GLHttpRequstFault)fault
{
    __weak WYMenuManager *weakSelf = self;
    
    requestOperation = [[LYCategoryManager sharedInstance] getCategoriesFromServer:menu
                                                                        completion:^(NSArray *result) {
        NSMutableArray *newList = [NSMutableArray new];
        for (LYCategoryCellData *cat in result) {
            OWSubNavigationItem *item = [[OWSubNavigationItem alloc] init];
            item.catID = cat.categoryID;
            item.catName  = cat.name;
            [newList addObject:item];
        }
        [weakSelf generateFavorite:newList];
        if (completion) {
            completion(newList);
        }
        
    } failedCallBack:^(NSString *msg) {
        if (fault)
            fault(msg);
    }];
}

- (void)generateFavorite:(NSArray *)result
{
    NSString *username = [LYAccountManager getUserName];
    NSString *localFav = [NSString stringWithFormat:@"%@_%@", kFAVCATSBYNAME, username];
    NSArray *fav = [[NSUserDefaults standardUserDefaults]objectForKey:localFav];
    
    if (self.favoriteCats) {
        [self.favoriteCats removeAllObjects];
        [self.dislikeCats removeAllObjects];
    }
    else {
        self.favoriteCats = [NSMutableArray new];
        self.dislikeCats = [NSMutableArray new];
    }
    //NSLog(@"\r\n count:%ld", fav.count);
    if (fav.count != 0) {
        for (NSInteger i=0; i<result.count; i++) {
            BOOL isFound = NO;
            OWSubNavigationItem *cat = result[i];
            for (int j = 0; j < fav.count; j++) {
                OWSubNavigationItem *catLocal = [NSKeyedUnarchiver unarchiveObjectWithData:fav[j]];
                //NSLog(@"\r\n name:%@,catname:%@", catLocal.catID, cat.catID);
                if ([catLocal.catID isEqual:cat.catID]) {
                    [self.favoriteCats addObject:cat];
                    isFound = YES;
                } else {
                    continue;
                }
                //[self.dislikeCats addObject:cat];
            }
            if (isFound == NO) {
                [self.dislikeCats addObject:cat];
            }
        }
    } else {
        NSInteger favCount = 5;
        if (isPad) {
            favCount = 9;
        }
        for (NSInteger i=0; i<result.count; i++) {
            LYCategoryCellData *cat = result[i];
            if (i<favCount) {
                [self.favoriteCats addObject:cat];
            }
            else {
                [self.dislikeCats addObject:cat];
            }
        }
    }
}

- (void)saveCategory:(LYCategoryCellData *)data  isFavorite:(BOOL)favorite sort:(int)sort
{
    [wydd.parentMOC performBlockAndWait:^{
        WYArticleCategory *category = [wydd generateManagedObject:[WYArticleCategory class]];
        category.catID = data.categoryID;
        category.catName = data.name;
        category.isFavorite = @(favorite) ;
        category.sort = @(sort);
        
        [wydd.parentMOC save:nil];
    }];
}

- (void)updateSorting
{
//    [wydd.parentMOC performBlock:^{
//
//        int i = 0;
//        for (WYArticleCategory *cat in self.favoriteCats) {
//            cat.isFavorite = @YES;
//            cat.sort = @(i);
//            i++;
//        }
//        
//        i = 0;
//        for (WYArticleCategory *cat in self.dislikeCats) {
//            cat.isFavorite = @NO;
//            cat.sort = @(i);
//            i++;
//        }
//        NSError *error;
//        [wydd.parentMOC save:&error];
//        if (error) {
//            NSLog(@"category sorting error:%@",error.description);
//        }
//    }];
}


@end
