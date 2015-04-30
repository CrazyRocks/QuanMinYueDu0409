//
//  ContentManager.h
//  LogicBook
//
//  Created by iMac001 on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OWCoreText/OWCoreText.h>
#import "LYBookSliderController.h"

#import "LYBookPageScrollView.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>

#import "Catalogue.h"
#import "Bookmark.h"
#import "MyBook.h"
#import "MyBooksManager.h"
#import "BSCoreDataDelegate.h"
#import "SearchModel.h"

#import "ReadProessNetModel.h"

#import "LYBookSceneManager.h"

#import "BSGlobalAttri.h"

@class Catalogue, Bookmark;

//章节页面范围 、全局可访问页面范围
struct CataloguePageRange{
    NSInteger startPage;
    NSInteger endPage;
};

@interface LYBookRenderManager : NSObject<GLSliderDelegate>{
    @private
     NSInteger _currentPageNumber;
    
    NSArray *_catalogues;
    
    BOOL isChangeFont;
}

@property BOOL isChangeFont;


@property (nonatomic, weak)  LYBookPageScrollView *pageSV;

//目录字典
@property(nonatomic,retain)NSArray   *catalogues;
@property(nonatomic,retain)Catalogue *currentCatalogue;

//用于解析完页面后，自动渲染内容
@property(nonatomic,assign)int       currentCatalogueNavIndex;
//标识当前状态
@property(nonatomic,assign)BOOL       isContentMode;

//章节布局器 字典，以章节索引做为key
@property(nonatomic,retain)NSMutableDictionary *layouterDic;
@property(nonatomic,retain)NSMutableDictionary *pageInfos;

/*
 当前页码,改变当前页码时判断并预加载后继内容
*/
@property(nonatomic,assign)NSInteger currentPageNumber;


//文本字体字号渲染标识
@property (nonatomic, strong) NSString        *textRenderID;


/*
 应用的总页数，进入应用后如果总页数为0时需要先计算总页数
 确定了总页数，每一章的起始页码也就确定了
*/
@property(nonatomic,assign)NSInteger pageCount;


#pragma mark 是否同步进度属性～
@property BOOL isNeedChangePage;




+ (LYBookRenderManager *)sharedInstance;

- (void)parseCatalogue:(GLNoneParamBlock)block;

-(void)reset;

/*
 从目录进篇章 
 */
- (void)intoCatelogue:(Catalogue *)cat;

/*
 从书签进入指定页
 */
-(void)intoBookmark:(Bookmark *)bm;


/*
 从书摘进入指定页
*/
-(void)intoBookDigest:(BookDigest *)bd;




//从续读进入指定页
-(void)intoPage:(NSInteger)pn;

/*
 续读
 打开上次阅读的章节及位置
 */
- (void)continueRead;

/*
 改变当前字体样式
 1,清空当前的layouter
 2,生成新的layouter
 */
- (void)changeFontStyle;

//装载章节内容，由改变当前页码触发时将异步调用
//由目录触发时同步执行
- (OWCoreTextLayouter *)getLayouterByCatalogue:(Catalogue *)cat;
- (OWCoreTextLayouter *)generateLayouterByCat:(Catalogue *)cat;


//跟据页码计算所属章节
- (Catalogue *)calculateCatalogue_by_PageNumber:(NSInteger)pn;
- (Catalogue *)calculateCat:(NSInteger)lower :(NSInteger)upper :(NSInteger)pn ;

//初始化coretext
-(void)initCoreText;



//搜索
-(NSMutableArray *)searchBaseStringInAllCatalogs:(NSString *)baseString;

//跳转
-(void)intoBookSearch:(SearchModel *)model;

//网络加载进度跳转
-(void)intoBookLastReadWithReadNetModel:(ReadProessNetModel *)model;


-(void)updataPageNumber;

-(void)continueReadUnReloadCurrentPage;


@end
