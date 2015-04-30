//
//  JRReaderNotificationName.h
//  JRReader
//
//  Created by grenlight on 14/11/14.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#ifndef JRReader_JRReaderNotificationName_h
#define JRReader_JRReaderNotificationName_h

#define EMAIL_REG_PLACEHOLDER @"填写电子邮箱"
#define NICKNAME_REG_PLACEHOLDER @"设置一个昵称"
#define PWD_REG_PLACEHOLDER @"设置一个密码"
#define EMAIL_LOGIN_PLACEHOLDER @"电子邮箱地址"
#define PWD_LOGIN_PLACEHOLDER @"密码"
#define BT_LOGIN_LABEL @"     使用微博帐号注册"
#define BT_REG_LABEL @"使用现有帐号登录"

/*
 color--------------------------
 */
//页脚字体颜色
#define PAGEFOOTER_COLOR 0x805122




/*
 user defaults keys ------------------------------------------------------------------
 */
//客户端类型
#define CLIENT_TYPE  @"Client_Type"
//书的标识
#define BOOK_ID @"Book_ID"
//用户在微博的唯一标识
#define WEIBO_ID @"WEIBO_ID"
//微博类型1：新浪微博  2：腾讯微博  3：豆瓣
#define WEIBO_TYPE @"WEIBO_TYPE"

//微博名
#define WEIBO_NAME @"WEIBO_NAME"
//此微博名是否已绑定
#define WEIBO_BINDING @"WEIBO_BINDING"
//用户大头像地址
#define AVATAR_LARGE @"Avatar_Large"
#define AVATAR_SMALL @"Avatar_Small"
//用户头像是否已上传
#define AVATAR_UPLOADED @"Avatar_Uploaded"
//昵称
#define LONGYUAN_NAME @"LongYuan_NickName"
#define LONGYUAN_PWD @"LongYuan_Pwd"
//注册邮箱
#define LONGYUAN_EMAIL @"LongYuna_Email"
//当前页码，为0时打开目录页
#define CURRENT_PAGE @"Current_Page"




/*
 ---  通知名称 -----------------------------------------------------------------------
 */
/*
 通知 ..........................................................
 */

//开始下载
#define  BOOK_DOWNLOAD_BEGIN           @"Book_Download_Begin"
//下载进度
#define  BOOK_DOWNLOAD_PROGRESS        @"Book_Download_progress"
//下载失败
#define  BOOK_DOWNLOAD_ERROR           @"Book_Download_ERROR"
//下载完成
#define  BOOK_DOWNLOAD_COMPLETE        @"Book_Download_COMPLETE"

//书架更新通知
#define  BOOKSHELF_CHANGED              @"Bookshelf_Changed"
#define  BOOKSHELF_SHOW_SEARCHBAR       @"Bookshelf_Show_SearchBar"
#define  BOOKSHELF_HIDE_SEARCHBAR       @"Bookshelf_Hide_SearchBar"

//书签列表改改（如：添加了书签,删掉了书签）
#define  LYBOOK_BOOKMARK_CHANGED        @"LYBook_Bookmark_Changed"

//返回书架通知
#define  BOOK_BACKTO_BOOKSHELF          @"Book_BackTo_Bookshelf"
//打开目录
#define  BOOK_OPEN_CATALOGUE            @"Book_Open_Catalogue"
//加载目录
#define  BOOK_LOAD_CATALOGUE            @"Book_Load_Catalogue"
//移除目录
#define  BOOK_REMOVE_CATALOGUE            @"Book_Remove_Catalogue"

//打开内容
#define BOOK_OPEN_CONTENT               @"Book_Open_Content"
//打开搜索
#define  BOOK_OPEN_SEACH           @"Book_Open_seach"


//当前页码改变
#define BOOK_PAGENUM_CHANGED    @"Book_PageNumber_Changed"


//调整字号
#define    BOOK_FONTSIZE_CHANGEING     @"Book_Fontsize_changing"

//场景切换（白天、夜间...）
#define    BOOK_SCENE_CHANGED     @"Book_Scene_changed"

//开如计算页码
#define    BOOK_PARSER_BEGAIN       @"Book_Parser_begain"
//解析进度
#define     BOOK_PARSER_PROGRESS        @"Book_PARSER_progress"
//页码解析完成
#define    BOOK_PARSER_COMPLETE     @"Book_Parser_complete"

#define  BOOK_NOTES_EDITOR @"book_notes_editor"



#define appWidth   [[UIScreen mainScreen] bounds].size.width
#define appHeight  [[UIScreen mainScreen] bounds].size.height




#endif
