//
//  ArticleTableCellData.h
//  LongYuan
//
//  Created by gren light on 12-6-19.
//  Copyright (c) 2012年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYArticleTableCellData : NSObject
{
    BOOL _searchedReadState; //是否已查询过已读
    BOOL _alreadyRead;
    float _cellHeight;
}

@property(nonatomic,retain)NSString *titleID;
@property(nonatomic,retain)NSString *favoriteID;

@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *summary;
@property(nonatomic,retain)NSString *author;

//image info
@property(nonatomic,retain)NSString *thumbnailURL;
@property (nonatomic, retain) NSNumber * thumbnailWidth;
@property (nonatomic, retain) NSNumber * thumbnailHeight;
//在屏幕上显示的最终高度
@property (nonatomic, assign) float      thumbnailScreenHeight;

//这个时间用于在客户端安时间分组呈现
@property(nonatomic,retain)NSString *publishDateSection;
@property(nonatomic,retain)NSDate   *publishDate;

@property(nonatomic,retain)NSString *categoryID;

//所属杂志的信息
@property(nonatomic,retain)NSString *magName;
@property(nonatomic,retain)NSString *magGUID;
@property(nonatomic,retain)NSString *magYear;
@property(nonatomic,retain)NSString *magIssue;
@property(nonatomic,retain)NSString *magazineIcon;
@property (nonatomic, retain) NSString *sectionName;
@property (nonatomic, retain) NSString *cycle;//刊类型，如：半月刊
@property (nonatomic, retain) NSString *magazineCategory;//刊所属分类

@property(nonatomic, strong) NSArray *images;

//列表项编辑新状态
@property(nonatomic,assign)BOOL  isEditMode;
@property(nonatomic,assign)BOOL  willDeleted;

/*
 已读信息
 是否是已读
 */
@property(nonatomic,assign)BOOL alreadyRead;

@property (nonatomic, assign) CGRect    textRect;

//使用UILabel分别显示标题和摘要,不使用OWCoreText
@property(nonatomic,assign) float titleLabelHeight;
@property(nonatomic,assign) float summaryLabelHeight;
@property(nonatomic,assign) float labelCellHeight;

- (float)labelCellHeight:(float)thumbnailScreenWidth;

- (float)cellHeight;
- (void)setCellHeight:(float)value;

- (NSString *)generateHTML;

- (CGSize)string:(NSString *)str sizeWithFont:(UIFont *)font width:(float)width;

@end
