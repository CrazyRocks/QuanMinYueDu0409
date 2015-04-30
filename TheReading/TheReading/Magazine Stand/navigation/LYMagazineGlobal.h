//
//  LYMagazineGlobal.h
//  LYMagazinesStand
//
//  Created by grenlight on 14-5-15.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYMagazineGlobal : NSObject

@property (nonatomic, strong) NSArray             *magCategories;
//
@property (nonatomic, assign) BOOL              isLocalMagazine;

+ (LYMagazineGlobal *)sharedInstance;

@end
