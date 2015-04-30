//
//  MyBooksManager.m
//  KWFStore
//
//  Created by  iMac001 on 12-9-11.
//  Copyright (c) 2012年 kiwifish. All rights reserved.
//

#import "MyBooksManager.h"
#import "BSCoreDataDelegate.h"
#import "MyBook.h"
#import "MyBooksManager.h"
#import "BSReaderViewController.h"
#import <OWCoreText/HTMLParser.h>
#import <OWCoreText/HTMLNode.h>
#import <CommonCrypto/CommonCryptor.h>
#import "zlib.h"
#import "Catalogue.h"
#import "Bookmark.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "LYBookConfig.h"
#import "JRReaderNotificationName.h"



static NSString *key = @"DSEPUB86";

@implementation MyBooksManager

@synthesize currentReadBook;

+(MyBooksManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static MyBooksManager *instance;

    dispatch_once(&onceToken, ^{
        instance = [[MyBooksManager alloc] init];
        [instance setup];
    });
    
    return instance;
}

- (void)setup
{
    purchasedBooks = [[NSMutableArray alloc] init];
    bsdd = [BSCoreDataDelegate sharedInstance];
}

-(NSArray *)allMyBooks
{
    return [self requestAllBooks];
}

- (void)setReadBookByName:(NSString *)bn
{
    [self allMyBooks];
    self.currentReadBook = [self getBookByName:bn];
}


-(void)setCurrentReadBook:(MyBook *)acurrentReadBook
{
    _currentReadBook = acurrentReadBook;
    _currentReadBook.accessDate = [NSDate date];
}

-(MyBook *)currentReadBook
{
    return _currentReadBook;
}

-(NSArray *)requestAllBooks
{
    __block NSArray *books ;
    [bsdd.parentMOC performBlockAndWait:^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        NSPredicate *predicate;
        //是否已更新UserID,没有的话，为旧数据加上UserID
        if ([defaults boolForKey:@"UserIDUpdated"]) {
            predicate = [NSPredicate predicateWithFormat:@"userID=%@", [LYAccountManager getUserName]];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"accessDate" ascending:NO];
        books = [[BSCoreDataDelegate sharedInstance] getCoreDataList:@"MyBook"
                                                           byContext:bsdd.parentMOC
                                                           predicate:predicate
                                                                sort:@[sortDescriptor]];
        if (![defaults boolForKey:@"UserIDUpdated"]) {
            for (MyBook *book in books) {
                book.userID = [LYAccountManager getUserName];
            }
            [defaults setBool:YES forKey:@"UserIDUpdated"];
            [defaults synchronize];
        }
        
        if ([defaults boolForKey:@"needReDownloadEpub"]) {
            for (MyBook *book in books) {
                book.isDownloaded = @(NO);
            }
        }
        [bsdd.parentMOC save:nil];
    }];
   
    allMyBooks = books;
    
    return books;
}

-(MyBook *)createABook:(LYBookItemData *)data isSimple:(BOOL)bl
{
    __block MyBook *book ;
    book = [self getBookByID:data.bGUID];
    
    if (book) {
        return book;
    }
    
    [bsdd.parentMOC performBlockAndWait:^{
        book = [NSEntityDescription insertNewObjectForEntityForName:@"MyBook"
                                                     inManagedObjectContext:bsdd.parentMOC];
        
        book.userID = [LYAccountManager getUserName];
        
        book.isBook = [NSNumber numberWithBool: data.isBookMode];
        book.unitName = data.unitName;
        book.unitDomain = data.uniteDomain;
        book.issueString = data.issueString;
        
        book.bookName = data.name;
        book.bookID = data.bGUID;
        book.categoryID = data.categoryID;
        book.author = data.author;
        book.downloadURL = data.downloadUrl;
        book.downloadingProgress = [NSNumber numberWithFloat:0.0f];
        book.isDownloaded = [NSNumber numberWithBool:NO];
        book.sortID = [NSNumber numberWithInt: 0];
        book.smallCover = data.cover;
        book.accessDate = [NSDate date];
        book.addDate = [NSDate date];
        book.isPageParsed = [NSNumber numberWithBool:NO];
        
        if ([LYBookConfig sharedInstance].bookShelfMode == lyBorrowMode) {
            NSInteger time = [[NSDate dateWithTimeIntervalSinceNow:[data.expireIn intValue]*24*60*60] timeIntervalSince1970];
            book.expiringDate = [NSNumber numberWithInteger:time];
        }
        else {
            book.expiringDate = @0;
        }
        
        book.expiringMessage = data.expireMessage;
        book.publishName = data.publishName;
        book.introduce = data.summary;
     //   NSLog(@"----%@-----",book.bookJRID);
        book.bookJRID = [[NSString alloc]initWithFormat:@"%@",data.bookJRID];
        book.bookType = data.bookType;
        book.opsPath = data.opesPath;
        
        
        [bsdd.parentMOC save:nil];
    }];
    [self requestAllBooks];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOKSHELF_CHANGED object:nil];
    
    return book;
}

- (void)updateBook:(MyBook *)book downloadingProgress:(float)progress
{
    [bsdd.parentMOC performBlock:^{
        book.downloadingProgress = [NSNumber numberWithFloat:progress];
    }];
}


#pragma mark 下载完成后设置opsPath
- (void)bookDownloaded:(MyBook *)book
{
    NSString *epubPath = [[[BSCoreDataDelegate sharedInstance] cacheDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.epub",book.bookID]];
    NSString *saveToPath = [[[BSCoreDataDelegate sharedInstance] cacheDocumentsDirectory] stringByAppendingPathComponent:book.bookID];
    
    BOOL result = NO;
    result = [self decryptDESFile:epubPath toPath:epubPath];
    if (!result) {
        [self showMessage:@"解密失败，下载的不是有效的epub文件"];
        return;
    }
    
    result = [self unZipEpub:epubPath to:saveToPath];
    if (!result) {
        [self showMessage:@"解压失败，下载的不是有效的epub文件"];
        return;
    }
    
#pragma mark 需要添加判断OPS
    
    NSString *opsPath, *catPath;
    
    if (book.opsPath == nil || [book.opsPath isEqualToString:@""]) {
        NSString *findSubString = [NSString stringWithFormat:@"%@/META-INF/container.xml",saveToPath];
        
        NSError *err;
        NSString *fineHtml = [NSString stringWithContentsOfFile:findSubString encoding:NSUTF8StringEncoding error:&err];
        //
        if (err) {
            NSLog(@"没找到container.xml文件：%@",err);
        }
        else {
            HTMLParser *parser = [[HTMLParser alloc] initWithString:fineHtml error:nil];
            HTMLNode * node = [[parser body] findChildrenWithTag:@"rootfile"][0];
            NSString *indexFilePath = (NSString *)[node getAttributeNamed:@"full-path"];
            opsPath = [indexFilePath componentsSeparatedByString:@"/"][0];

            NSString *contentHTML = [NSString stringWithContentsOfFile:
                                     [saveToPath stringByAppendingPathComponent:indexFilePath]
                                                              encoding:NSUTF8StringEncoding error:&err];
            parser = [[HTMLParser alloc] initWithString:contentHTML error:nil];
            catPath = [[[parser body] findChildWithTag:@"item" ] getAttributeNamed:@"href"];
        }
    }
    [bsdd.parentMOC performBlockAndWait:^{
        book.downloadingProgress = @1.0f;
        book.isDownloaded = [NSNumber numberWithBool:YES];
        book.opsPath = opsPath;
        book.catPath = catPath;
        [bsdd.parentMOC save:nil];
    }];
    
    //加密文件
    [self encryptBook:saveToPath];
}

- (void)encryptBook:(NSString *)inputPath
{
    NSError *error;
    NSArray *list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputPath error:&error];
    if (error) {
        NSLog(@"error:%@",error.description);
        return;
    }
    for (NSString *name in list) {
        if ([name componentsSeparatedByString:@"."].count >1 ) {
            [self encryptFile:[inputPath stringByAppendingPathComponent:name]];
        }
        else {
            [self encryptBook:[inputPath stringByAppendingPathComponent:name]];
        }
    }
}

- (void)showMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

- (LYBookItemData *)generateBookData:(NSString *)bid
{
    
//    NSLog(@"bid ==========%@",bid);
    
    LYBookItemData *bookData = [[LYBookItemData alloc] init];
    
    NSString *subString = [NSString stringWithFormat:@"present/%@/OEBPS/content.opf",bid];
    NSString *readmePath = [[NSBundle mainBundle].bundlePath
                            stringByAppendingPathComponent:subString];
    
    NSLog(@"%@",readmePath);
    
    NSError *error;
    
    NSString *html;
    
    NSString *base = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        
        //        NSLog(@"%@",html);
        
        HTMLParser *parser1 = [[HTMLParser alloc] initWithString:html error:&error];
        
        HTMLNode *metadata = [[parser1 doc] findChildWithTag:@"metadata"];
        
        bookData.name = [(HTMLNode *)[metadata findChildWithTag:@"title"] contents];
        bookData.author = [(HTMLNode *)[metadata findChildWithTag:@"creator"] contents];
        NSString *cover = [[metadata findChildWithAttribute:@"name" matchingName:@"cover" allowPartial:YES] getAttributeNamed:@"content"];
        
        bookData.cover = [[bsdd applicationDocumentsDirectory]
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/OPS/images/%@",bookData.bGUID, cover]];
        
        bookData.bookJRID = bid;
        
        return bookData;
        
    }
    else{
        
        html = base;
        
        HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error ];
        
        HTMLNode *metadata = [[parser doc] findChildWithTag:@"metadata"];
        
        bookData.name = [(HTMLNode *)[metadata findChildWithTag:@"title"] contents];
        bookData.author = [(HTMLNode *)[metadata findChildWithTag:@"creator"] contents];
        NSString *cover = [[metadata findChildWithAttribute:@"name" matchingName:@"cover" allowPartial:YES] getAttributeNamed:@"content"];
        
        bookData.cover = [[bsdd applicationDocumentsDirectory]
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/OEBPS/Images/%@",bookData.bGUID, cover]];
        
        bookData.bookJRID = bid;
        
        return bookData;
    }
    
}

- (void)present
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:@"present"]) {
        
        __block NSFileManager *fileManager = [NSFileManager defaultManager];
        __block NSString *presentPath, *targetPath;

        void(^generatePresent)(NSString *) = ^(NSString *bid){
            __block MyBook *book;
            
            LYBookItemData *bookData = [self generateBookData:bid];
            book = [self createABook:bookData isSimple:NO];
            
            
            [bsdd.parentMOC performBlockAndWait:^{
                book.downloadingProgress = [NSNumber numberWithFloat:1.0f];
                book.isDownloaded = [NSNumber numberWithBool:YES];
                [bsdd.parentMOC save:Nil];
            }];
            
            presentPath =
            [[NSBundle mainBundle].bundlePath
             stringByAppendingPathComponent:[NSString stringWithFormat:@"/present/%@",bid]];
            
            if ([fileManager fileExistsAtPath:presentPath]) {
                targetPath = [[bsdd cacheDocumentsDirectory]
                              stringByAppendingPathComponent:book.bookID];
                [fileManager copyItemAtPath:presentPath toPath:targetPath error:nil];
            }
        };
        
        for (uint i=1; i<4; i++) {
            generatePresent([NSString stringWithFormat:@"%i", i]);
        }

        [defaults setBool:YES forKey:@"present"];
        [defaults synchronize];
    }
}


- (void)clearAllBooks
{
    NSArray *list = [self allMyBooks];
    for (MyBook *book in list) {
        [self deleteBook:book];
    }
}

- (void)deleteBook:(MyBook *)book
{
    __block NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *bookPath = [[bsdd cacheDocumentsDirectory]
                          stringByAppendingPathComponent:book.bookName];
    
    if ([fileManager fileExistsAtPath:bookPath]) {
        [fileManager removeItemAtPath:bookPath error:nil];
    }
    
    
    [bsdd.parentMOC performBlock:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookID=%@", book.bookID];
        [bsdd deleteObjects:@"Bookmark" predicate:predicate sort:nil fetchOffset:0 fetchLimit:0];
        [bsdd deleteObjects:@"Catalogue" predicate:predicate sort:nil fetchOffset:0 fetchLimit:0];

        [bsdd.parentMOC deleteObject:book];
        [bsdd.parentMOC save:nil];
    }];
}


- (void)openBook:(MyBook *)book
{
    NSString *catchPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:book.bookName];
    [[NSUserDefaults standardUserDefaults] setObject:catchPath forKey:@"BundlePath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setCurrentReadBook:book];
    
    [[OWNavigationController sharedInstance]
     pushViewController:[[BSReaderViewController alloc] init]
     animationType:owNavAnimationTypeDegressPathEffect];
}

#pragma mark 获取PDF路径
-(NSString *)getOpenPDFBookPath
{
    if (_currentReadBook == nil) {
        NSLog(@"获取PDF路径失败，为空");
    }
    
    NSString *catchPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",_currentReadBook.bookID]];
    [[NSUserDefaults standardUserDefaults] setObject:catchPath forKey:@"BundlePath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    return catchPath;
}



-(NSString *)getOpenIbookPath;
{
    if(_currentReadBook==nil)
    {
        NSLog(@"获取PDF路径失败，为空");
    }
    NSString* catchPath=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:_currentReadBook.bookID];
    [[NSUserDefaults standardUserDefaults]setObject:catchPath forKey:@"BundlePath"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    return catchPath;
    
}






- (void)openBookByID:(NSString *)bookID
{
    [self allMyBooks];
    for (MyBook *book in allMyBooks) {
        if([book.bookID isEqualToString:bookID]) {
            [self openBook:book];
            return;
        }
    }
}

- (MyBook *)getBookByID:(NSString *)bookID
{
    for (MyBook *book in allMyBooks) {
        if ([book.bookID isEqualToString:bookID]) {
            return book;
        }
    }
    return nil;
}

- (MyBook *)getBookByName:(NSString *)bn
{
    for (MyBook *book in allMyBooks) {
        if ([book.bookName isEqualToString:bn]) {
            return book;
        }
    }
    return nil;
}

- (void)saveReadProgress:(float)progress cid:(NSNumber *)cid position:(NSNumber *)pos
{    
    [bsdd.parentMOC performBlock:^{
        self.currentReadBook.lastReadCID = cid;
        self.currentReadBook.lastReadPosition = pos;
        self.currentReadBook.readProgress = [NSNumber numberWithFloat:progress];
        
        [bsdd.parentMOC save:nil];
    }];
}



- (NSInteger)isDownloaded:(NSString *)bGUID
{
    [self allMyBooks];
    MyBook *book = [self getBookByID:bGUID];
    if (book) {
        NSInteger expireIn = [book.expiringDate integerValue];
        
        NSInteger   currentDate = [[NSDate date] timeIntervalSince1970];
        if ((expireIn > 0) && (currentDate > expireIn)) {
            return 2;
        }
        return [book.isDownloaded boolValue];
    }
    return 0;
}

- (void)continueBorrow:(LYBookItemData *)bookData
{
    for (MyBook *book in allMyBooks) {
        if ([book.bookID isEqualToString:bookData.bGUID]){
            [bsdd.parentMOC performBlockAndWait:^{
                NSInteger time = [[NSDate dateWithTimeIntervalSinceNow:[bookData.expireIn intValue]*24*60*60] timeIntervalSince1970];
                book.expiringDate = [NSNumber numberWithInteger:time];
                
                [bsdd.parentMOC save:nil];
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:BOOKSHELF_CHANGED object:nil];
        }
    }
}

#pragma mark 加解密，解压
- (void)encryptFile:(NSString *)inputPath
{
    NSData *textData = [NSData dataWithContentsOfFile:inputPath];
    NSString *encryptedStr = [textData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    [[NSFileManager defaultManager] removeItemAtPath:inputPath error:nil];
    [encryptedStr writeToFile:inputPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)decryptFile:(NSString *)inputPath
{
    NSString *text = [NSString stringWithContentsOfFile:inputPath encoding:NSUTF8StringEncoding error:nil];
    NSData *textData = [[NSData alloc] initWithBase64EncodedString:text options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    return [[NSString alloc] initWithData:textData encoding:NSUTF8StringEncoding];
}

- (UIImage *)decryptImage:(NSString *)inputPath
{
    NSString *text = [NSString stringWithContentsOfFile:inputPath encoding:NSUTF8StringEncoding error:nil];
    NSData *imgData = [[NSData alloc] initWithBase64EncodedString:text options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:imgData];
}

- (BOOL)encryptDESFile:(NSString *)input_path  toPath:(NSString *)savePath
{
    BOOL succeed=NO;
    
    NSData *textData = [NSData dataWithContentsOfFile:input_path];
    if (textData) {
        NSInteger d = [textData length]%8;
        NSMutableData* cipherData = [NSMutableData dataWithLength:[textData length] + (8-d)];
        
        size_t numBytesEncrypted = 0;
        
        unsigned char iv[kCCBlockSizeDES];
                
        CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                              kCCOptionPKCS7Padding,
                                              [key UTF8String], kCCKeySizeDES,
                                              iv,
                                              [textData bytes]  , [textData length],
                                              cipherData.mutableBytes, [cipherData length],
                                              &numBytesEncrypted);
        if (cryptStatus == kCCSuccess) {
            [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
            BOOL saved = [cipherData writeToFile:savePath atomically:YES];
            if (saved) {
                succeed=YES;
            }
            else {
                NSLog(@"写入文件失败!");
            }
        }
        else{
            NSLog(@"加密失败!");
        }
    }
    return succeed;
}

- (BOOL)decryptDESFile:(NSString *)input_path toPath:(NSString *)savePath
{
    NSData *outData = [self decryptDESFile:input_path];
    if (outData) {
        [outData writeToFile:savePath atomically:YES];
        return true;
    }
    return false;
}

- (NSString *)decryptDESFileToString:(NSString *)input_path
{
    NSData *outData = [self decryptDESFile:input_path];
    if (outData) {
        NSString *tempPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"1.temp" ];
        [outData writeToFile:tempPath atomically:YES];
        NSError *error;
        NSString *resultStr = [NSString stringWithContentsOfFile:tempPath encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"8888 %@ 8888", resultStr);
        if (error) {
            NSLog(@"%@",error);
        }
        return resultStr;
    }
    return @"";
}

- (NSData *)decryptDESFile:(NSString *)input_path
{
    //减小内存占用
    NSData *sourceData = [NSData dataWithContentsOfFile:input_path options:NSDataReadingMappedIfSafe error:nil];

    NSMutableData *plainData = [NSMutableData dataWithLength:(sourceData.length + kCCBlockSizeDES)];
    
    size_t numBytesDecrypted = 0;
    
    const char *iv = [key UTF8String];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          0,
                                          //                                          kCCOptionPKCS7Padding | kCCModeCBC,
                                          //kCCModeCBC|0x0000,
                                          //                                          kCCOptionECBMode|kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          [sourceData bytes], sourceData.length,
                                          [plainData mutableBytes], plainData.length,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSMutableData dataWithBytes:plainData.mutableBytes length:numBytesDecrypted];
        return resultData;
    }
    return nil;
}

- (BOOL)unZipEpub:(NSString *)fromPath to:(NSString *)toPath
{
    ZipArchive *zip = [[ZipArchive alloc] init];
    zip.delegate = self;
    
    BOOL result;
    if ([zip UnzipOpenFile:fromPath]) {
        result = [zip UnzipFileTo:toPath overWrite:YES];
        [zip UnzipCloseFile];
        if (!result) {
            NSLog(@"解压失败");
            return NO;
        }
        NSFileManager *fManager = [NSFileManager defaultManager];
        NSError *error;
        [fManager removeItemAtPath:fromPath error:&error];
        if (error) {
            [fManager removeItemAtPath:fromPath error:&error];
        }
        return YES;
    }
    else {
        NSLog(@"无法解压：不是有效的zip文件");
        return NO;
    }
}

- (void)ErrorMessage:(NSString *)msg
{
    NSLog(@"error:%@",msg);
}

- (AFHTTPRequestOperation *)getBookList:(NSString *)cid
          pageIndex:(NSInteger)pageIndex
    successCallBack:(GLHttpRequstMultiResults)sCallBack
     failedCallBack:(GLHttpRequstFault)fCallBack
{
    NSDictionary *params = @{@"categorycode":cid,
                             @"pagesize":@"30",
                             @"pageindex":@(pageIndex),
                             @"itemcount":@(0)};
    
    return [CommonNetworkingManager GET:LONGYUAN_BOOK_LIST parameters:params completeBlock:^(NSDictionary *result) {
        NSArray *arr = result[@"Data"];
        NSInteger pageCount = ceilf([(NSNumber *)result[@"ItemCount"] integerValue] / 30.f);
        sCallBack(arr,pageCount);
    } faultBlock:^(NSString *msg) {
        if(fCallBack) fCallBack(msg);
    }];
}

- (void)getBookDetail:(NSString *)bid
      successCallBack:(GLHttpRequstResult)sCallBack
       failedCallBack:(GLHttpRequstFault)fCallBack
{
    [self cancelRequest];
    
    NSDictionary *params = @{@"bookguid":bid};
    httpRequest = [CommonNetworkingManager GET:LONGYUAN_BOOK_DETAIL parameters:params completeBlock:^(NSDictionary *result) {
        [[MyBooksManager sharedInstance] getDownloadURL:result[@"Data"]
                                        successCallBack:sCallBack
                                         failedCallBack:fCallBack];
    } faultBlock:^(NSString *msg) {
        if(fCallBack) fCallBack(msg);
    }];
}

- (void)getDownloadURL:(NSDictionary *)info
       successCallBack:(GLHttpRequstResult)sCallBack
        failedCallBack:(GLHttpRequstFault)fCallBack
{
    NSMutableDictionary *newInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    NSString *getCode;
    for (NSDictionary *item in info[@"BookTypes"]) {
        if ([item[@"BookType"] integerValue] == 5) {
            getCode = item[@"GetCode"];
            break;
        }
    }
    if (!getCode) {
        return;
    }
    [CommonNetworkingManager sycGET:GET_BOOK_DOWNLOAD_URL parameters:@{@"getCode":getCode} completeBlock:^(NSDictionary *result){
        [newInfo setObject:result[@"Data"] forKey:@"epubDonwloadURL"];
        sCallBack(newInfo);
    }faultBlock:^(NSString *msg){
        [newInfo setObject:@"" forKey:@"epubDonwloadURL"];
        sCallBack(newInfo);
    }];
    
}

#pragma mark PDF

#pragma mark PDF
-(void)presentPDF
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:@"PDF"]) {
        
        __block NSFileManager *fileManager = [NSFileManager defaultManager];
        __block NSString *presentPath, *targetPath;
        
        void(^generatePresent)(NSString *) = ^(NSString *bid){
            __block MyBook *book;
            
            LYBookItemData *bookData = [self generateBookPDFData:bid];
            
            book = [self createABook:bookData isSimple:NO];
            
            [bsdd.parentMOC performBlockAndWait:^{
                book.downloadingProgress = [NSNumber numberWithFloat:1.0f];
                book.isDownloaded = [NSNumber numberWithBool:YES];
                [bsdd.parentMOC save:Nil];
            }];
            
            presentPath =
            [[NSBundle mainBundle].bundlePath
             stringByAppendingPathComponent:[NSString stringWithFormat:@"/PDF/%@",bid]];
            
            if ([fileManager fileExistsAtPath:presentPath]) {
                
                targetPath = [[bsdd cacheDocumentsDirectory]
                              stringByAppendingPathComponent:book.bookID];
                
                [fileManager copyItemAtPath:presentPath toPath:targetPath error:nil];
            }
            
        };
        
        generatePresent([NSString stringWithFormat:@"svn指南.pdf"]);
        
        [defaults setBool:YES forKey:@"PDF"];
        [defaults synchronize];
    }
    
}

- (LYBookItemData *)generateBookPDFData:(NSString *)bid
{
    //    NSLog(@"bid ==========%@",bid);
    
    LYBookItemData *bookData = [[LYBookItemData alloc] init];
    
    bookData.name = bid;
    bookData.author = nil;
    bookData.cover = nil;
    bookData.bookJRID = bid;
    bookData.bookType = @"pdf";
    
    return bookData;
    
}



@end
