//
//  DownloadingItem.h
//  OWReader
//
//  Created by gren light on 13-10-14.
//
//

#import <Foundation/Foundation.h>

@interface DownloadingItem : NSObject

@property (nonatomic,retain) NSString *bid;
@property (nonatomic, assign) BOOL downloaded;
@property (nonatomic, assign) float downloadProgress;

@end
