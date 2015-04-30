//
//  LYGlobalDefine.h
//  LYMagazineService
//
//  Created by grenlight on 13-12-26.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#define EMAIL_REG_PLACEHOLDER      @"填写电子邮箱"
#define NICKNAME_REG_PLACEHOLDER   @"设置一个昵称"
#define PWD_REG_PLACEHOLDER        @"设置一个密码"
#define EMAIL_LOGIN_PLACEHOLDER    @"电子邮箱地址"
#define PWD_LOGIN_PLACEHOLDER      @"密码"
#define BT_LOGIN_LABEL             @"     使用微博帐号注册"
#define BT_REG_LABEL               @"使用现有帐号登录"


/*
 error--------------------------------------------------------------------------
 */
#define GET_ARTICLEDETAIL_ERROR      @"获取文章失败！"


/*
 新浪微博接口--------------------------------------------------------------------------
 */
#define kSinaWeiBoAppKey     @"37737484"
#define kSinaWeiBoAppSecret  @"a3b41b78478f0cc5348e301ff49457fe"

#define kWBAuthorizeURL      @"https://api.weibo.com/oauth2/authorize"
#define kWBAccessTokenURL    @"https://api.weibo.com/oauth2/access_token"

#define SINA_API_DOMAIN      @"https://api.weibo.com/2/"
//读取用户信息
#define SINA_API_USERINFO    SINA_API_DOMAIN@"users/show.json"
// 拉取联系人列表
#define SINA_API_FRIENDS     SINA_API_DOMAIN@"friendships/friends.json"
//写微博
#define SINA_API_UPDATE      SINA_API_DOMAIN@"statuses/update.json"
//写微博(带图片）
#define SINA_API_UPLOAD      SINA_API_DOMAIN@"statuses/upload.json"

/*
 龙源 接口--------------------------------------------------------------------------
 */
#define LONGYUAN_APP_KEY                  @"afddb3de74bbd56c1c7170773e96e962"
#define LONGYUAN_APP_SECRET               @"c736953b08dd68a68e400f7e887110e7"

//刷新文章列表的最多条数限制
#define ARTICLELIST_FATCHLIMIT            30

#define DEFAULT_TOKEN                     @"C/DYejbl2iw2Cy7Xdragon2012EoKpTv6cr9ofZKf3IXfH0O9v13Ieev3rJUBgJlK7aRzPFryauSxS833Wfsdragon2014"

//正式环境
#define LONGYUAN_DOMAIN                  ([LYGlobalConfig sharedInstance].apiDomain)
//登录用的
#define LONGYUAN_LOGIN_DOMAIN                 @"http://dps.qikan.com/"

//测试环境
//#define LONGYUAN_SERVER                   @"http://mobile1.qikan.com/DragonEssenceApp"

//统一认证
#define LONGYUAN_AUTHLOGIN_API                [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/AuthLogin.ashx?"]


//注册   Register.ashx? loginname =xxx&password=xxx&email=xxx&mobile=xxx
#define LONGYUAN_REGISTER_API             [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/Register.ashx?loginname=%@&password=%@&email=%@&mobile=%@"]
//登录   http://*/Login.ashx?loginname=xx&password=xxx&clientid=xxx
#define LONGYUAN_LOGIN_API                [NSString stringWithFormat:@"%@%@",LONGYUAN_LOGIN_DOMAIN, @"api/user/Login"]

//修改密码 POST
#define MODIFY_PWD_API                [NSString stringWithFormat:@"%@%@",LONGYUAN_LOGIN_DOMAIN, @"api/user/ChangePassword"]

//获取用户有阅读权限的单位列表接口
#define LONGYUAN_UNIT_LIST                [NSString stringWithFormat:@"%@%@",LONGYUAN_LOGIN_DOMAIN, @"api/user/GetUnitList?"]

//单位服务列表
#define LONGYUAN_SERVICE_LIST             [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/unit/GetServices?"]

//服务使用权限
#define LONGYUAN_SERVICE_TICKET            [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/unit/GetServiceTicket?"]

//获取各单位管理客户端左侧滑菜单项目
#define GET_UNIT_MENU           [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/menu/GetAll?"]


//资源分类   kind=6是文章，3是图书，2是期刊
#define LONGYUAN_CATEGORY_API   [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/category/GetAllByKind?"]
//文章列表 categorycode，itemcount
#define LONGYUAN_ARTICLE_LIST_API       [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/compilation/article/catalog?"]

//文章
#define LONGYUAN_ARTICLEDETAIL_API       [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/compilation/article/GetDetail?"]


/*
 获取收藏列表时传:100
 
 在资讯下收藏一篇文章传：103
 在杂志下收藏一篇文章传：101
 */

//添加收藏  ?
#define LONGYUAN_ADD_FAVORITE_API         [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/user/favorite/add?"]

//是否已收藏
#define IS_FAVORITE_API         [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/user/favorite/IsFavorite?"]

//取消收藏
#define LONGYUAN_DELETE_FAVORITE_API        [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/user/favorite/remove?"]
//收藏列表
#define LONGYUAN_FAVORITE_SYNC             [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/user/favorite/GetList?"]

/*
 图书相当接口-------------------------------------------------------------------
 */
//图书分类 kind=3

//图书列表
#define LONGYUAN_BOOK_LIST          [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/book/GetBookByCategory?booktype=5"]

//图书详情
#define LONGYUAN_BOOK_DETAIL         [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/book/GetBasicInfo?"]

//图书下载地址
#define GET_BOOK_DOWNLOAD_URL         [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/book/Download?"]


//期刊流

//期刊分类 kind=2

//期刊列表
#define LONGYUAN_MAGAZINE_LIST_API    [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/magazine/GetMagazineByCategory?"]

//基本信息: magazineguid
#define MAGAZINE_INFO_API        [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/magazine/GetBasicInfo?"]

//所有发行年份列表：magazineguid，magazinetype，
#define MAGAZINE_YEAR_LIST_API        [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/magazine/GetAllYear?"]

//期刊的期列表：magazineguid，magazinetype，year
#define MAGAZINE_ISSUE_LIST_API        [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/magazine/GetMagazineIssues?"]


//获取期刊目录
#define LONGYUAN_MAGAZINE_CATELOGUE_API   [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/magazine/article/catalog?"]

//期刊文章详情
#define MAGAZINE_ARTICLE_DETAIL_API    [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/magazine/article/GetDetail?"]

//我的订阅
#define LONGYUAN_ORDER_LIST_API        [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/GetMagazineOrderList.ashx?"]

//关注期刊 resourceking=2
#define LONGYUAN_MAGAZINE_FOCUS_API        [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/user/concern/add?"]
//是否已关注
#define MAGAZINE_ISFOCUSED_API        [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/user/concern/IsConcern?"]

//取消关注 id=关注编号
#define LONGYUAN_MAGAZINE_DISFOCUS_API        [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/user/concern/remove?"]
//关注列表
#define LONGYUAN_MAGAZINE_FOCUSLIST_API        [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/user/concern/GetList?"]


//搜索接口
#define LONGYUAN_ARTICLESEARCH_API        [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/compilation/article/search?"]
//杂志搜索
#define LONGYUAN_MAGAZINESEARCH_API       [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/magazine/search?"]
//图书搜索
#define LONGYUAN_BOOKSEARCH_API       [NSString stringWithFormat:@"%@%@",LONGYUAN_DOMAIN, @"/api/book/search?"]




#import <Foundation/Foundation.h>

@interface LYGlobalDefine : NSObject

@end
