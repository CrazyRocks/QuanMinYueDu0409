//
//  GLCommentManager.h
//  LogicBook
//
//  Created by iMac001 on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYSinaWeibo.h"
#import "LYSinaWeiboRequest.h"

typedef enum {
    owCommentAuthorizeState,//只获取授权
    owCommentSendMessageState,
    owCommentSharedBookshelf,//分享书架，
}CommentStatus;

@class SinaWeiboAuthorizeView;


@interface GLCommentManager : NSObject<LYSinaWeiboDelegate,LYSinaWeiboRequestDelegate>{
    @private
    NSString  *sinaAppKey, *sinaAppSecret;
    
    //微博发送成功之后的回调
    void(^sendCompleteBlock)(NSString *);
    
    //当前在发送的内容
    NSString *currentMessage;
    
    CommentStatus       currentState;
    
    void(^getAuthorizeComplete)();
    void(^getUserInfoComplete)();
    
    UIImage *needSendImage;

}

//微博编辑界面导航栏遮罩
@property(nonatomic,retain)UIView *navbarMask;

@property(nonatomic,retain)NSString *defaultMessage;
//
@property (nonatomic, strong) LYSinaWeibo *weiboEngine;



+(GLCommentManager *)sharedInstance;

- (void)setMessageCompleteBlock:(void(^)(NSString *))block;

//发送消息且释放编辑视图
-(void)sendAndSync:(NSString *)cmt;
- (void)sendAndSync:(NSString *)cmt image:(UIImage *)img;



//加载微博编辑界面
-(void)loadWeiBoUI;
-(void)loadWeiBoUIByDefaultMessage:(NSString *)msg;

//分享书架
- (void)sharedBookshelf:(UIImage *)image;


- (void)getAuthorize:(void(^)())block;

- (void)getUserInfo:(void(^)())block;

- (void)sendingCompleted;
- (void)sendingFault;


@end
