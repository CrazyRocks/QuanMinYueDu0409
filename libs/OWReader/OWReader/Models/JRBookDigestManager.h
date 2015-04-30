//
//  JRBookDigestManager.h
//  LYBookStore
//
//  Created by grenlight on 14-10-14.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookDigest.h"
#import "BSCoreDataDelegate.h"
#import <OWCoreText/GLCTPageInfo.h>
#import "MyBook.h"

@interface JRBookDigestManager : NSObject

@property (nonatomic, retain) NSMutableArray *currentBookDigest;
@property (nonatomic, retain) BookDigest *currentNeedSaveBookDigest;
@property (nonatomic, retain) BookDigest *currentNeedDeleteBookDigest;

+(JRBookDigestManager *)sharedInstance;


//存储书摘
-(BOOL)saveBookDigestsendRange:(NSRange)range DigestString:(NSString *)digestString PageInfo:(GLCTPageInfo *)pageInfo Catalogue:(NSString *)cat CatIndex:(NSNumber *)cid NumbersArray:(NSMutableArray *)numbersArray;

//存储笔记
-(BOOL)saveBookDigestsendRange:(NSRange)range DigestString:(NSString *)digestString PageInfo:(GLCTPageInfo *)pageInfo Catalogue:(NSString *)cat CatIndex:(NSNumber *)cid NumbersArray:(NSMutableArray *)numbersArray Note:(NSString *)note;


//获取当前阅读图书的所有摘要以及笔记
-(NSMutableArray *)loadThisBookDigestsAndNotes:(MyBook *)book;

-(BOOL)delegateThisBookDigestAndNotes:(BookDigest *)digest;


//更新
- (void)updateData:(BookDigest *)model;

//网络同步的模型存储方法
-(BOOL)BookDigestModelsToSave:(NSMutableArray *)array;


@end
