//
//  SinaWeibo.m
//  sinaweibo_ios_sdk
//
//  Created by Wade Cheng on 4/19/12.
//  Copyright (c) 2012 SINA. All rights reserved.
//

#import "LYSinaWeibo.h"
#import "LYSinaWeiboRequest.h"
#import "LYSinaWeiboConstants.h"
#import "GLSinaAuthorizeViewController.h"

@interface LYSinaWeibo ()

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, copy) NSString *appRedirectURI;

@end

@implementation LYSinaWeibo

@synthesize userID;
@synthesize accessToken;
@synthesize expirationDate;
@synthesize refreshToken;
@synthesize ssoCallbackScheme;
@synthesize delegate;
@synthesize appKey;
@synthesize appSecret;
@synthesize appRedirectURI;

#pragma mark - Memory management

/**
 * @description 初始化构造函数，返回采用默认sso回调地址构造的SinaWeibo对象
 * @param _appKey: 分配给第三方应用的appkey
 * @param _appSecrect: 分配给第三方应用的appsecrect
 * @param _appRedirectURI: 微博开放平台中授权设置的应用回调页
 * @return SinaWeibo对象
 */
- (id)initWithAppKey:(NSString *)_appKey appSecret:(NSString *)_appSecrect
      appRedirectURI:(NSString *)_appRedirectURI
         andDelegate:(id<LYSinaWeiboDelegate>)_delegate
{
    return [self initWithAppKey:_appKey appSecret:_appSecrect appRedirectURI:_appRedirectURI ssoCallbackScheme:nil andDelegate:_delegate];
}


/**
 * @description 初始化构造函数，返回采用默认sso回调地址构造的SinaWeibo对象
 * @param _appKey: 分配给第三方应用的appkey
 * @param _appSecrect: 分配给第三方应用的appsecrect
 * @param _ssoCallbackScheme: sso回调地址，此值应与URL Types中定义的保持一致
 *            若为nil,则初始化为默认格式 sinaweibosso.your_app_key;
 * @param _appRedirectURI: 微博开放平台中授权设置的应用回调页
 * @return SinaWeibo对象
 */
- (id)initWithAppKey:(NSString *)_appKey appSecret:(NSString *)_appSecrect
      appRedirectURI:(NSString *)_appRedirectURI
   ssoCallbackScheme:(NSString *)_ssoCallbackScheme
         andDelegate:(id<LYSinaWeiboDelegate>)_delegate
{
    if ((self = [super init]))
    {
        self.appKey = _appKey;
        self.appSecret = _appSecrect;
        self.appRedirectURI = _appRedirectURI;
        self.delegate = _delegate;
        
        if (!_ssoCallbackScheme)
        {
            _ssoCallbackScheme = [NSString stringWithFormat:@"sinaweibosso.%@://", self.appKey];
        }
        self.ssoCallbackScheme = _ssoCallbackScheme;
        
        requests = [[NSMutableSet alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleOpenURL:)
                                                     name:@"Application_HandleOpenURL" object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    delegate = nil;
    
    for (LYSinaWeiboRequest* _request in requests)
    {
        _request.sinaweibo = nil;
    }
    
    [request disconnect];
    request = nil;
    
}

- (void)storeAuthData
{    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.accessToken, @"AccessTokenKey",
                              self.expirationDate, @"ExpirationDateKey",
                              self.userID, @"UserIDKey",
                              self.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
/**
 * @description 清空认证信息
 */
- (void)removeAuthData
{
    self.accessToken = nil;
    self.userID = nil;
    self.expirationDate = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* sinaweiboCookies = [cookies cookiesForURL:
                                [NSURL URLWithString:@"https://open.weibo.cn"]];
    
    for (NSHTTPCookie* cookie in sinaweiboCookies)
    {
        [cookies deleteCookie:cookie];
    }
}

#pragma mark - Private methods

- (void)requestAccessTokenWithAuthorizationCode:(NSString *)code
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.appKey, @"client_id",
                            self.appSecret, @"client_secret",
                            @"authorization_code", @"grant_type",
                            self.appRedirectURI, @"redirect_uri",
                            code, @"code", nil];
    [request disconnect];
    request = nil;
    
    request = [LYSinaWeiboRequest requestWithURL:kSinaWeiboWebAccessTokenURL
                                     httpMethod:@"POST"
                                         params:params
                                       delegate:self];
    
    [request connect];
}

- (void)requestDidFinish:(LYSinaWeiboRequest *)_request
{
    [requests removeObject:_request];
    _request.sinaweibo = nil;
}

- (void)requestDidFailWithInvalidToken:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(sinaweibo:accessTokenInvalidOrExpired:)])
    {
        [delegate sinaweibo:self accessTokenInvalidOrExpired:error];
    }
}

- (void)notifyTokenExpired:(id<LYSinaWeiboRequestDelegate>)requestDelegate
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Token expired", NSLocalizedDescriptionKey, nil];
    
    NSError *error = [NSError errorWithDomain:kSinaWeiboSDKErrorDomain
                                         code:21315
                                     userInfo:userInfo];
    
    if ([delegate respondsToSelector:@selector(sinaweibo:accessTokenInvalidOrExpired:)])
    {
        [delegate sinaweibo:self accessTokenInvalidOrExpired:error];
    }
    
    if ([requestDelegate respondsToSelector:@selector(request:didFailWithError:)]) 
	{
		[requestDelegate request:nil didFailWithError:error];
	}
}

- (void)logInDidCancel
{
    if ([delegate respondsToSelector:@selector(sinaweiboLogInDidCancel:)])
    {
        [delegate sinaweiboLogInDidCancel:self];
    }
}

- (void)logInDidFinishWithAuthInfo:(NSDictionary *)authInfo
{
    NSString *access_token = [authInfo objectForKey:@"access_token"];
    NSString *uid = [authInfo objectForKey:@"uid"];
    NSString *remind_in = [authInfo objectForKey:@"remind_in"];
    NSString *refresh_token = [authInfo objectForKey:@"refresh_token"];
    if (access_token && uid)
    {
        if (remind_in != nil)
        {
            int expVal = [remind_in intValue];
            if (expVal == 0)
            {
                self.expirationDate = [NSDate distantFuture];
            }
            else
            {
                self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
            } 
        } 
        
        self.accessToken = access_token;
        self.userID = uid;
        self.refreshToken = refresh_token;
        
        [self storeAuthData];
        
        if ([delegate respondsToSelector:@selector(sinaweiboDidLogIn:)])
        {
            [delegate sinaweiboDidLogIn:self];
        }
    }
}

- (void)logInDidFailWithErrorInfo:(NSDictionary *)errorInfo
{
    NSString *error_code = [errorInfo objectForKey:@"error_code"];
    if ([error_code isEqualToString:@"21330"])
    {
        [self logInDidCancel];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(sinaweibo:logInDidFailWithError:)])
        {
            NSString *error_description = [errorInfo objectForKey:@"error_description"];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      errorInfo, @"error",
                                      error_description, NSLocalizedDescriptionKey, nil];
            NSError *error = [NSError errorWithDomain:kSinaWeiboSDKErrorDomain 
                                                 code:[error_code intValue]
                                             userInfo:userInfo];
            [delegate sinaweibo:self logInDidFailWithError:error];
        }
        
    }
}

#pragma mark - Validation

/**
 * @description 判断是否登录
 * @return YES为已登录；NO为未登录
 */
- (BOOL)isLoggedIn
{
    return userID && accessToken && expirationDate;
}

/**
 * @description 判断登录是否过期
 * @return YES为已过期；NO为未为期
 */
- (BOOL)isAuthorizeExpired
{
    NSDate *now = [NSDate date];
    return ([now compare:expirationDate] == NSOrderedDescending);
}


/**
 * @description 判断登录是否有效，当已登录并且登录未过期时为有效状态
 * @return YES为有效；NO为无效
 */
- (BOOL)isAuthValid
{
    return ([self isLoggedIn] && ![self isAuthorizeExpired]);
}

#pragma mark - LogIn / LogOut

/**
 * @description 登录入口，当初始化SinaWeibo对象完成后直接调用此方法完成登录
 */
- (void)logIn
{
    if ([self isAuthValid])
    {
        if ([delegate respondsToSelector:@selector(sinaweiboDidLogIn:)])
        {
            [delegate sinaweiboDidLogIn:self];
        }
    }
    else
    {
        [self removeAuthData];
        
        ssoLoggingIn = NO;
        
        // open sina weibo app
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)] &&
            [device isMultitaskingSupported])
        {
            NSDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    self.appKey, @"client_id",
                                    self.appRedirectURI, @"redirect_uri",
                                    self.ssoCallbackScheme, @"callback_uri", nil];
            
            // 先用iPad微博打开
            NSString *appAuthBaseURL = kSinaWeiboAppAuthURL_iPad;
            if (SinaWeiboIsDeviceIPad())
            {
                NSString *appAuthURL = [LYSinaWeiboRequest serializeURL:appAuthBaseURL
                                                               params:params httpMethod:@"GET"];
                ssoLoggingIn = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appAuthURL]];
            }
            
            // 在用iPhone微博打开
            if (!ssoLoggingIn)
            {
                appAuthBaseURL = kSinaWeiboAppAuthURL_iPhone;
                NSString *appAuthURL = [LYSinaWeiboRequest serializeURL:appAuthBaseURL
                                                               params:params httpMethod:@"GET"];
//                NSLog(@"url:%@",appAuthURL);
                ssoLoggingIn = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appAuthURL]];
            }
        }
        
        if (!ssoLoggingIn)
        {
            // open authorize view
            
            NSDictionary *params = [@{@"client_id":self.appKey,
                                    @"response_type":@"code",
                                    @"redirect_uri":self.appRedirectURI,
                                    @"display":@"mobile"} mutableCopy];
            NSString *authPagePath = [LYSinaWeiboRequest serializeURL:kSinaWeiboWebAuthURL
                                                             params:params httpMethod:@"GET"];
            
            GLSinaAuthorizeViewController *authorizeController = [[GLSinaAuthorizeViewController alloc] init];
            authorizeController.delegate = self;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:authorizeController animated:YES completion:nil];

            [authorizeController loadRequestWithURL:[NSURL URLWithString:authPagePath]];

        }
    }
}

/**
 * @description 退出方法，需要退出时直接调用此方法
 */
- (void)logOut
{
    [self removeAuthData];
    
    if ([delegate respondsToSelector:@selector(sinaweiboDidLogOut:)])
    {
        [delegate sinaweiboDidLogOut:self];
    }
}

#pragma mark - Send request with token

/**
 * @description 微博API的请求接口，方法中自动完成token信息的拼接
 * @param url: 请求的接口
 * @param params: 请求的参数，如发微博所带的文字内容等
 * @param httpMethod: http类型，GET或POST
 * @param _delegate: 处理请求结果的回调的对象，SinaweiboRequestDelegate类
 * @return 完成实际请求操作的SinaWeiboRequest对象
 */

- (LYSinaWeiboRequest *)requestWithURL:(NSString *)url
                             params:(NSMutableDictionary *)params
                         httpMethod:(NSString *)httpMethod
                           delegate:(id<LYSinaWeiboRequestDelegate>)_delegate
{
    if (params == nil)
    {
        params = [NSMutableDictionary dictionary];
    }
    
    if ([self isAuthValid])
    {
        [params setValue:self.accessToken forKey:@"access_token"];
        NSString *fullURL = [kSinaWeiboSDKAPIDomain stringByAppendingString:url];
        
        LYSinaWeiboRequest *_request = [LYSinaWeiboRequest requestWithURL:fullURL
                                                           httpMethod:httpMethod
                                                               params:params
                                                             delegate:_delegate];
        _request.sinaweibo = self;
        [requests addObject:_request];
        [_request connect];
        return _request;
    }
    else
    {
        //notify token expired in next runloop
        [self performSelectorOnMainThread:@selector(notifyTokenExpired:)
                               withObject:_delegate
                            waitUntilDone:NO];
        
        return nil;
    }
}

#pragma mark - SinaWeiboAuthorizeView Delegate

- (void)authorizeView:(id)authView didRecieveAuthorizationCode:(NSString *)code
{
    [[UIApplication sharedApplication].keyWindow.rootViewController
     dismissViewControllerAnimated:YES completion:nil];
    [self requestAccessTokenWithAuthorizationCode:code];
}

- (void)authorizeView:(id)authView didFailWithErrorInfo:(NSDictionary *)errorInfo
{
    [[UIApplication sharedApplication].keyWindow.rootViewController
     dismissViewControllerAnimated:YES completion:nil];
    [self logInDidFailWithErrorInfo:errorInfo];
}

- (void)authorizeViewDidCancel:(id)authView
{
    [[UIApplication sharedApplication].keyWindow.rootViewController
     dismissViewControllerAnimated:YES completion:nil];
    [self logInDidCancel];
}


#pragma mark - SinaWeiboRequest Delegate

- (void)request:(LYSinaWeiboRequest *)_request didFailWithError:(NSError *)error
{
    if (_request == request)
    {
        if ([delegate respondsToSelector:@selector(sinaweibo:logInDidFailWithError:)])
        {
            [delegate sinaweibo:self logInDidFailWithError:error];
        }
        
        request = nil;
    }
}

- (void)request:(LYSinaWeiboRequest *)_request didFinishLoadingWithResult:(id)result
{
    if (_request == request)
    {        
        [self logInDidFinishWithAuthInfo:result];
        request = nil;
    }
}

#pragma mark - Application life cycle

/**
 * @description 当应用从后台唤起时，应调用此方法，需要完成退出当前登录状态的功能
 */
- (void)applicationDidBecomeActive
{
    if (ssoLoggingIn)
    {
        // user open the app manually
        // clean sso login state
        ssoLoggingIn = NO;
        
        if ([delegate respondsToSelector:@selector(sinaweiboLogInDidCancel:)])
        {
            [delegate sinaweiboLogInDidCancel:self];
        }
    }
}

/**
 * @description sso回调方法，官方客户端完成sso授权后，回调唤起应用，应用中应调用此方法完成sso登录
 * @param url: 官方客户端回调给应用时传回的参数，包含认证信息等
 * @return YES
 */
- (void)handleOpenURL:(NSNotification *)notif
{
    NSURL *url = [notif.userInfo objectForKey:@"url"];
    
    NSString *urlString = [url absoluteString];
    
    if ([urlString hasPrefix:self.ssoCallbackScheme])
    {
        if (!ssoLoggingIn)
        {
            // sso callback after user have manually opened the app
            // ignore the request
        }
        else
        {
            ssoLoggingIn = NO;
            
            if ([LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"sso_error_user_cancelled"])
            {
                if ([delegate respondsToSelector:@selector(sinaweiboLogInDidCancel:)])
                {
                    [delegate sinaweiboLogInDidCancel:self];
                }
            }
            else if ([LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"sso_error_invalid_params"])
            {
                if ([delegate respondsToSelector:@selector(sinaweibo:logInDidFailWithError:)])
                {
                    NSString *error_description = @"Invalid sso params";
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                              error_description, NSLocalizedDescriptionKey, nil];
                    NSError *error = [NSError errorWithDomain:kSinaWeiboSDKErrorDomain 
                                                         code:kSinaWeiboSDKErrorCodeSSOParamsError
                                                     userInfo:userInfo];
                    [delegate sinaweibo:self logInDidFailWithError:error];
                }
            }
            else if ([LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"error_code"])
            {
                NSString *error_code = [LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"error_code"];
                NSString *error = [LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"error"];
                NSString *error_uri = [LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"error_uri"];
                NSString *error_description = [LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"error_description"];
                
                NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                           error, @"error",
                                           error_uri, @"error_uri",
                                           error_code, @"error_code",
                                           error_description, @"error_description", nil];
                
                [self logInDidFailWithErrorInfo:errorInfo];
            }
            else
            {
                NSString *access_token = [LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"access_token"];
                NSString *expires_in = [LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"expires_in"];
                NSString *remind_in = [LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"remind_in"];
                NSString *uid = [LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"uid"];
                NSString *refresh_token = [LYSinaWeiboRequest getParamValueFromUrl:urlString paramName:@"refresh_token"];
                
                NSMutableDictionary *authInfo = [NSMutableDictionary dictionary];
                if (access_token) [authInfo setObject:access_token forKey:@"access_token"];
                if (expires_in) [authInfo setObject:expires_in forKey:@"expires_in"];
                if (remind_in) [authInfo setObject:remind_in forKey:@"remind_in"];
                if (refresh_token) [authInfo setObject:refresh_token forKey:@"refresh_token"];
                if (uid) [authInfo setObject:uid forKey:@"uid"];
                
                [self logInDidFinishWithAuthInfo:authInfo];
            }
        }
    }
}

- (void)authorizeCompleted
{
    
}

@end

BOOL SinaWeiboIsDeviceIPad()
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
#endif
    return NO;
}
