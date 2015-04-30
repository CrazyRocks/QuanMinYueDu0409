//
//  LYBookSceneManager.h
//  LYBookStore
//
//  Created by grenlight on 14/7/19.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OWCoreText/OWHTMLToAttriString.h>


#import "LYBookRenderManager.h"


@class  UIStyleManager;

@interface LYBookSceneManager : NSObject
{
   
}
//@property (nonatomic, strong) LYBookRenderManager *renderManager;
@property (nonatomic, strong) UIStyleManager    *styleManager;
@property (nonatomic, strong) OWHTMLToAttriString   *htmlToAttriString;
//资源包
@property (nonatomic, strong) NSBundle          *assetsBundle;

@property (nonatomic, assign) float             fontSizeScale;
@property (nonatomic, strong) NSString          *fontName;


+ (LYBookSceneManager *)manager;

//场景模式
- (void)changeSceneMode:(NSString *)sm;

- (NSString *)sceneMode;

- (void)reloadCss;



@end
