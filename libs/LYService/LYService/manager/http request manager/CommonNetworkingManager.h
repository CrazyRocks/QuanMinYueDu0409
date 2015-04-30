//
//  CommonNetworkingManager.h
//  YuanYang
//
//  Created by grenlight on 14/6/20.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h> 
#import "LYArticleTableCellData.h"
#import "LYMagazineTableCellData.h"
#import "LYGlobalConfig.h"
#import "LYGlobalDefine.h"

typedef enum {
    glMagazineList,
    glFavoriteList,
    glRecommendList,
    glArticleSearchList,
}GLNavigationList;

@interface CommonNetworkingManager : NSObject
{
    AFNetworkReachabilityManager *reachabilityManager;
    NSString         *timeStamp;
    //上一次请求时间戳的时间
    NSTimeInterval    lastRequstTime;
    
    NSString         *_recommendCategoryID;
    
}
@property(nonatomic,retain) LYMagazineTableCellData   *currentMagazine;
//当前的推荐分类
@property(nonatomic,retain) NSString       *recommendCategoryID;
//当前推荐分类的名称
@property(nonatomic,retain) NSString       *recommendCategoryName;
//当前文章是不是由哪个列表导航而来
@property(nonatomic,assign)GLNavigationList fromList;


//当前文章列表
@property(nonatomic, strong) NSArray *articles;
//当前文章索引
@property(nonatomic,assign) NSInteger      articleIndex;



+ (instancetype)sharedInstance;

+ (NSString *)PackageURL:(NSString *)url Params:(NSDictionary *)dict;

- (BOOL)isReachable;
- (BOOL)isWifiConnection;

- (LYArticleTableCellData *)getCurrentArticle;

+ (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                  completeBlock:(GLHttpRequstResult)completeBlock
                     faultBlock:(GLHttpRequstFault)faultBlock;

+ (AFHTTPRequestOperation *)POST:(NSString *)URLString
                     parameters:(id)parameters
                  completeBlock:(GLHttpRequstResult)completeBlock
                     faultBlock:(GLHttpRequstFault)faultBlock;

+ (void)sycGET:(NSString *)URLString
    parameters:(id)parameters
 completeBlock:(GLHttpRequstResult)completeBlock
    faultBlock:(GLHttpRequstFault)faultBlock;

//生成&保存 设备号
+ (NSString *)UUID;

+ (NSString *)md5:(NSString *)str;

+ (CFStringRef)encode:(NSString *)string;
+ (CFStringRef)decodeFromPercentEscapeString:(NSString *)string;

@end
