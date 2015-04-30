//
//  DownloadManager.h
//  OWReader
//
//  Created by gren light on 12-12-8.
//
//

#import <Foundation/Foundation.h>

@protocol BookDownloadDelegate;
@class MyBook;

@interface LYBookDownloadManager : NSObject
{
    NSMutableSet       *inQueueURLs;
    NSOperationQueue   *downloadQueue;
    
    NSMutableDictionary *currentDownloadingInfo;
}

+(LYBookDownloadManager *)sharedInstance;

- (void)download:(MyBook *)book;

- (void)autoDownload;

@end

@protocol BookDownloadDelegate <NSObject>

@optional
-(void)downloadBegin:(uint)sortID;
-(void)downloadProgress:(float)newProgress;
-(void)downloadError:(NSError *)error;
-(void)downloadCompleteUnzipError;
-(void)downloadandUnzipComplete;
@end
