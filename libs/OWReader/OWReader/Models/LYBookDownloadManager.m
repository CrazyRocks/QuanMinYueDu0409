//
//  DownloadManager.m
//  OWReader
//
//  Created by gren light on 12-12-8.
//
//

#import "LYBookDownloadManager.h"
#import "MyBook.h"
#import "MyBooksManager.h"
#import <LYService/LYService.h>
#import "BSCoreDataDelegate.h"
#import "JRReaderNotificationName.h"

@implementation LYBookDownloadManager
//单例
+(LYBookDownloadManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static LYBookDownloadManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[LYBookDownloadManager alloc] init];
        [instance setup];
    });
    return instance;
}
//初始化
-(void)setup
{
    inQueueURLs = [[NSMutableSet alloc] init];
    downloadQueue = [[NSOperationQueue alloc] init];
    //设置队列最大数量
    downloadQueue.maxConcurrentOperationCount = 1;
    [downloadQueue setSuspended:NO];
}

-(void)dealloc
{
    [downloadQueue cancelAllOperations];
    [downloadQueue setSuspended:YES ];
}

- (void)download:(MyBook *)book
{
    //判断URL是否在下载队列URL 里
    if ([inQueueURLs containsObject:book.downloadURL]) return;
    
    //判断网络
    if (![CommonNetworkingManager sharedInstance].isReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"当前没有网络连接，无法完成下载" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [inQueueURLs addObject:book.downloadURL];
    NSMutableDictionary *info = [@{@"bookInfo":book} mutableCopy];

    [self downloadOperation:info];
}

-(void)downloadOperation:(NSMutableDictionary *)info
{
    currentDownloadingInfo = info;
    //添加通知
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_DOWNLOAD_BEGIN object:nil userInfo:info];
    
    __block MyBook *bookInfo = (MyBook *)info[@"bookInfo"];
    
    //创建下载路径
    NSString *saveFilePath = [[[BSCoreDataDelegate sharedInstance] cacheDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.epub",bookInfo.bookID]];
    
    AFURLConnectionOperation *operation = [[AFURLConnectionOperation alloc]
                                           initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:bookInfo.downloadURL]]];
    [downloadQueue addOperation:operation];
    
    [downloadQueue setSuspended:NO ];

    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        //算出下载的百分比
        float progress = (CGFloat)totalBytesRead / totalBytesExpectedToRead;
        
        MyBook *bookInfo = (MyBook *)currentDownloadingInfo[@"bookInfo"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MyBooksManager sharedInstance] updateBook:bookInfo downloadingProgress:progress];
            NSMutableDictionary *downloadInfo = [NSMutableDictionary dictionaryWithDictionary:info];
            [downloadInfo setValue:[NSNumber numberWithFloat:progress] forKey:@"progress"];
            [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_DOWNLOAD_PROGRESS object:nil userInfo:downloadInfo];
        });
    }];

    __unsafe_unretained LYBookDownloadManager *weakSelf = self;
    __weak AFURLConnectionOperation *weakOperation = operation;
   
    
    [operation setCompletionBlock:^{
        if ([weakOperation error]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"下载失败，可能是因为当前网络不太稳定，您可以稍后再下载" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
            [weakSelf->inQueueURLs removeObject:((MyBook *)info[@"bookInfo"]).downloadURL];
            [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_DOWNLOAD_ERROR object:nil userInfo:info];
            return ;
        }
        NSData *data = [[NSData alloc] initWithData:[weakOperation responseData]];
        [data writeToFile:saveFilePath atomically:YES];
        
        [[MyBooksManager sharedInstance] bookDownloaded:bookInfo];
        
        [weakSelf->inQueueURLs removeObject:((MyBook *)info[@"bookInfo"]).downloadURL];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_DOWNLOAD_COMPLETE object:nil userInfo:info];
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOKSHELF_CHANGED object:nil];
        
    }];
    
}


- (void)autoDownload
{
    [[UIApplication sharedApplication] canOpenURL:nil];
}

@end
