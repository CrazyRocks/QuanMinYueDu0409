//
//  VideoIcon.h
//  TestVideo
//
//  Created by grenlight on 14/10/26.
//  Copyright (c) 2014年 qikan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface VideoIcon : NSObject

//获取视频资源
+(UIImage *)getImage:(NSURL *)videoURL;


//获取音频资源
+(UIImage *)getMessageFromAudio:(NSURL *)audioURL;


@end
