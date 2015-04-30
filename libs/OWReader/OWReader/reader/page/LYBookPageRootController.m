//
//  LYBookPageScrollController.m
//  LYBookStore
//
//  Created by grenlight on 14-4-28.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYBookPageRootController.h"
#import "LYBookPageScrollView.h"
#import "LYBookRenderManager.h"
#import "LYBookNavigationBarController.h"
#import "LYBookSliderController.h"
#import <OWKit/OWShimmeringView.h>
#import "MyBooksManager.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>
//#import "GLNotificationName.h"

#import "LYBookSceneManager.h"

#import "JRReaderNotificationName.h"

#import <OWCoreText/AudioCommon.h>

#import "SearchViewController.h"

#import "NetworkSynchronizationForBook.h"

@interface LYBookPageRootController ()
{
    LYBookPageScrollView    *contentView;
        
    BOOL    showedNavigationBar;

    OWShimmeringView     *shimmeringView;
    
    
    CGRect musicBtnRect;
    
    CGPoint musicPoint;
    
    CGPoint center;
    
    CGPoint musicCenter;
    
}
@end

@implementation LYBookPageRootController

@synthesize sliderController, navBarController;

- (id)init
{
    if (self=[super init]) {
        isFontChanging = NO;
        
        __weak typeof (self) weakSelf = self;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_BACKTO_BOOKSHELF object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf hideAccessory];
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_OPEN_CATALOGUE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf hideAccessory];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_PARSER_COMPLETE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf bookParseComplete];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_PARSER_BEGAIN object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf fontChangeBegain];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSearch:) name:BOOK_OPEN_SEACH object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(intoVideo:) name:@"intoVideo" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAudio:) name:@"AddAudio" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAudio:) name:@"removeAudio" object:nil];
        
//        //新增打开编辑通知
//        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_NOTES_EDITOR object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
//            [weakSelf callNotesViewShow:note];
//        }];
        
        sliderController = [[LYBookSliderController alloc] init];
        navBarController = [[LYBookNavigationBarController alloc] init];
    }
    return self;
}


- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appWidth, appHeight)];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    center = self.view.center;
    
    contentView = [[LYBookPageScrollView alloc] initWithFrame:self.view.bounds];
    contentView.parentController = self;
    
    [self.view addSubview:contentView];
    
    [LYBookRenderManager sharedInstance].pageSV = contentView;
    
    [self addAccessory];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSceneMode) name:BOOK_SCENE_CHANGED object:nil];
    
#pragma mark 添加音乐界面显示按钮
    
    musicBtnRect = CGRectMake(self.view.frame.size.width - 45, self.view.frame.size.height, 40, 40);
    musicPoint = CGPointMake(self.view.frame.size.width - 45, self.view.frame.size.height - 50);
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       
        NetworkSynchronizationForBook *manager = [NetworkSynchronizationForBook manager];
        
        [manager getCurrentBookProgressFromSever];
        
    });
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NetworkSynchronizationForBook *manager = [NetworkSynchronizationForBook manager];
        
        [manager getBookDigestListFromSever];
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       
        NetworkSynchronizationForBook *manager = [NetworkSynchronizationForBook manager];
        
        [manager getBookMarkListFromSever];
        
    });
    
}

#pragma mark 音乐界面控制代理方法
-(void)stopMusicAction
{
    
    [_musicBtn.halo removeAnimationAll];
    
    [UIView animateWithDuration:0.4 animations:^{
        _musicBtn.center = musicPoint;
    } completion:^(BOOL finished) {

        if (finished) {
            
            
            [UIView animateWithDuration:1 animations:^{
                _musicBtn.frame = musicBtnRect;
            } completion:^(BOOL finished) {
                
                if (finished) {
                    
                   [_musicBtn setHidden:YES];
                }
            }];
        }
        
    }];
    
}

-(void)pauMusicAction
{
    [_musicBtn setHidden:NO];
    
    [OWAnimator basicAnimate:_musicBtn toScale:CGPointZero duration:0.5f delay:0 completion:^{
        
        [OWAnimator spring:_musicBtn toScale:CGPointMake(1, 1) delay:0];
        
    }];
    
}


#pragma mark 音乐按钮点击事件
-(void)showView:(MusicControlBtn *)sender
{
    
    musicCenter = sender.center;
    
    [UIView animateWithDuration:0.4 animations:^{
        
        sender.center = center;
        sender.layer.cornerRadius = 0;
        
        
    } completion:^(BOOL finished) {
        
        _audioCtrl.endPoint = musicCenter;
        [_audioCtrl showViewAnimation];
        [sender setHidden:YES];
        
        sender.center = musicCenter;
        
    }];
}


-(void)addAudio:(NSNotification *)notification
{
    
    if (_musicBtn != nil) {
        
        [_audioCtrl.player stop];
        
        [_audioCtrl.view removeFromSuperview];
        
        _audioCtrl = nil;
        
        [_musicBtn removeFromSuperview];
        
        _musicBtn = nil;
    }
    
    _audioCtrl = [[AudioViewController alloc]initWithNibName:nil bundle:nil];
    _audioCtrl.delegate = self;
    [self.view addSubview:_audioCtrl.view];
    
    _musicBtn = [[MusicControlBtn alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 45, self.view.frame.size.height, 60, 60)];
    
    _musicBtn.delegate = self;
    
    [self.view addSubview:_musicBtn];
    
    NSURL *url = [AudioCommon sharedInstance].currentURL;
    
    [_audioCtrl setPlayerURL:url];
    
    [_musicBtn setImageViewIcon:url];
    
    [_musicBtn autoPlay];
    
    [OWAnimator basicAnimate:_musicBtn toScale:CGPointZero duration:0.5f delay:0 completion:^{
        
        [OWAnimator spring:_musicBtn toScale:CGPointMake(1, 1) delay:0];
        
    }];
    
    [UIView animateWithDuration:1 animations:^{
        
        _musicBtn.center = musicPoint;
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            
            
            [UIView transitionWithView:_musicBtn duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft+UIViewAnimationOptionCurveEaseInOut animations:^{
                
            } completion:^(BOOL finished) {
                
                [_musicBtn.halo setupAnimationGroup];
                
            }];
            
        }
        
        
    }];
    
}

-(void)removeAudio:(NSNotification *)notification
{
    
    [_musicBtn.halo removeAnimationAll];
    
    [_musicBtn stopAnimation];
    
    if (_musicBtn) {
        [_musicBtn removeFromSuperview];
        _musicBtn = nil;
    }
    
    [AudioCommon sharedInstance].currentURL = nil;
    
    [_audioCtrl stopBtnAction:nil];
}


-(void)intoVideo:(NSNotification *)notification
{
    if (!_video) {
        _video = [[VideoViewController alloc]initWithNibName:nil bundle:nil];
    }
    
    [self presentViewController:_video animated:YES completion:^{
        
        [_video setURL:(NSString *)notification.object];
        
    }];
    
}


- (void)changeSceneMode
{
    //改变正在动画的simmeringView的color
    if (statusManageView) {
        statusManageView.frontColor = [self shimmeringColor];
    }
}

- (void)fontChangeBegain
{
    isFontChanging = YES;

    [navBarController hide];
    [sliderController showProgressView];
}

- (void)bookParseComplete
{
    isFontChanging = NO;

//    [self showAccessory];
    [sliderController hideProgressView];
    [sliderController hideSlider];
}

- (void)addAccessory
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(singleTap)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delegate = self;
//    [self.view addGestureRecognizer:singleTap];
    
    sliderController.delegate = [LYBookRenderManager sharedInstance];
    [self.view addSubview:sliderController.view];
    
    [self.view addSubview:navBarController.view];
    
    [navBarController hide];
    
    showedNavigationBar = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(singleTap) name:@"OneTap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAccessory) name:@"hiddenNavBar" object:nil];
}

-(void)singleTap
{
    if (isFontChanging) {
        return;
    }
    
    if (showedNavigationBar) {
        [self hideAccessory];
    }
    else {
        [self showAccessory];
    }
}

- (void)showAccessory
{
    [sliderController showSlider];
    showedNavigationBar = YES;
    [navBarController show];
}

- (void)hideAccessory
{
    [sliderController hideSlider];
    [navBarController hide];

    showedNavigationBar = NO;
}

-(void)hiddenAudioViewShowBtn
{
    [_musicBtn setHidden:NO];
    
    [OWAnimator basicAnimate:_musicBtn toScale:CGPointZero duration:0.5f delay:0 completion:^{
        
        [OWAnimator spring:_musicBtn toScale:CGPointMake(1, 1) delay:0];
        
    }];
    
}

#pragma mark 进入搜索
-(void)addSearch:(NSNotification *)notification
{
    SearchViewController *search = [[SearchViewController alloc]initWithNibName:nil bundle:nil];
    
    [self presentViewController:search animated:YES completion:^{
        
        [search showKeyBorad];
        
    }];
    
}


//#pragma mark 新增现实编辑批注界面的显示方法
//- (void)callNotesViewShow:(NSNotification *)notification
//{
//    NSString *str = (NSString *)notification.object;
//    
//    //先配置属性
//    [self presentViewController:_noteEditor animated:YES completion:^{
//        
//        [_noteEditor setSubViewContent:str];
//        
//    }];
//}



@end
