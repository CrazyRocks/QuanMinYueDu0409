//
//  WYRootArticleListController.h
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h>
#import "WYMenuManager.h"

@interface WYArticleListSubNavController : OWSubNavigationController
{
   
}
@property (nonatomic, weak) WYMenuManager   *menuManager;

@end
