//
//  AccountManager.h
//  LongYuan
//
//  Created by gren light on 12-7-17.
//  Copyright (c) 2012年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWBasicHTTPRequest.h"

#define kFAVCATSBYNAME      @"favCatsByName"

@interface LYAccountManager : OWBasicHTTPRequest

//是否已登陆
+(BOOL)isLogin;

+(NSString *)getToken;
+(NSString *)getNoEncodeToken;

+ (void)setToken:(NSString *)token;
+ (NSString *)getValueByKey:(NSString *)key;

+ (NSString *)getUserName;

+ (NSString *)getServiceID;
+ (void)setServiceID:(NSString *)sid;

+ (NSString *)appToken;
+ (NSString *)noEncodeAppToken;

//登出
+(void)logOut;

//保存登陆信息
+(void)saveLogin:(NSString *)name pwd:(NSString *)pwd token:(NSString *)token ;

-(void)loginByUserName:(NSString *)name
                   pwd:(NSString *)pwd
            completion:(GLHttpRequstResult)sCallBack
                 fault:(GLHttpRequstFault)fCallBack;

+ (void)generateDomain:(NSDictionary *)info;

+ (void)getServiceList:(GLHttpRequstResult)sCallBack
                 fault:(GLHttpRequstFault)fCallBack;

+(void)regByNickName:(NSString *)name pwd:(NSString *)pwd
     successCallBack:(GLNoneParamBlock)sCallBack 
      failedCallBack:(GLParamBlock)fCallBack;

+ (void)modifyPwd:(NSString *)newPwd
       completion:(GLNoneParamBlock)sCallBack
            fault:(GLHttpRequstFault)fCallBack;

//获取左边栏菜单列表
+ (void)RequestMenuList:(GLHttpRequstResult)sCallBack
              fault:(GLHttpRequstFault)fCallBack;

+ (NSArray *)GetMenuList;

//从左侧栏列表项里取得分类ID列表
+ (NSArray *)GetCategoriesByMenu:(NSString *)menu;

@end
