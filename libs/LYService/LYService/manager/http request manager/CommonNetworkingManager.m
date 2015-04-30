//
//  CommonNetworkingManager.m
//  YuanYang
//
//  Created by grenlight on 14/6/20.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "CommonNetworkingManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "LYAccountManager.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <OWKit/OWMessageView.h> 

@implementation CommonNetworkingManager

@synthesize currentMagazine;
@synthesize articleIndex, articles;
@synthesize recommendCategoryID, recommendCategoryName;
@synthesize fromList;

+ (instancetype)sharedInstance
{
    static CommonNetworkingManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CommonNetworkingManager alloc] init];
        [instance setup];
    });
    return instance;
}

- (BOOL)isReachable
{
    return reachabilityManager.isReachable;
}

- (BOOL)isWifiConnection
{
    return reachabilityManager.isReachableViaWiFi;
}

-(void)setup
{
    timeStamp = nil;
    lastRequstTime = 0;
    reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    //状态栏显示网络请求指示器
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

-(NSString *)recommendCategoryID
{
    if (!_recommendCategoryID) {
        _recommendCategoryID = @"";
    }
    return _recommendCategoryID;
}

-(void)setRecommendCategoryID:(NSString *)arecommendCategoryID
{
    if ([_recommendCategoryID isEqualToString:arecommendCategoryID]) {
        return;
    }
    _recommendCategoryID = arecommendCategoryID;
}

-(LYArticleTableCellData *)getCurrentArticle
{
    return (LYArticleTableCellData *)articles[articleIndex]  ;
}

+ (NSDictionary *)getParameters:(NSDictionary *)dict
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:dict];
    if (!params[@"ticket"] || [params[@"ticket"] isEqualToString:@""]) {
        [params setObject:[LYAccountManager getToken] forKey:@"ticket"];
    }
    if (!params[@"apptoken"] || [params[@"apptoken"] isEqualToString:@""]) {
        NSString *appToken = [LYAccountManager appToken];
        [params setObject:appToken forKey:@"apptoken"];
    }
    
    return params;
}

+ (NSDictionary *)getNoneEncodeParameters:(NSDictionary *)dict
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:dict];
    if (!params[@"ticket"] || [params[@"ticket"] isEqualToString:@""]) {
        [params setObject:[LYAccountManager getNoEncodeToken] forKey:@"ticket"];
    }
    if (!params[@"apptoken"] || [params[@"apptoken"] isEqualToString:@""]) {
        NSString *appToken = [LYAccountManager noEncodeAppToken];
        [params setObject:appToken forKey:@"apptoken"];
    }
    return params;
}

+ (NSString *)PackageURL:(NSString *)url Params:(NSDictionary *)dict
{
    NSDictionary *params = [CommonNetworkingManager getParameters:dict];
    
    NSMutableString *newURL = [[NSMutableString alloc] init];
//    NSMutableString *signStr = [[NSMutableString alloc] init];
    
    [newURL appendString:url];
    NSArray *keys = [params allKeys];
    NSArray *sKeys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    for (NSInteger i=0; i<sKeys.count; i++) {
        NSString *key = sKeys[i];
        NSString *val = [NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]];
        if (i == 0) {
            [newURL appendString:val];
//            [signStr appendString:val];
        }
        else {
            [newURL appendFormat:@"&%@", val];
//            [signStr appendFormat:@"|%@", val];
        }
        
    }
//    [newURL appendFormat:@"&sign=%@", [CommonNetworkingManager md5:signStr]];
    
    return newURL;
}

+ (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                  completeBlock:(GLHttpRequstResult)completeBlock
                     faultBlock:(GLHttpRequstFault)faultBlock
{
    NSDictionary *params = [CommonNetworkingManager getNoneEncodeParameters:parameters];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 240;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes
    = [NSSet setWithObjects:@"text/plain", @"text/html",@"application/json",nil];
   return  [manager GET:URLString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
       [CommonNetworkingManager parseJSONData:operation.responseData completeBlock:completeBlock faultBlock:faultBlock];
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (faultBlock) faultBlock(error.description);
    }];
}

+ (AFHTTPRequestOperation *)POST:(NSString *)URLString
                     parameters:(id)parameters
                  completeBlock:(GLHttpRequstResult)completeBlock
                     faultBlock:(GLHttpRequstFault)faultBlock
{
    NSDictionary *params = [CommonNetworkingManager getParameters:parameters];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = requestSerializer;
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes
    = [NSSet setWithObjects:@"text/plain", @"text/html",@"application/json",nil];
    return  [manager POST:URLString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [CommonNetworkingManager parseJSONData:operation.responseData completeBlock:completeBlock faultBlock:faultBlock];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@",error.description);
        if (faultBlock) faultBlock(error.description);
    }];
}

+ (void)sycGET:(NSString *)URLString parameters:(id)parameters completeBlock:(GLHttpRequstResult)completeBlock faultBlock:(GLHttpRequstFault)faultBlock
{
    NSString *url = [CommonNetworkingManager PackageURL:URLString Params:parameters];
    NSURLResponse *response ;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"error:%@", error.description);
        if (faultBlock) faultBlock(error.description);
    }
    else {
        [CommonNetworkingManager parseJSONData:responseData completeBlock:completeBlock faultBlock:faultBlock];
    }
}

+ (void)parseJSONData:(NSData *)responseData
        completeBlock:(GLHttpRequstResult)completeBlock
           faultBlock:(GLHttpRequstFault)faultBlock
{
    if (!responseData) {
        if (faultBlock) faultBlock(@"接口没有返回值");
        return ;
    }
    
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSStringEncoding gb2312Encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *gb2312String = [[NSString alloc] initWithData:responseData encoding:gb2312Encoding];
        if (gb2312String && [gb2312String isKindOfClass:[NSString class]] && gb2312String.length > 0) {
            NSData *utf8Data = [gb2312String dataUsingEncoding:NSUTF8StringEncoding];
            if ( utf8Data) {
                error = nil;
                result = [NSJSONSerialization JSONObjectWithData:utf8Data options:NSJSONReadingMutableLeaves error:&error];
            }
        }
    }
    if (error) {
        NSLog(@"error:%@",error.description);
        NSLog(@"error data:%@",[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (faultBlock) faultBlock(@"JSON解析错误！");
        return ;
    };
    
    //         NSLog(@"result:%@",result);
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        id status = result[@"Code"];
        if ([status isKindOfClass:[NSNumber class]])
            status = [(NSNumber *)status stringValue];
        
        if([status isEqualToString:@"1"])
            completeBlock(result);
        else if ([status isEqualToString:@"3"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AppLogOut" object:nil];
            [[OWMessageView sharedInstance] showMessage:@"当前帐号已在其他设备登录" autoClose:YES];
        }
        else {
            NSLog(@"error message:%@",result[@"Message"]);
            if (faultBlock) faultBlock(result[@"Message"]);
        }
    }
    else
        if (faultBlock) faultBlock(@"服务器错误!");
    
}

//生成&保存 设备号
+(NSString*) UUID
{
    NSString *result = [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"];
    if (result) {
        return result;
    }
    
    result = [[UIDevice currentDevice] identifierForVendor].UUIDString ;
    
    [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"uuid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return result ;
}

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (CFStringRef)encode:(NSString *)string
{
    return  CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                    (__bridge CFStringRef)string, nil,
                                                    CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), kCFStringEncodingUTF8);
}

+ (CFStringRef)decodeFromPercentEscapeString:(NSString *) string
{
    return CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(__bridge CFStringRef) string,CFSTR(""),kCFStringEncodingUTF8);
}

@end
