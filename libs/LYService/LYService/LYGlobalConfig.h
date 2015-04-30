//
//  GLNotificationName.h
//  LogicBook
//
//  Created by iMac001 on 12-2-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#define isiOS7 ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue]>=7)
#define isiOS8 ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue]>=8)

#define viewFrameOffsetY    (isiOS7 ? 0 : (-20))
//#define viewFrameOffsetY    0

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define appWidth   ([[UIScreen mainScreen] bounds].size.width)
#define appHeight  ([[UIScreen mainScreen] bounds].size.height)


//#define appHeight  ([OWNavigationController sharedInstance].view.frame.size.height)

#define appBackground   0x2C2C2C
//登录注册页面背景
#define loginBackground 0xf9f9f9
//列表项选择背景
#define tableCellSelectedColor  0x2a2a2a

//文章字号大小
#define appFontsize_normal 18.0f
#define appFontsize_large  22.0f


//表格状态
typedef enum{
    gTableCellState_none,
    gTableCellState_image,
}TableCellState;

//导航状态
typedef enum {
    glNavigationBarNormalState,
    glNavigationBarSeachState,
    glNavigationBarRecommendState,
    glNavigationBarFavoriteState,
    glNavigationBarFavoriteEditState,
    glNavigationBarMagazineState,
    glNavigationBarSettingState
}MainNavigationBarStatus;

//当前文章渲染进程状态
typedef enum {
    glArticleDetailInitState,
    glArticleDetailTitleState,
    glArticleDetailAlbumState,
    glArticleDetailContentRequestState,
    glArticleDetailCompleteState
}ArticleDetailReaderStatus;


/*
 user defaults keys ------------------------------------------------------------------
 */
//是第一次启动
#define ISLAUNCHINGFIRSTTIME   @"IsLaunchingFirstTime"

//应用的字体大小
#define APP_FONTSIZE @"App_Fontsize"
//3G条件下自动下载
#define AUTO_DOWNLOAD @"Auto_Download"
//离线收藏
#define OFFLINE_FAVORITE @"Offline_Favorite"


//用户在微博的唯一标识
#define WEIBO_ID               @"WEIBO_ID"
//微博类型1：新浪微博  2：腾讯微博  3：豆瓣
#define WEIBO_TYPE             @"WEIBO_TYPE"

//此微博名是否已绑定
#define WEIBO_BINDING   @"WEIBO_BINDING"
//用户大头像地址
#define AVATAR_LARGE    @"Avatar_Large"
#define AVATAR_SMALL    @"Avatar_Small"
//用户头像是否已上传
#define AVATAR_UPLOADED @"Avatar_Uploaded"
//用户信息
#define LONGYUAN_NAME   @"LongYuan_NickName"
#define LONGYUAN_PWD    @"LongYuan_Pwd"
#define LONGYUAN_TOKEN    @"LongYuan_Token"
#define LONGYUAN_SERVICEID  @"ServiceID"

#define UNIT_NAME   @"Unit_Name"
#define DISPLAY_NAME   @"Display_Name"
#define CELL_PHONE      @"CellPhone"
#define LOGO_URL      @"Logo_URL"
#define ACCOUNT_HEADER_BG      @"Account_Header_Bg_URL"



//注册邮箱
#define LONGYUAN_EMAIL  @"LongYuna_Email"


/*
 ---  通知名称 -----------------------------------------------------------------------
 */
//登录成功
#define LOGIN_SUCCESSED             @"Login_Successed"

//字体大小
#define APP_FONTSIZE_CHANGED        @"App_Fontsize_Changed"
//当前文章切换
#define CURRENTARTICLE_CHANGED      @"CurrentArticle_Changed"


//新浪微博授权成功
#define SINA_AUTHORIZE_SUCCEED      @"SinaAuthorizeSucceed"

//频道 更新完成
#define CATEGORY_UPDATED            @"Category_updated"
//选择一个频道
#define RECOMMEND_CATEGORY_SELECTED  @"Category_Selected"

#define NAV_TO_RECOMMENDVIEW        @"NavToRecommendView"

//批量删除收藏通知
#define FAVORITE_DELETE             @"FavoriteDelete"
#define FAVORITEEDIT_COMPLETE       @"FavoriteEdit_complete"
//收藏列表进入编辑状态
#define FAVORITE_INTOEDITSTATE      @"Favorite_EditState"

//主屏变化通知，由点击或划动右边栏进入了相应的模块时触发
//导航栏获得事件后调整导航新状态
#define MAINSCREEN_CHANGED          @"MainScreen_Changed"

//刷新按钮点击通知
#define REFRESHBUTTON_TAPPED        @"RefreshButton_Tapped"
//刷新按钮可用通知（在刷新动作没有完成之前不能再次点击）
#define REFRESHBUTTON_ENABLED       @"RefreshButton_Enabled"

//成功获取了权限的通知
#define    GETAUTHORITY_COMPLETED   @"GetAuthority_Success"

#define LOGIN_BUTTON_TAPPED         @"LoginButtonTapped"

#define REGISTER_BUTTON_TAPPED      @"RegisterButtonTapped"


//开始下载
#define  MAG_DOWNLOAD_BEGIN           @"MAG_Download_Begin"
//下载进度
#define  MAG_DOWNLOAD_PROGRESS        @"MAG_Download_progress"
//下载失败
#define  MAG_DOWNLOAD_ERROR           @"MAG_Download_ERROR"
//下载完成
#define  MAG_DOWNLOAD_COMPLETE        @"MAG_Download_COMPLETE"

#import <UIKit/UIKit.h>
#import <OWKit/OWBlockDefine.h> 

@interface LYGlobalConfig : NSObject

@property (nonatomic, strong) NSString *apiDomain;

@property (nonatomic, strong) NSString *userAccount;
@property (nonatomic, strong) NSString *userInfo;
//机构通道代码
@property (nonatomic, strong) NSString *unitCode;
//静态密钥
@property (nonatomic, strong) NSString *staticKey;
//
@property (nonatomic, strong) NSString *serviceName;

@property (nonatomic, strong) NSString *applicationID;

//刷新密钥
@property (nonatomic, copy) RefreshKey refreshKeyBlock;

//启用分享功能，默认不启用
@property (nonatomic, assign) BOOL    allowToShare;

/*
 要使用的文章详情页版本
 1：横翻上下篇，使用CoreText；
 2:坚翻上下篇，使用WebView;
 
 默认值是 1
 */
@property (nonatomic, assign) NSInteger     versionOfTheArticleDetailView;

//
@property (nonatomic, assign) UIStatusBarStyle  statusBarStyle;

+ (LYGlobalConfig *)sharedInstance;

@end
