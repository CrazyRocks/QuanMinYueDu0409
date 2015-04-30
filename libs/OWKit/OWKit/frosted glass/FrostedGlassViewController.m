//
//  FrostedGlassViewController.m
//  PublicLibrary
//
//  Created by grenlight on 13-12-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "FrostedGlassViewController.h"
#import "UIImage+ImageEffects.h"

@interface FrostedGlassViewController ()

@end

@implementation FrostedGlassViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.backgroundView = [[FrostedGlassBackgroundView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)generateFrostedGlassImage
{
    __unsafe_unretained FrostedGlassViewController *weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        if (isiOS7) {
            UIImage *image = [self captureViewImage];
            image = [image applyDarkEffect];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.backgroundView.imageView setImage:image];
            });
        }
    });
}

@end
