//
//  VideoIcon.m
//  TestVideo
//
//  Created by grenlight on 14/10/26.
//  Copyright (c) 2014年 qikan. All rights reserved.
//

#import "VideoIcon.h"

@implementation VideoIcon

+(UIImage *)getImage:(NSURL *)videoURL
{
    
    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:videoURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMake(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc]initWithCGImage:image];
    
    return thumb;
}

+(UIImage *)getMessageFromAudio:(NSURL *)audioURL
{
    AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:audioURL options:nil];
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        
        
        for (NSString *format in [mp3Asset availableMetadataFormats]) {
            
            //                 NSLog(@"format type = %@",format);
            for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
                
//                NSLog(@"commonKey = %@",metadataItem.commonKey);
                //artwork这个key对应的value里面存的就是封面缩略图，其它key可以取出其它摘要信息，例如title - 标题
                if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                    
                    NSData *data = (NSData *)metadataItem.value;
                    
                    return [UIImage imageWithData:data];
                    
                    break;
                }
            }
        }
        
    }
    else
    {
        for (NSString *format in [mp3Asset availableMetadataFormats]) {
            
            //                 NSLog(@"format type = %@",format);
            for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
                
//                NSLog(@"commonKey = %@",metadataItem.commonKey);
                //artwork这个key对应的value里面存的就是封面缩略图，其它key可以取出其它摘要信息，例如title - 标题
                if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                    
                    NSDictionary *dic = (NSDictionary *)metadataItem.value;
                    
                    NSData *data = [dic objectForKey:@"data"];
                    
                    return [UIImage imageWithData:data];
                    
                    break;
                }
            }
        }
    }
    
    
    
    
    
    
    return nil;
}


@end
