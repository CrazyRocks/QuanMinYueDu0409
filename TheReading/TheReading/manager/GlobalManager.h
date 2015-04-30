//
//  GlobalManager.h
//  LongYuanYueDu
//
//  Created by gren light on 12-10-26.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LYService/LYGlobalConfig.h>

@class OWImageManager;

@interface GlobalManager : NSObject
{
   
}

@property(nonatomic,assign)MainNavigationBarStatus               currentNavigationState;

//所以需要重建
@property(nonatomic, weak) UIView           *magazineSearchBarSupperView;

+(GlobalManager *)sharedInstance;
-(void)intoSearchModel;
-(void)quitSearchModel;

-(void)setNavigationState:(MainNavigationBarStatus)state;

@end
