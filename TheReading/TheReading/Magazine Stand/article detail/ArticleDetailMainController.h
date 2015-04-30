//
//  ContentMainController.h
//  DragonSourceReader
//
//  Created by iMac001 on 11-12-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalPageScrollView.h"
#import "VerticleScrollView.h"

@interface ArticleDetailMainController :XibAdaptToScreenController
{
    HorizontalPageScrollView          *contentView;
    VerticleScrollView                *verticleContentView;

    IBOutlet  UIButton               *favoriteButton ;
    IBOutlet  UIButton               *fontSizeButton ;
    IBOutlet  UIButton               *weiboButton;
    
    IBOutlet  UIButton               *catalogueButton;
}
//是否为推荐/资讯文章模式
@property (nonatomic, assign) BOOL isRecommendArticleMode;

-(IBAction)sharedToWeiBo:(id)sender;

-(IBAction)fontsizeButton_tapped:(id)sender;
-(IBAction)favoriteButton_tapped:(id)sender;

- (void)renderContentView;
- (void)continueRead;

//非续读时调用此方法
- (void)clearOldContent;

@end
