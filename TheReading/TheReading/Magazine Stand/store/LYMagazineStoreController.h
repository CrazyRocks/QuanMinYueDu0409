//
//  LYMagazineStoreController.h
//  LYMagazinesStand
//
//  Created by grenlight on 14/7/31.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <OWKit/OWKit.h>
#import "LYCategoryManager.h"

@interface LYMagazineStoreController : OWViewController
{
    LYCategoryManager   *categoryManager;
}
@property (nonatomic, strong) LYMenuData *menu;

@end
