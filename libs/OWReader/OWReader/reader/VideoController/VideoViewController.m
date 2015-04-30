//
//  VideoViewController.m
//  LYBookStore
//
//  Created by grenlight on 14/10/27.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "VideoViewController.h"

@interface VideoViewController ()

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _player = [[MPMoviePlayerController alloc]init];
    
    _player.view.frame = CGRectMake(0, 0, appWidth, appHeight);
    
    _player.fullscreen = YES;
    
    _player.view.backgroundColor = [UIColor blackColor];
    
    [_player setControlStyle:MPMovieControlStyleFullscreen];
    
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        
        self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        self.view.frame = CGRectMake(0, 0, appHeight, appWidth);
        _player.view.frame = CGRectMake(0, 0, appHeight, appWidth);
        
        
    }else{
        
        _player.view.frame = CGRectMake(0, 0, appHeight, appWidth);
        
        [_player.view setTransform:CGAffineTransformMakeRotation(M_PI/2)];
        
        _player.view.center = CGPointMake(appWidth/2, appHeight/2);

    }
    
    

    
    
    [self.view addSubview:_player.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(done:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
}

-(void)done:(NSNotification *)notification
{
    
    if (notification.userInfo) {
      
        NSString *value = [notification.userInfo objectForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"];
        
        if ([value intValue] == 0) {
            
            
            
            
        }else if ([value intValue] == 2){
            
            
            [self dismissViewControllerAnimated:YES completion:^{
                
                
            }];
            
        }
        
    };
}

-(void)setURL:(NSString *)URLStr
{
    if (URLStr) {
        
//        NSLog(@"URLStr ===== %@",URLStr);
        
        _player.contentURL = [NSURL URLWithString:URLStr];
        
        [_player play];
        
        [self performSelector:@selector(update) withObject:nil afterDelay:0.5];
    }
}

-(void)update
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
