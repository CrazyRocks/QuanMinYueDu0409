//
//  LYBookAddUserGuide.h
//  LYBookStore
//
//  Created by grenlight on 14/7/17.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYBookAddUserGuide : NSObject
{
    BOOL addedUserGuide;
    UIImageView *userGuidView;
}
@property (nonatomic, weak) UIViewController *parentController;

+ (LYBookAddUserGuide *)sharedUserGuide;

- (void)addUserGuide:(UIViewController *)controller;
- (void)removeUserCuide;

@end
