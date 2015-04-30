//
//  GLCommentManager.m
//  LogicBook
//
//  Created by iMac001 on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GLCommentManager.h"
#import "CmtWrittingController.h"
#import "SendingMessageController.h"
#import <LYService/LYService.h>
#import <OWKit/OWKit.h>

@interface GLCommentManager()
{
    CmtWrittingController       *writtingController;
    
}

@end


@implementation GLCommentManager

static GLCommentManager *instance;
@synthesize navbarMask;
@synthesize defaultMessage;
@synthesize weiboEngine;

-(id)init
{
    self = [super init];
    if(self){
     
    }
    return self;
}

-(void)setup
{    
    weiboEngine = [[LYSinaWeibo alloc] initWithAppKey:@"37737484"
                                          appSecret:@"a3b41b78478f0cc5348e301ff49457fe"
                                     appRedirectURI:@"http://m.qikan.com"
                                        andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
    {
        weiboEngine.accessToken = sinaweiboInfo[@"AccessTokenKey"];
        weiboEngine.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
        weiboEngine.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
    }
}

+(GLCommentManager *)sharedInstance
{
    @synchronized(self) {
        if(instance == nil){
            instance = [[GLCommentManager alloc]init];
            [instance setup];
        }
        return instance;
    }
}


- (void)setMessageCompleteBlock:(void (^)(NSString *))block
{
    sendCompleteBlock = block;
}

//加载微博编辑界面
-(void)loadWeiBoUI
{
    needSendImage = nil;
    currentState = owCommentSendMessageState;
    //为了演示微博授权到发博的过程，故将登录信息清除
    [weiboEngine logOut];
    
    if ([weiboEngine isLoggedIn] && ![weiboEngine isAuthorizeExpired]) {
        [self animateIntoWrittingView];

    }
    else {
        [weiboEngine logIn];
    }
}

- (void)sharedBookshelf:(UIImage *)image
{
    needSendImage = image;
    
    currentState = owCommentSharedBookshelf;
    
    if ([weiboEngine isLoggedIn] && ![weiboEngine isAuthorizeExpired]) {
        [self animateIntoWrittingView];
        
    }
    else {
        [weiboEngine logIn];
    }
}

-(void)loadWeiBoUIByDefaultMessage:(NSString *)msg
{
    defaultMessage = msg;
    [self loadWeiBoUI];
}

- (void)getAuthorize:(void (^)())block
{
    [weiboEngine logOut];
    
    currentState = owCommentAuthorizeState;
    getAuthorizeComplete = [block copy];

    if ([weiboEngine isLoggedIn] && ![weiboEngine isAuthorizeExpired]) {
        getAuthorizeComplete();
    }
    else {
        [weiboEngine logIn];
    }    
}

//进入微博编辑视图
-(void)animateIntoWrittingView
{
    if(!writtingController){
        writtingController = [[CmtWrittingController alloc]init ];
        [writtingController initMask:navbarMask];
    }
    [writtingController  animateInWritingPanel];
}


-(void)sendAndSync:(NSString *)cmt
{
    [self sendAndSync:cmt image:nil];
}

-(void)sendAndSync:(NSString *)cmt image:(UIImage *)img
{
    currentMessage = cmt;
   
//    [[SendingMessageController sharedInstance] showMessage:@"正在发送微博..." autoClose:NO];
    //判断当前网络情况
    if( ![[CommonNetworkingManager sharedInstance] isReachable]){
        [self closeMessagePanel];
//        [[SendingMessageController sharedInstance] showMessage:@"发送失败！" autoClose:YES];
        return;
    }
    
    if (nil == cmt) {
        [self closeMessagePanel];
        return;
    }
    
    UIImage *image = img;
    
    if (currentState == owCommentSharedBookshelf)
        image = needSendImage;
    
    //发送到新浪
    if (image) {  
        [weiboEngine requestWithURL:@"statuses/upload.json"
                           params:[@{@"status":cmt,@"pic":image} mutableCopy]
                       httpMethod:@"POST"
                         delegate:self];
  
    }
    else {
        [weiboEngine requestWithURL:@"statuses/update.json"
                             params:[@{@"status":cmt} mutableCopy]
                         httpMethod:@"POST"
                           delegate:self];
    }
    
}

- (void)sendingCompleted
{
    [writtingController sendingCompleted];
     
    [self performSelector:@selector(closeMessagePanel) withObject:nil afterDelay:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"COMMENT_CHANGED" object:nil];
}

- (void)sendingFault
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"COMMENT_SENDING_FAULT" object:nil];;
    
    [self performSelector:@selector(closeMessagePanel)
               withObject:nil
               afterDelay:1];
}

- (void)closeMessagePanel
{
    __unsafe_unretained GLCommentManager *weakSelf = self;

    void(^animateOutCallBack)(void) = ^{
        [weakSelf->writtingController.view removeFromSuperview];
        weakSelf->writtingController = nil;
    };
    
    [writtingController animageOut:animateOutCallBack];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];

}


#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(LYSinaWeibo *)sinaweibo
{
    if (currentState == owCommentSendMessageState || currentState == owCommentSharedBookshelf) {
        [self animateIntoWrittingView];
    }
    else {
        getAuthorizeComplete();
    }

}

- (void)sinaweiboDidLogOut:(LYSinaWeibo *)sinaweibo
{
   
}

- (void)sinaweiboLogInDidCancel:(LYSinaWeibo *)sinaweibo
{
}

- (void)sinaweibo:(LYSinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
}

- (void)sinaweibo:(LYSinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
   
}


#pragma mark - SinaWeiboRequest Delegate

- (void)request:(LYSinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"]) {
    }
    
    else if ([request.url hasSuffix:@"statuses/user_timeline.json"]){
    }
    
    else if ([request.url hasSuffix:@"statuses/update.json"] ||
             [request.url hasSuffix:@"statuses/upload.json"]) {
        [self sendingFault];
    }
   
}

- (void)request:(LYSinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"]) {
        [self saveUserInfoAndDownloadAvatar:result];
    }
    
    else if ([request.url hasSuffix:@"statuses/user_timeline.json"]){
    }
    
    else if ([request.url hasSuffix:@"statuses/update.json"] ||
             [request.url hasSuffix:@"statuses/upload.json"]) {

        if(sendCompleteBlock)
            sendCompleteBlock(currentMessage);
        else
            [self sendingCompleted];
    }
}

#pragma saveUserInfo and download avatar

//
- (void)getUserInfo:(void(^)())block
{
    getUserInfoComplete = [block copy];
    
    [weiboEngine requestWithURL:@"users/show.json"
                         params:[NSMutableDictionary dictionaryWithObject:weiboEngine.userID forKey:@"uid"]
                     httpMethod:@"GET"
                       delegate:self];
}

//已登录且取得了用户信息
- (void)alreadyGetUserInfo
{
    getUserInfoComplete();
}

- (void)saveUserInfoAndDownloadAvatar:(NSDictionary *)result
{
    NSString *userName = result[@"screen_name"];
    NSString *avatar_large = result[@"avatar_large"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:userName forKey:@"WEIBO_NAME"];
    [defaults setObject:@"" forKey:AVATAR_LARGE];
    [defaults setBool:NO forKey:AVATAR_UPLOADED];
    
    __unsafe_unretained GLCommentManager *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //下载用户头像
        [weakSelf downloadImageByURL:avatar_large imageName:@"avatar_large.png" defautsKey:AVATAR_LARGE];
    });
}

-(void)downloadImageByURL:(NSString *)url imageName:(NSString *)name defautsKey:(NSString *)key
{
    NSString *documentPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imagePath = [documentPath stringByAppendingPathComponent:name];
//    __unsafe_unretained ASIHTTPRequest *dlRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString: url]];
//    [dlRequest setDownloadDestinationPath:imagePath];
//    
//    __unsafe_unretained GLCommentManager *weakSelf = self;
//    [dlRequest setCompletionBlock:^{
//        [[NSUserDefaults standardUserDefaults] setObject:url forKey:key];
//        
//        if (key) {
//            [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey:key];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//        //如果是用户头像
//        if([key isEqualToString:AVATAR_LARGE]){
//            UIImage *choosenImage = [UIImage imageWithContentsOfFile:imagePath];
//            //生成小头像
//            choosenImage = [OWImage resizeImage:choosenImage toWidth:50 height:50];
//            NSString *fileName =@"avatar_small.png";
//            NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent: fileName ];
//            NSData *imageData = UIImagePNGRepresentation(choosenImage);
//            [imageData writeToFile:filePath atomically:NO];
//            [[NSUserDefaults standardUserDefaults] setObject:filePath forKey:AVATAR_SMALL];
//        }
//        [weakSelf alreadyGetUserInfo];
//        
//    }];
//    [dlRequest setFailedBlock:^{
//        [weakSelf downloadImageByURL:url imageName:@"avatar_large.png" defautsKey:AVATAR_LARGE];
//    }];
//    [dlRequest startAsynchronous];
}
@end
