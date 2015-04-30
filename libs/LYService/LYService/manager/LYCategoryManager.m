//
//  CategoryManager.m
//  LongYuan
//
//  Created by iMac001 on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LYCategoryManager.h"
#import <CoreData/CoreData.h>
#import "LYCoreDataDelegate.h"
#import "LYArticleCategory.h"
#import "LYCategoryCellData.h"
#import "LYAccountManager.h"
#import "LYUtilityManager.h"

@implementation LYCategoryManager

@synthesize categories;

+ (LYCategoryManager *)sharedInstance
{
    static LYCategoryManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYCategoryManager alloc] init];
    });
    return instance;
}

- (void)getCategoriesFromLocal:(NSString *)key
                    completion:(GLParamBlock)sCallBack
                 failedCallBack:(GLHttpRequstFault)fCallBack
{
    NSArray *cats = [self getLocalCategory:key];
    if (cats && cats.count > 0)
        [self excuteCompletionBlock:sCallBack data:cats];
    else {
       if (fCallBack)
           fCallBack(@"本地没有文章分类的缓存");
    }
}

- (NSArray *)getLocalCategory:(NSString *)key
{
   return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setLocalCategory:(NSArray *)dic byKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//从服务器端取得资讯分类数据
-(AFHTTPRequestOperation *)getCategoriesFromServer:(LYMenuData *)menu
                                        completion:(GLParamBlock)sCallBack
                failedCallBack:(GLHttpRequstFault)fCallBack
{
    __weak LYCategoryManager *weakSelf = self;

    return [self getCategoriesByKind:@"6"
                                menu:menu
                          completion:^(NSArray *result){
                              [weakSelf excuteCompletionBlock:sCallBack data:result];
                          } failedCallBack:^(NSString *message){
                              [weakSelf getCategoriesFromLocal:menu.menuName completion:sCallBack failedCallBack:fCallBack];
                          }];
}

-(AFHTTPRequestOperation *)getCategoriesByKind:(NSString *)kind
                                          menu:(LYMenuData *)menu
                                    completion:(GLParamBlock)sCallBack
                                    failedCallBack:(GLHttpRequstFault)fCallBack
{
    __weak LYCategoryManager *weakSelf = self;
    return [CommonNetworkingManager GET:LONGYUAN_CATEGORY_API parameters:@{@"kind":kind}
                          completeBlock:^(NSDictionary *result){
                              NSArray *arr = result[@"Data"];
                              NSArray *filters = menu.menuValue;
                              NSMutableArray *newArr = [NSMutableArray new];
                              if (arr && [arr isKindOfClass:[NSArray class]] && filters && filters.count > 0) {
                                  for (NSString *filter in filters) {
                                      for (NSDictionary *cat in arr) {
                                          NSString *catID = cat[@"CategoryCode"];
                                          if ([filter isEqualToString:catID]) {
                                              [newArr addObject:cat];
                                              break;
                                          }
                                      }
                                  }
                              }
                              
                              NSArray *newArray2 = [LYUtilityManager filterDictionaryNilValue:newArr];
                              [weakSelf setLocalCategory:newArray2 byKey:menu.menuName];
                              sCallBack(newArray2);
                          } faultBlock:fCallBack];
}

- (AFHTTPRequestOperation *)getBookCategoriesFromServer:(LYMenuData *)menu completion:(GLParamBlock)sCallBack failedCallBack:(GLHttpRequstFault)fCallBack
{
    return [self getCategoriesByKind:@"3" menu:menu
                          completion:sCallBack failedCallBack:fCallBack];
}

- (AFHTTPRequestOperation *)getMagazineCagegory:(LYMenuData *)menu completion:(GLParamBlock)sCallBack failedCallBack:(GLHttpRequstFault)fCallBack
{
    return [self getCategoriesByKind:@"2" menu:menu
                          completion:sCallBack failedCallBack:fCallBack];
}

- (void)excuteCompletionBlock:(GLParamBlock)cBlock data:(NSArray *)category
{
    NSMutableArray *parsedResult = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in category) {
        LYCategoryCellData *item = [self parseCategoryItem:dic];
        [parsedResult addObject:item];
    }
    if ([NSThread isMainThread]) {
        categories = parsedResult;
        if (cBlock)
            cBlock(parsedResult);
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            categories = parsedResult;
            if (cBlock)
                cBlock(parsedResult);
        });
    }
}

- (void)excuteFaultBlock:(GLHttpRequstFault)fault message:(NSString *)msg
{
    if(fault) fault(msg);
}

-(LYCategoryCellData *)parseCategoryItem:(NSDictionary *)info
{
    LYCategoryCellData *cellData = [[LYCategoryCellData alloc] init];
    cellData.name = [info objectForKey:@"CategoryName"];
    cellData.categoryID = [info objectForKey:@"CategoryCode"];
    return cellData;
}


@end
