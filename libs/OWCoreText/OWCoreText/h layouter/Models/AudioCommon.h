//
//  AudioCommon.h
//  OWCoreText
//
//  Created by grenlight on 14/10/28.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AudioCommon : NSObject

//正在播放的音频地址
@property (nonatomic, retain) NSURL *currentURL;

@property (nonatomic, retain) NSString *currentName;

+(AudioCommon *)sharedInstance;

@end
