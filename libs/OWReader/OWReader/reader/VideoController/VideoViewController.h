//
//  VideoViewController.h
//  LYBookStore
//
//  Created by grenlight on 14/10/27.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "JRReaderNotificationName.h"
@interface VideoViewController : UIViewController

@property (nonatomic, retain) MPMoviePlayerController *player;


-(void)setURL:(NSString *)URLStr;

@end
