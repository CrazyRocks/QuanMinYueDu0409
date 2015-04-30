//
//  MyBooksManager.h
//  KWFStore
//
//  Created by  iMac001 on 12-9-11.
//  Copyright (c) 2012年 kiwifish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyBook.h"
#import "LYBookItemData.h"
#import "ZipArchive.h"
#import <LYService/LYService.h>
#import <OWKit/OWBlockDefine.h> 

#define SPLIT_IN    @"SplitIn"
#define SPLIT_OUT   @"SplitOut"
#define SPLIT_OUT_NONANIMATION   @"SplitOutNonAnimation"

@class BSCoreDataDelegate;

@interface MyBooksManager : OWBasicHTTPRequest<ZipArchiveDelegate>
{
    MyBook                 *_currentReadBook;
    //本地所有的书
    NSArray                *allMyBooks;
    
    NSMutableArray          *purchasedBooks;
    
    BSCoreDataDelegate  *bsdd;
    
}
@property(nonatomic,retain)MyBook *currentReadBook;

+(MyBooksManager *)sharedInstance;

-(NSArray *)allMyBooks;

//通过书名来设置当前正在阅读的书
- (void)setReadBookByName:(NSString *)bn;

- (MyBook *)createABook:(LYBookItemData *)book  isSimple:(BOOL)bl;
- (void)updateBook:(MyBook *)book downloadingProgress:(float)progress;
- (void)bookDownloaded:(MyBook *)book;

- (void)clearAllBooks;
- (void)deleteBook:(MyBook *)book;

//默认赠书
- (void)present;

//PDF赠书
-(void)presentPDF;
#pragma mark 获取PDF路径
-(NSString *)getOpenPDFBookPath;
-(NSString *)getOpenIbookPath;

- (AFHTTPRequestOperation *)getBookList:(NSString *)cid
          pageIndex:(NSInteger)pageIndex
    successCallBack:(GLHttpRequstMultiResults)sCallBack
     failedCallBack:(GLHttpRequstFault)fCallBack;

- (void)getBookDetail:(NSString *)bid
    successCallBack:(GLHttpRequstResult)sCallBack
     failedCallBack:(GLHttpRequstFault)fCallBack;

//加解密
- (BOOL)encryptDESFile:(NSString *)input_path toPath:(NSString *)savePath;
- (BOOL)decryptDESFile:(NSString *)input_path toPath:(NSString *)savePath;
//base64加密
- (void)encryptFile:(NSString *)inputPath;
- (NSString *)decryptFile:(NSString *)inputPath;
- (UIImage *)decryptImage:(NSString *)inputPath;


- (NSData *)decryptDESFile:(NSString *)input_path;
- (NSString *)decryptDESFileToString:(NSString *)input_path;

//解压epub,入库
- (BOOL)unZipEpub:(NSString *)fromPath to:(NSString *)toPath;

//打开书
- (void)openBook:(MyBook *)book;
- (void)openBookByID:(NSString *)bookID;

/*
 记录阅读进度
 阅读进度记录总页码的百分比，具体的阅读位置需要记录章标识及在章节中的索引坐标
 */
- (void)saveReadProgress:(float)progress cid:(NSNumber *)cid position:(NSNumber *)pos;


//是否已下载
- (MyBook *)getBookByID:(NSString *)bookID;

//0:没下载，1:已下载，2：已过期
- (NSInteger)isDownloaded:(NSString *)bn;
//通过书名取得书的ID;
- (NSString *)getBookID:(NSString *)bn;

//设置继借
- (void)continueBorrow:(LYBookItemData *)bookData;




@end
