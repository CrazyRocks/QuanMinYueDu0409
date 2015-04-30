//
//  LYBookSceneManager.m
//  LYBookStore
//
//  Created by grenlight on 14/7/19.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "LYBookSceneManager.h"
#import "BSCoreDataDelegate.h"
#import "MyBooksManager.h"
#import <OWKit/OWKit.h>
#import <OWCoreText/OWCoreText.h> 
//#import "GLNotificationName.h"

#import "JRReaderNotificationName.h"
#import "LYBookSceneManager.h"
#import "LYBookHelper.h"
#import "BSGlobalAttri.h"

@implementation LYBookSceneManager

- (id)init
{
    self = [super init];
    if (self) {
        [self initStyleManager];
        self.htmlToAttriString = [[OWHTMLToAttriString alloc] init];
        self.htmlToAttriString.fontName = [self fontName];
        [self.htmlToAttriString scaleFontSize:[self fontSizeScale]];
        
        [self loadSceneData];
    }
    return self;
}

+ (LYBookSceneManager *)manager
{
    static LYBookSceneManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYBookSceneManager alloc] init];
    });
    return(instance);
}

- (void)initStyleManager
{
    self.styleManager = [[UIStyleManager alloc] init];
    [self.styleManager parseStyleFile:[self sceneMode] inBundle:self.assetsBundle];
}

#pragma mark bundle
- (NSBundle *)assetsBundle
{
    if (!_assetsBundle) {
        [self updateBundle];
    }
    return _assetsBundle;
}

- (void)updateBundle
{
    NSString *sceneMode = [self sceneMode];
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle",sceneMode]];
    self.assetsBundle = [NSBundle bundleWithPath:bundlePath];
    self.htmlToAttriString.bundle = self.assetsBundle;
}

#pragma mark scene
- (void)changeSceneMode:(NSString *)sm
{
    if ([[self sceneMode] isEqualToString:sm]) {
        return;
    }
    
    NSUserDefaults *defauts = [NSUserDefaults standardUserDefaults];
    [defauts setObject:sm forKey:@"scene_mode"];
    [defauts synchronize];

    [self loadSceneData];

    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_SCENE_CHANGED object:nil userInfo:nil];

    [[LYBookRenderManager sharedInstance] changeFontStyle];

    UIStatusBarStyle barStyle = UIStatusBarStyleDefault ;
    if ([LYBookHelper isNightMode]) {
        barStyle = UIStatusBarStyleLightContent;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:barStyle animated:YES];
    
}

- (void)loadSceneData
{
    //更新资源包
    [self updateBundle];
    [self.styleManager parseStyleFile:[self sceneMode] inBundle:self.assetsBundle];
    
    [self reloadCss];
}

//当前模式
- (NSString *)sceneMode
{
    NSUserDefaults *defauts = [NSUserDefaults standardUserDefaults];
    if (![defauts stringForKey:@"scene_mode"]) {
        [defauts setObject:@"day" forKey:@"scene_mode"];
        [defauts synchronize];
    }
    return [defauts stringForKey:@"scene_mode"];
}

- (void)reloadCss
{
    NSString *cssName ;
    cssName = [self sceneMode];

    [self.htmlToAttriString setCSS:cssName fontSizeScale:self.fontSizeScale];
    UIEdgeInsets insets = [BSGlobalAttri sharedInstance].textInsets;
    self.htmlToAttriString.imageSize = CGSizeMake(appWidth - insets.left * 2, appHeight - insets.top - insets.bottom);
    
    [self.htmlToAttriString setImageBasicPath:
     [[BSCoreDataDelegate sharedInstance].cacheDocumentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@", [MyBooksManager sharedInstance].currentReadBook.bookID ,[MyBooksManager sharedInstance].currentReadBook.opsPath]]];
}

#pragma mark 字体字号控制
- (void)setFontSizeScale:(float)scale
{
    [[NSUserDefaults standardUserDefaults] setFloat:scale forKey:@"LYBook_FontSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.htmlToAttriString scaleFontSize:scale];
}

- (float)fontSizeScale
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    float fz = [userDefaults floatForKey:@"LYBook_FontSize"];
    if (fz > 0.6) {
        return fz;
    }
    else {
        [userDefaults setFloat:1.0f forKey:@"LYBook_FontSize"];
        [userDefaults synchronize];
        return 1.0f;
    }
}

- (void)setFontName:(NSString *)fontName
{
    [[NSUserDefaults standardUserDefaults] setObject:fontName forKey:@"LYBook_FontName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.htmlToAttriString setFontName:fontName];
}

- (NSString *)fontName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fn = [userDefaults stringForKey:@"LYBook_FontName"];
    if (!fn) {
        fn = @"FangSong";
        [userDefaults setObject:fn forKey:@"LYBook_FontName"];
        [userDefaults synchronize];
    }
    return fn;
}
@end
