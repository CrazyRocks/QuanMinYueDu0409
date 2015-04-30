//
//  KWFBootItemData.h
//  OWReader
//
//  Created by gren light on 12-11-3.
//
//

#import <Foundation/Foundation.h>


@interface LYBookItemData : NSObject
{
    
}

@property(nonatomic,retain)NSString *bGUID;

@property(nonatomic,retain)NSString *productID;
@property(nonatomic,assign) BOOL purchased;
@property (nonatomic, assign) BOOL downloaded;
@property (nonatomic, assign) float downloadProgress;

@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *type;
@property(nonatomic,retain)NSString *cover;
@property(nonatomic,retain)NSString *author;
@property(nonatomic,retain)NSNumber *price;
@property (nonatomic, retain) NSString *downloadUrl;


@property(nonatomic,retain)NSString *label;//标签
@property(nonatomic,retain)NSString *designedBy;
@property(nonatomic,retain)NSString *proofreader;//校对
@property(nonatomic,retain)NSNumber *wordcount;


@property(nonatomic,retain)NSString *categoryID;
@property(nonatomic,retain)NSString *categoryName;

@property(nonatomic,retain)NSString *summary;
@property(nonatomic,retain)NSDate   *publishTime;
@property(nonatomic,retain)NSString *publishName;//发行商
@property(nonatomic,retain)NSNumber *expireIn;//过期时间 /天
@property(nonatomic,retain)NSString *expireMessage;//过期提示信息

@property(nonatomic,retain)NSString *copyright;
@property (nonatomic, retain) NSArray *catalogue;

//图书馆信息
@property(nonatomic,retain)NSString *unitName;
@property(nonatomic,retain)NSString *uniteDomain;

//杂志信息
@property(nonatomic,retain)NSNumber *year;
@property(nonatomic,retain)NSNumber *issue;
@property(nonatomic,retain)NSString *issueString;

@property(nonatomic,assign)BOOL isBookMode;

//书本属性 0 = 全本 ；1 = 连载
@property (nonatomic, retain) NSNumber * bookAttribute;

@property (nonatomic, retain) NSString * bookJRID;

@property (nonatomic, retain) NSString * bookType;

@property (nonatomic, retain) NSString * opesPath;

@property(nonatomic,retain)NSString *ISBN;

@end
