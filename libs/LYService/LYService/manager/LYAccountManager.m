//
//  AccountManager.m
//  LongYuan
//
//  Created by gren light on 12-7-17.
//  Copyright (c) 2012年 grenlight. All rights reserved.
//

#import "LYAccountManager.h"
#import "LYDESUtils.h"
#import <OWKit/OWKitGlobal.h> 
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <Mantle/Mantle.h>
#import "LYMenuData.h"

@implementation LYAccountManager


+(BOOL)isLogin
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_TOKEN])
        return YES;
    
    return NO;
}

+(NSString *)getToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_TOKEN])
        return [[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_TOKEN];
    else
        return DEFAULT_TOKEN;
}

+(NSString *)getNoEncodeToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_TOKEN])
        return [[NSUserDefaults standardUserDefaults] objectForKey:LONGYUAN_TOKEN];
    else
        return DEFAULT_TOKEN;
}

+ (NSString *)getUserName
{
    return [LYAccountManager getValueByKey:LONGYUAN_NAME];
}

+ (void)setToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:LONGYUAN_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getServiceID
{
    return [LYAccountManager getValueByKey:LONGYUAN_SERVICEID];
}

+ (void)setServiceID:(NSString *)sid
{
    [[NSUserDefaults standardUserDefaults] setObject:sid forKey:LONGYUAN_SERVICEID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getValueByKey:(NSString *)key
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key])
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    else
        return @"";
}

+ (void)setValue:(NSString *)value byKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]  synchronize];
}

+(void)logOut
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LONGYUAN_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LONGYUAN_EMAIL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LONGYUAN_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

+(void)saveLogin:(NSString *)name pwd:(NSString *)pwd token:(NSString *)token
{
    if(name != nil)
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:LONGYUAN_NAME];
    
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:LONGYUAN_PWD];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:LONGYUAN_TOKEN];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)noEncodeAppToken
{
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *needEncryptStr = [NSString stringWithFormat:@"%@|%zd|%zd",[LYGlobalConfig sharedInstance].applicationID,PLATFORM,timestamp];
    NSString *appToken =  [[LYDESUtils sharedInstance] encryptString:needEncryptStr];
    
    return appToken;
}

+ (NSString *)appToken
{
    NSString *appToken = (__bridge NSString *)[CommonNetworkingManager encode:
                                               [LYAccountManager noEncodeAppToken]];
    return appToken;
}

-(void)loginByUserName:(NSString *)name
                   pwd:(NSString *)pwd
            completion:(GLHttpRequstResult)sCallBack
                 fault:(GLHttpRequstFault)fCallBack
{
    [self cancelRequest];
    
    NSDictionary *params = @{@"loginname":name,
                             @"password":pwd,
                             @"deviceid":[CommonNetworkingManager UUID]};
    completionBlock = ^(NSDictionary *result){
        NSDictionary *info = result[@"Data"];
        [LYAccountManager setValue:info[@"Name"] byKey:DISPLAY_NAME];
        [LYAccountManager setValue:name byKey:CELL_PHONE];
        [LYAccountManager saveLogin:name pwd:pwd token:info[@"Ticket"]];
        [LYAccountManager getUnitList:sCallBack fault:fCallBack];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESSED object:nil];
    };
    faultBlock = ^(NSString *message){
        if(fCallBack) fCallBack(message);
    };
    httpRequest = [CommonNetworkingManager POST:LONGYUAN_LOGIN_API parameters:params completeBlock:completionBlock faultBlock:faultBlock];
}

+ (void)getUnitList:(GLHttpRequstResult)sCallBack
                 fault:(GLHttpRequstFault)fCallBack
{
    [CommonNetworkingManager sycGET:LONGYUAN_UNIT_LIST
                         parameters:nil
                      completeBlock:^(NSDictionary *result){
                          
                          NSArray *list = result[@"Data"];

                          if (list && [list isKindOfClass:[NSArray class]]
                              && list.count > 0) {
                              if (list.count == 1) {
                                  NSDictionary *info = list[0];
                                  [LYAccountManager generateDomain:info];
                                  [LYAccountManager getServiceList:sCallBack fault:fCallBack];
                              }
                              else {
                                  sCallBack(list);
                              }
                              
                          }
                          else {
                              [LYAccountManager logOut];
                              fCallBack(@"没有取得单位列表");
                          }
                         
                      } faultBlock:^(NSString *msg){
                          [LYAccountManager logOut];
                          fCallBack(msg);
                      }];
}

+ (void)generateDomain:(NSDictionary *)info
{
    NSString *domain = info[@"Domain"];
    [LYAccountManager setValue:info[@"UnitName"] byKey:UNIT_NAME];
    
    NSString *protocal = ([domain componentsSeparatedByString:@"://"].count > 1) ? @"" :@"http://";
    [LYGlobalConfig sharedInstance].apiDomain = [NSString stringWithFormat:@"%@%@", protocal, domain];
}

+ (void)getServiceList:(GLHttpRequstResult)sCallBack
                 fault:(GLHttpRequstFault)fCallBack
{
    [CommonNetworkingManager sycGET:LONGYUAN_SERVICE_LIST
                         parameters:nil
                      completeBlock:^(NSDictionary *result){
                        NSString *appID = [LYGlobalConfig sharedInstance].applicationID;
                          NSDictionary *info = result[@"Data"][0];
                          [LYAccountManager setValue:info[@"LogoURL"] byKey:LOGO_URL];
                          [LYAccountManager setValue:info[@"BackgroundURL"] byKey:ACCOUNT_HEADER_BG];

                          if ([info[@"TemplateID"] isEqualToString:appID]) {
                              [LYAccountManager setServiceID:info[@"ChooseServiceID"]];
                              [LYAccountManager getServiceTicket:sCallBack fault:fCallBack];
                              
                          }
                          else {
                              [LYAccountManager logOut];
                              if (fCallBack) fCallBack(@"没有取到服务列表");
                          }
                      } faultBlock:^(NSString *msg){
                          [LYAccountManager logOut];
                          fCallBack(msg);
                      }];
}

+ (void)getServiceTicket:(GLHttpRequstResult)sCallBack
                   fault:(GLHttpRequstFault)fCallBack
{
    NSString *serviceID = [LYAccountManager getServiceID];
    [CommonNetworkingManager sycGET:LONGYUAN_SERVICE_TICKET
                         parameters:@{@"chooseserviceid":serviceID}
                      completeBlock:^(NSDictionary *result){
                          [LYAccountManager setToken:result[@"Data"]];
                          [LYAccountManager RequestMenuList:sCallBack fault:fCallBack];
                      } faultBlock:^(NSString *msg){
                          [LYAccountManager logOut];
                          fCallBack(msg);
                      }];
}

#pragma  mark 左边栏
+ (void)RequestMenuList:(GLHttpRequstResult)sCallBack
              fault:(GLHttpRequstFault)fCallBack
{
    [CommonNetworkingManager GET:GET_UNIT_MENU
                         parameters:nil
                      completeBlock:^(NSDictionary *result){
                          NSArray *list = [LYAccountManager SaveMenuToFile:result[@"Data"]];
                          if (sCallBack) sCallBack(list);
                      } faultBlock:fCallBack];

}

+ (NSArray *)SaveMenuToFile:(NSArray *)arr
{
    [[NSFileManager defaultManager] removeItemAtPath:[self menuArchiverPath] error:nil];
    
    NSMutableArray *newArray = [NSMutableArray new];
    for (NSDictionary *item in arr) {
        LYMenuData *md = [MTLJSONAdapter modelOfClass:[LYMenuData class] fromJSONDictionary:item error:nil];
        [newArray addObject:md];
    }
    [NSKeyedArchiver archiveRootObject:newArray toFile:[self menuArchiverPath]];
    return newArray;
}

+ (NSArray *)GetMenuList
{
    NSArray *menuList = [NSKeyedUnarchiver unarchiveObjectWithFile:[self menuArchiverPath]];
    return menuList;
}


+ (NSString *)menuArchiverPath
{
    NSString *bundlePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [bundlePath stringByAppendingPathComponent:@"menu.archiver"];
}

#pragma mark 注册
+(void)regByNickName:(NSString *)name  pwd:(NSString *)pwd
     successCallBack:(GLNoneParamBlock)sCallBack 
      failedCallBack:(GLParamBlock)fCallBack
{
    NSString *url = [NSString stringWithFormat:LONGYUAN_REGISTER_API,name,pwd,@"",@""];
   
    [CommonNetworkingManager GET:url parameters:nil completeBlock:^(NSDictionary *result) {
        NSString *token = [result objectForKey:@"authToken"];
        [self saveLogin:name pwd:pwd token:token];
        if(sCallBack ) sCallBack ();
    } faultBlock:^(NSString *message) {
        if(fCallBack) fCallBack(message);
    }];
}

+ (void)modifyPwd:(NSString *)newPwd completion:(GLNoneParamBlock)sCallBack fault:(GLHttpRequstFault)fCallBack
{
    NSDictionary *params = @{@"oldpassword":[LYAccountManager getValueByKey:LONGYUAN_PWD],
                             @"newpassword":newPwd};
    [CommonNetworkingManager POST:MODIFY_PWD_API parameters:params completeBlock:^(NSDictionary *result){
        if (sCallBack) sCallBack();
    } faultBlock:fCallBack];
}

+ (NSArray *)GetCategoriesByMenu:(NSString *)menu
{
    NSString *bundlePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"catFilter.plist"]];
    return [[dict objectForKey:menu] componentsSeparatedByString:@","];
}

+ (void)AlertMessage:(NSString *)msg faultBlock:(GLParamBlock)fault
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:msg delegate:Nil cancelButtonTitle:@"知道了" otherButtonTitles:Nil, nil];
    [alert show];
    
    if (fault) fault(msg);
}

+ (NSString *)md5_32:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15],
            result[16], result[17], result[18], result[19],
            result[20], result[21], result[22], result[23],
            result[24], result[25], result[26], result[27],
            result[28], result[29], result[30], result[31]
            ];
}
@end
