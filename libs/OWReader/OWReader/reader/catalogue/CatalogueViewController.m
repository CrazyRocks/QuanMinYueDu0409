//
//  CatelogueViewController.m
//  DragonSourceReader
//
//  Created by iMac001 on 11-12-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CatalogueViewController.h"
#import <QuartzCore/CoreAnimation.h>
#import "CatalogueTableCell.h" 
#import "Shadow.h"
#import "GLNoiceBackgroundView.h"
#import "LYBookRenderManager.h"
//#import "GLNotificationName.h"
#import "JRReaderNotificationName.h"
#import "MyBooksManager.h"
#import "OWBookButton.h"
#import "LYBookSceneManager.h"
#import "LYBookHelper.h"

@interface CatalogueViewController(){
    //分割动画的起始点
    float splitPositionY;
    //是否处于视图显示状态
    BOOL isAdded;
}
//
@property(assign)CGPoint listContentOffset;
//上次从列表触发分割时的列表状态
//
-(void)barBGAnimate:(float)alpha;


@end

@implementation CatalogueViewController

@synthesize listContentOffset;



- (id)init
{
    self = [super initWithNibName:@"CatalogueViewController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        [self initializeSharedInstance];
        
    }
    return self;
}

-(void)initializeSharedInstance
{
    //添加更新UI通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateModelStyle) name:BOOK_SCENE_CHANGED object:nil];
    
    sysFrame = [UIScreen mainScreen].bounds;
    
    catalogueList = [[CatalogueTableController alloc]init];
    [self addChildViewController:catalogueList];
    
    bookmarkList = [[BookmarkTableController alloc]init];
    [self addChildViewController:bookmarkList];
    
    bookDigestList = [[BookDigestTableController alloc]init];
    [self addChildViewController:bookDigestList];
    
}

- (void)releaseData
{
    if ([catalogueList isViewLoaded]) {
        [catalogueList.view removeFromSuperview];
        catalogueList.view = nil;
        [bookDigestList.view removeFromSuperview];
        bookDigestList.view = nil;
        
    }
    if ([bookmarkList isViewLoaded]) {
        [bookmarkList.view removeFromSuperview];
        bookmarkList.view = nil;
        [bookDigestList.view removeFromSuperview];
        bookDigestList.view = nil;
    }
    
    if ([bookDigestList isViewLoaded]) {
        [bookmarkList.view removeFromSuperview];
        bookmarkList.view = nil;
        [catalogueList.view removeFromSuperview];
        catalogueList.view = nil;
    }
    
    [super releaseData];
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    splitPositionY = 0;
//加载目录列表
    float paddingTop = 64;
    
    listCenter = CGPointMake(appWidth / 2.0, (appHeight-paddingTop)/2.0 + paddingTop);
    
    
    [self segmentValueChanged:segmentControl];

    [self loadSceneMode];
    
}



- (void)loadSceneMode
{
    UIStyleObject *viewStyle = [[LYBookSceneManager manager].styleManager getStyle:@"目录页"];
    self.view.backgroundColor = viewStyle.background;
    barBG.backgroundColor = viewStyle.background;
    
    UIStyleObject *lineStyle = [[LYBookSceneManager manager].styleManager getStyle:@"目录列表cell"];
    [splitLine drawByStyle:lineStyle];
    
    UIStyleObject *segStyle= [[LYBookSceneManager manager].styleManager getStyle:@"目录页SegmentedControl"];
    [segmentControl setStyle:segStyle];
    
    
    [self.view insertSubview:continueButton atIndex:99];
    
}

-(void)updateModelStyle
{
    UIStyleObject *viewStyle = [[LYBookSceneManager manager].styleManager getStyle:@"目录页"];
    self.view.backgroundColor = viewStyle.background;
    barBG.backgroundColor = viewStyle.background;
    
    UIStyleObject *lineStyle = [[LYBookSceneManager manager].styleManager getStyle:@"目录列表cell"];
    [splitLine drawByStyle:lineStyle];
    
    UIStyleObject *segStyle= [[LYBookSceneManager manager].styleManager getStyle:@"目录页SegmentedControl"];
    [segmentControl setStyle:segStyle];
    
}

- (void)continueRead:(id)sender
{
    [[LYBookRenderManager sharedInstance] continueRead];

    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_OPEN_CONTENT object:nil];
}

- (void)segmentValueChanged:(KWFSegmentedControl *)sender
{
    if (currentController) {
        [currentController.view removeFromSuperview];
    }
    [barBG setAlpha:0];

    switch (sender.selectedSegmentIndex) {
        case 0:
            [self intoCatelogueTable:nil];
            break;
        case 1:
            [self intoBookmarkTable:nil];
            break;
        case 2:
            [self intoBookDigestTable:nil];
            break;
        default:
            break;
    };
    
}

-(IBAction)intoCatelogueTable:(id)sender
{
    //-----使用segement需要移除这句话
    if (currentController) {
        [currentController.view removeFromSuperview];
    }
    [barBG setAlpha:0];
    
    //-----------------
    
    currentController = catalogueList;
    [catalogueList.view setCenter:listCenter];
    
    __unsafe_unretained CatalogueViewController *weakSelf = self;

    [catalogueList setSelectedItemChangedCallBack:^(float py,float offsetY){
        weakSelf->splitPositionY = py;
        weakSelf->listContentOffset = CGPointMake(0,offsetY);
    } ];
    
    [catalogueList setScrollCallBack:^(float alpha){
        [weakSelf barBGAnimate:alpha];
    }];
    [self.view insertSubview:catalogueList.view atIndex:1];
}

-(IBAction)intoBookmarkTable:(id)sender
{
    //-----使用segement需要移除这句话
    if (currentController) {
        [currentController.view removeFromSuperview];
    }
    [barBG setAlpha:0];
    
    currentController = bookmarkList;
    [self barBGAnimate:0];
    
    [bookmarkList.view setCenter:listCenter];
    
    __unsafe_unretained CatalogueViewController *weakSelf = self;

    [bookmarkList setSelectedItemChangedCallBack:^(float py,float offsetY){
        weakSelf->splitPositionY = py;
        weakSelf->listContentOffset = CGPointMake(0,offsetY);
    } ];
    
    [bookmarkList setScrollCallBack:^(float alpha){
        [weakSelf barBGAnimate:alpha];
    }];
    
    [self.view insertSubview:bookmarkList.view atIndex:1];
    
}

-(IBAction)intoBookDigestTable:(id)sender
{
    //-----使用segement需要移除这句话
    if (currentController) {
        [currentController.view removeFromSuperview];
    }
    [barBG setAlpha:0];

    currentController = bookDigestList;
    [self barBGAnimate:1];
    
    [bookDigestList.view setCenter:listCenter];
    
    __unsafe_unretained CatalogueViewController *weakSelf = self;
    
    [bookDigestList setSelectedItemChangedCallBack:^(float py,float offsetY){
        weakSelf->splitPositionY = py;
        weakSelf->listContentOffset = CGPointMake(0,offsetY);
    } ];
    
    [bookDigestList setScrollCallBack:^(float alpha){
        [weakSelf barBGAnimate:alpha];
    }];
    
    [self.view insertSubview:bookDigestList.view atIndex:1];
}

-(void)barBGAnimate:(float)alpha
{
    [UIView animateWithDuration:0.2 animations:^{
        [barBG setAlpha:alpha]; 
    }];
}

-(IBAction)add_n_removeView:(id)sender
{
    [self.view removeFromSuperview];
    CFRelease((__bridge CFTypeRef)self);
}

@end
