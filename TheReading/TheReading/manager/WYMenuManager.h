//
//  WYCategoryManager.h
//  PublicLibrary
//
//  Created by grenlight on 14-1-22.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@class WYCoreDataDelegate;

@interface WYMenuManager : NSObject
{
    WYCoreDataDelegate *wydd;
    AFHTTPRequestOperation  *requestOperation;
}
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableArray    *favoriteCats;
@property (nonatomic, strong) NSMutableArray    *dislikeCats;

- (void)getCategories:(LYMenuData *)menu completion:(GLParamBlock)completion fault:(GLHttpRequstFault)fault;

- (void)updateSorting;

@end
