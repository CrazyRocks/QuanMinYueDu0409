//
//  BookmarkController.m
//  LogicBook
//
//  Created by iMac001 on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookmarkController.h"
#import "LYBookmarkManager.h"
#import <OWCoreText/GLCTPageInfo.h>
#import <OWKit/OWKit.h>
//#import "GLNotificationName.h"
#import "JRReaderNotificationName.h"

#import "LYBookSceneManager.h"
#import "LYBookHelper.h"
#import "NetworkSynchronizationForBook.h"


@interface BookmarkController ()
{
    CGPoint home;
    CGPoint school;
    IBOutlet UIView  *moveView;//下拉移动层
    IBOutlet UIView  *addView;//添加书签层
    
    __weak IBOutlet UILabel *messageLB;
    
    __weak IBOutlet UIImageView *addImageView, *deleteImageView;
    
    NSString *message[4];
    
    GLCTPageInfo *pageInfo;
    NSString *catalogue;
    NSNumber *catIndex;
}
@end

@implementation BookmarkController

static BookmarkController *instance;

- (id)init
{
    self = [super initWithNibName:@"BookmarkController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        
        message[0] = @"下拉添加书签";
        message[1] = @"松开添加书签";
        message[2] = @"下拉删除书签";
        message[3] = @"松开删除书签";
        
        
        
    }
    return self;
}

- (void)initializeSharedInstance
{
    
}

-(void)setPageInfo:(GLCTPageInfo *)bl catalogue:(NSString *)cat catIndex:(NSNumber *)cid
{
    pageInfo = bl;
    catalogue = cat;
    catIndex = cid;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, appWidth, self.view.frame.size.height);
    moveView.frame = self.view.frame;
    addView.frame =self.view.frame;
    
    CGRect moveFrame = moveView.frame;
    moveFrame.origin.y = -CGRectGetHeight(moveFrame);
    [moveView setFrame:moveFrame];
    [self.view addSubview:moveView];
    
//    CGRect frame = moveFrame;
//    frame.origin.y = frame.size.height;
//    [addView setFrame:frame];
    
    [self.view addSubview:addView];
    [addView setAlpha:0];

    home = [moveView center];
    school = [addView center];
    
    
    
    
    
    
    
    
    addImageView.image = [OWImage imageWithName:@"bookmark_add@2x" bundle:[LYBookSceneManager manager].assetsBundle];
    deleteImageView.image = [OWImage imageWithName:@"bookmark_cancle@2x" bundle:[LYBookSceneManager manager].assetsBundle];
}

-(void)isMarked:(BOOL)bl
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _isMarked = bl;
        
        if(bl){
            [addView setAlpha:1];
        }
        else {
            [addView setAlpha:0];
        }        
    });
}

-(void)addBookmark:(BOOL)bl
{
    LYBookmarkManager *bmManager = [LYBookmarkManager sharedInstance];
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        if(bl){
            [bmManager addBookmarkBySummary:pageInfo.description catName:catalogue catIndex:catIndex position:pageInfo.location];
            
#pragma mark 上传书签
            [[NetworkSynchronizationForBook manager] saveBookMarkToSever:bmManager.needToSeverMark];
            
        }
        else {
            [bmManager deleteBookmark:pageInfo];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:LYBOOK_BOOKMARK_CHANGED object:nil];
        
    });
}

- (void)setAddViewAlpha:(float)alpha
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         [addView setAlpha:alpha];
                     }];
}

-(void)setMessage:(BOOL)direction
{
    if (direction) {//下拉
        if(_isMarked){
            messageLB.text = message[3];
            [self setAddViewAlpha:0];
        }
        else{
            messageLB.text = message[1];
            [self addBookmark:NO];
            [self setAddViewAlpha:1];
        }

    }
    else {
        if(_isMarked) {
            messageLB.text = message[2];
            [self setAddViewAlpha:1];
        }
        else {
            messageLB.text = message[0];
            [self setAddViewAlpha:0];
        }
    }
    
}

-(void)movingView:(float)offsetY
{
    CGPoint center = home;
    center.y += offsetY ;

    if(center.y < home.y){
        center.y = home.y;
        [self setMessage:NO];
    }
    else if(center.y > school.y){
        center.y = school.y;
        [self setMessage:YES];
    }
    else {
        [self setMessage:NO];
    }

    [moveView setCenter:center];
}

-(void)goHome
{
    CGPoint currentCenter = moveView.center;
    //添加或删除书签并修改书签状态
    if(currentCenter.y >= school.y){
        _isMarked = !_isMarked;
        [self addBookmark:_isMarked];
    }

    [UIView animateWithDuration:0.3  animations:^{
        [moveView setCenter:home];
    } ];
}


@end
