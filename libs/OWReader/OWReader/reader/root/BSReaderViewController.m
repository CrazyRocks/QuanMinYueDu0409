//
//  LogicBookRootViewController.m
//  LogicBook
//
//  Created by  iMac001 on 12-11-20.
//
//

#import "BSReaderViewController.h"
#import "MyBook.h"
#import "LYBookSceneManager.h"
#import "BSCoreDataDelegate.h"
#import "MyBooksManager.h"
#import "CatalogueViewController.h"
#import "LYBookPageRootController.h"

#import <Foundation/Foundation.h>

#import "JRReaderNotificationName.h"

#import "NetworkSynchronizationForBook.h"


@interface BSReaderViewController ()
{
    CatalogueViewController *catController;
    LYBookPageRootController   *contController;
    
    OWCoverAnimationView    *coverView;
    UIView                  *contentView;
    
    UILabel                 *logoLabel;
}
@end

@implementation BSReaderViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        [[LYBookSceneManager manager] reloadCss];
        
        __weak typeof (self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_BACKTO_BOOKSHELF object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf quitReader];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_OPEN_CATALOGUE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf intoCatalogue];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_LOAD_CATALOGUE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf loadCatalogueView];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_REMOVE_CATALOGUE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf removeCatalogueView];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:BOOK_OPEN_CONTENT object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf intoContent];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCataloges:) name:@"MOVE_ROOT" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSceneMode) name:BOOK_SCENE_CHANGED object:nil];
        
    }
    return self;
}

-(void)showCataloges:(NSNotification *)notification
{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)notification.object;
    CGPoint point = [pan locationInView:pan.view.superview.superview.superview];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        lastPoint = point;
        [self loadCatalogueView];
    }
    else if (pan.state == UIGestureRecognizerStateChanged){
        
        float cha = point.x - lastPoint.x;
        
        if (rootView.center.x + cha > 0 && rootView.center.x + cha < appWidth) {
            rootView.center = CGPointMake(rootView.center.x + cha, rootView.center.y);
        }
        else{
            
        }
        
    }
    else {
        float cha = point.x - lastPoint.x;
        CGFloat newX = rootView.center.x + cha;
        
        if (newX <= appWidth/2) {
            rootView.center = CGPointMake(rootView.center.x, rootView.center.y);
        }else{
            rootView.center = CGPointMake(newX, rootView.center.y);
        }
        
        if (rootView.center.x > appWidth/2) {
            [self intoCatalogue];
        }
        else{
            [self intoContent];
        }
        
        lastPoint = CGPointMake(0, 0);
    }
    
}


- (void)releaseData
{
    [[LYBookRenderManager sharedInstance] reset];
    [coverView removeFromSuperview];
    coverView = nil;
    [super releaseData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [super viewDidDisappear:animated];
}

-(void)loadView
{
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, appWidth, appHeight)];
    rootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, appWidth*2, appHeight)];
    rootView.center = CGPointMake(appWidth + appWidth/2, self.view.frame.size.height/2);
    rootView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:rootView];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(appWidth, 0, appWidth, appHeight)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.clipsToBounds = YES;
//    contentView.center = CGPointMake(rootView.frame.size.width*3/4, appHeight/2);
//    [self.view addSubview:contentView];
    [rootView addSubview:contentView];
    
    coverView = [[OWCoverAnimationView alloc] initWithFrame:contentView.bounds];
    coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [contentView addSubview:coverView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.clipsToBounds = YES;
    
    [self loadSceneMode];
     
//    centerFrame = leftFrame = rightFrame = self.view.bounds;
    
    leftFrame.origin.x = (-appWidth);
    rightFrame.origin.x = appWidth;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSceneMode) name:BOOK_SCENE_CHANGED object:nil];
    [self performSelector:@selector(removePanGesture) withObject:nil afterDelay:1];
}

- (void)loadSceneMode
{
    UIStyleObject *viewStyle = [[LYBookSceneManager manager].styleManager getStyle:@"目录页"];
    contentView.backgroundColor = viewStyle.background;
    
    UIStatusBarStyle barStyle = UIStatusBarStyleDefault;
    if ([LYBookHelper isNightMode]) {
        barStyle = UIStatusBarStyleLightContent;
//        rootView.backgroundColor = [OWColor colorWithHexString:@"#262626"];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)changeSceneMode
{
    UIStyleObject *viewStyle = [[LYBookSceneManager manager].styleManager getStyle:@"目录页"];
    contentView.backgroundColor = viewStyle.background;
    
    UIStatusBarStyle barStyle = UIStatusBarStyleDefault;
    if ([LYBookHelper isNightMode]) {
        barStyle = UIStatusBarStyleLightContent;
        rootView.backgroundColor = [OWColor colorWithHexString:@"#262626"];
    }else{
        rootView.backgroundColor = [OWColor colorWithHexString:@"#ffffff"];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
}

- (void)updateStatusBarStyle
{
    UIStatusBarStyle barStyle = UIStatusBarStyleDefault;
    if ([LYBookHelper isNightMode]) {
        barStyle = UIStatusBarStyleLightContent;
        
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    //新增切换模式后的调整背景颜色
    
    if ([LYBookHelper isNightMode]) {
        rootView.backgroundColor = [OWColor colorWithHexString:@"#262626"];
    }
    else{
        rootView.backgroundColor = [OWColor colorWithHexString:@"#ffffff"];
    }
    
}

#pragma mark 封面
- (void)openFromRect:(CGRect)rect cover:(UIImage *)img
{
    isCoverMode = YES;

    [coverView viewWithImage:img];
    
    homeFrame = rect;
    
//    homeFrame = CGRectMake(rect.origin.x + appWidth, rect.origin.y, rect.size.width, rect.size.height);
    
    CGRect tmp = contentView.frame;
    
    [contentView setFrame:homeFrame];
    
    [contentView setFrame:CGRectMake(rect.origin.x + appWidth, rect.origin.y, rect.size.width, rect.size.height)];
 
    rootView.center = CGPointMake(0, self.view.frame.size.height/2);
    [UIView animateWithDuration:0.45 animations:^{
        
        //还原
        contentView.frame = tmp;
        
    } completion:^(BOOL finished) {
        
        catController.view.hidden = NO;
        
        if ([LYBookHelper isNightMode]) {
            rootView.backgroundColor = [OWColor colorWithHexString:@"#262626"];
        }
        else{
            rootView.backgroundColor = [OWColor colorWithHexString:@"#ffffff"];
        }
        
    }];
    
    [coverView performSelector:@selector(startAnimation) withObject:nil afterDelay:0.f];
    [self performSelector:@selector(parseContent) withObject:nil afterDelay:0.f];

}

- (void)openWithNoneCover
{
    isCoverMode = NO;
//    contentView.frame = self.view.bounds;
    coverView.hidden = YES;
    
    [self parseContent];
}

#pragma mark 操作目录页
-(void)loadCatalogueView
{
    if (!catController) {
        catController =  [[CatalogueViewController alloc] init];
        [self addChildViewController:catController];
    }
    catController.view.frame = CGRectMake(0, 0, appWidth, appHeight);
    [rootView addSubview:catController.view];
}

//在屏幕外时，将目录从显示列表中移除，便于重新添加后触发viewDidAppear事件
- (void)removeCatalogueView
{
    if (catController && [catController isViewLoaded]) {
        [catController.view removeFromSuperview];
    }
}

- (void)intoCatalogue
{
    [self loadCatalogueView];
    
    [UIView animateWithDuration:0.3 animations:^{
        rootView.center = CGPointMake(appWidth, self.view.frame.size.height/2);
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
    
}

#pragma mark 内容页
- (void)intoContent
{
    [UIView animateWithDuration:0.3 animations:^{
        rootView.center = CGPointMake(0, self.view.frame.size.height/2);
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [self removeCatalogueView];
    }];
}

//调用解析目录方法
- (void)parseContent
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IntoEpubReader" object:nil];
    /*
     先解析目录并显示
     计算页码后置
     */
    __weak typeof (self) weakSelf = self;
    [[LYBookRenderManager sharedInstance] parseCatalogue:^{
        [weakSelf contentAlphaIn];
    }];
}

- (void)contentAlphaIn
{
    //ContentMainController放在此处初始化是因为要保证在此这前目录已经解析完成
    if (!contController) {
        contController  = [[LYBookPageRootController alloc] init];
        [self addChildViewController:contController];
    }
    
    //    [contController.view setFrame:rightFrame];
    [contentView insertSubview:contController.view atIndex:0];
    
    if (rootView.center.x >= appWidth) {
        
        rootView.center = CGPointMake(0, appHeight/2);
        
    }
    
    //直接进入到上次阅读的地方
    [[LYBookRenderManager sharedInstance] continueRead];
    
    [self intoContent];
}

#pragma mark 退出阅读
- (void)quitReader
{
    if (isCoverMode) {
        __weak typeof (self) weakSelf = self;
        
        [contentView bringSubviewToFront:coverView];
        
        [coverView closeCover:^{
            [weakSelf backToHome];
            [weakSelf outEpubReaderNotification];
        }];
        
        [[OWNavigationController sharedInstance] popViewControllerWithNoneAnimation:0.7];
    }
    else {
        [[OWNavigationController sharedInstance] popViewController:owNavAnimationTypeSlideFromLeft];
        [self outEpubReaderNotification];
    }
    
}

- (void)outEpubReaderNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OutEpubReader" object:nil];
}

- (void)backToHome
{
    catController.view.hidden = YES;
    rootView.backgroundColor = [UIColor clearColor];
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         rootView.center = CGPointMake(appWidth, self.view.frame.size.height/2);
                         contentView.frame = homeFrame;
                     } completion:nil];
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIDeviceOrientationPortrait;
}


@end
