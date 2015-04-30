//
//  ContentMainController.m
//  DragonSourceReader
//
//  Created by iMac001 on 11-12-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ArticleDetailMainController.h"
#import <CoreText/CoreText.h>
#import <OWCoreText/OWCoreText.h>
#import <OWCoreText/OWHTMLToAttriString.h>
#import "GLCommentManager.h"
#import "ArticleDetailController.h"

@interface ArticleDetailMainController(){    
    //竖屏
    OWInfiniteScrollView             *verticalScrollContentView;
    
    uint                              currentPageIndex;
    
    CGPoint                           homeCenter, schoolCenter;
    
    LYFavoriteManager                  *favoriteManager;
    
}
- (IBAction)intoCatalogue:(id)sender;

@end


@implementation ArticleDetailMainController

- (id)init
{
    self = [super initWithNibName:@"ArticleDetailMainController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        favoriteManager = [[LYFavoriteManager alloc] init];
        
        //设置文章的收藏等属性
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentArticle_changed) name:CURRENTARTICLE_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weiboSended) name:@"Weibo_Sended" object:nil];
        self.isRecommendArticleMode = NO;
    }
    return self;
}

-(void)releaseData
{
    [contentView removeFromSuperview];
    contentView = nil;
    
    [verticleContentView removeFromSuperview];
    verticleContentView = Nil;
    
    [[OWHTMLToAttriString sharedInstance] setImageBasicPath:Nil];
    
    [super releaseData];
}

- (void)updateStatusBarStyle
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [OWColor colorWithHexString:@"#FBFBFB"];
    
    if (![LYGlobalConfig sharedInstance].allowToShare) {
        [weiboButton setHidden:YES];
    }
    
    UITapGestureRecognizer *twoTap =[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                           action:@selector(twoTap)];
    twoTap.numberOfTapsRequired = 2;
    twoTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:twoTap];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float fontSize = [defaults floatForKey:APP_FONTSIZE];
    if (fontSize < 10.0) {
        fontSize = appFontsize_normal;
        [defaults setFloat:fontSize forKey:APP_FONTSIZE];
        [defaults synchronize];
    }
    [fontSizeButton setSelected: (fontSize > appFontsize_normal)];
    
    if (self.isRecommendArticleMode) {
        catalogueButton.hidden = YES;
    }
    else {
        catalogueButton.hidden = NO;
    }
}

- (void)renderContentView
{
    [self clearOldContent];
    
    CGRect frame;
    frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), appHeight-64);
    if ([LYGlobalConfig sharedInstance].versionOfTheArticleDetailView == 2) {
        verticleContentView = [[VerticleScrollView alloc] initWithFrame:frame];
        [self.view insertSubview:verticleContentView atIndex:0];
        verticleContentView.backgroundColor = self.view.backgroundColor;
    }
    else {
        contentView = [[HorizontalPageScrollView alloc] initWithFrame:frame];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.view insertSubview:contentView atIndex:0];
        
        contentView.backgroundColor = self.view.backgroundColor;
        [contentView renderArticle];
    }
}

- (void)continueRead
{
    if (verticleContentView || contentView) {
        return;
    }
    [self renderContentView];
}

-(void)currentArticle_changed
{
    [favoriteButton setSelected:
     [favoriteManager isFavorite:[CommonNetworkingManager sharedInstance].getCurrentArticle]];

}

-(void)weiboSended
{
}

-(void)twoTap
{
    [self comeback:nil];
}


-(IBAction)sharedToWeiBo:(id)sender
{
    [GLCommentManager sharedInstance].navbarMask = navBar;
    NSString *message = [contentView.currentPage getArticleWebURL];
    [[GLCommentManager sharedInstance] loadWeiBoUIByDefaultMessage:message];
}

-(IBAction)fontsizeButton_tapped:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults floatForKey:APP_FONTSIZE]==appFontsize_normal) {
        [defaults setFloat:appFontsize_large forKey:APP_FONTSIZE];
        [fontSizeButton setSelected:YES];
    }
    else {
        [defaults setFloat:appFontsize_normal forKey:APP_FONTSIZE];
        [fontSizeButton setSelected:NO];
    }
    [defaults synchronize];
   
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_FONTSIZE_CHANGED object:nil];
}

-(IBAction)favoriteButton_tapped:(UIButton *)sender
{
    BOOL needFavorite = !favoriteButton.selected;
    [sender setEnabled:NO];
    
    __block OWSlideMessageViewController *msgController = [OWSlideMessageViewController sharedInstance];
    [favoriteManager setArticle:[CommonNetworkingManager sharedInstance].getCurrentArticle toFavorite:needFavorite completion:^{
        [sender setEnabled:YES];
        
        NSString *msg = @"已取消收藏";
        if (!sender.selected) {
            msg = @"收藏成功";
        }
        [msgController showMessage:msg autoClose:YES];
        [sender setSelected:!sender.selected];
    } fault:^{
        [sender setEnabled:YES];
        
        NSString *msg = @"取消失败";
        if (!sender.selected) {
            msg = @"收藏失败";
        }
        [msgController showMessage:msg autoClose:YES];
    }];
}

- (void)comeback:(id)sender
{
    if (self.isRecommendArticleMode) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:MAG_BACKTO_SHELF object:nil];
    }
}

- (void)intoCatalogue:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MAG_OPEN_CATALOGUE object:nil];
    
}

- (void)clearOldContent
{
    [verticleContentView removeFromSuperview];
    verticleContentView = nil;

    [contentView removeFromSuperview];
    contentView = nil;
}

@end
