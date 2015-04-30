//
//  GlobalManager.h
//  LongYuanYueDu
//
//  Created by gren light on 12-10-26.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    glTableViewTypeRecomment,
    glTableViewTypeFavorite,
    glTableViewTypeCategory,
}GLTableViewType;

@interface LYGlobalManager : NSObject
{
   
}

//在搜索交互过程中，搜索条的原始父级视图可能因为内存原因被释放了，
//所以需要重建
@property(nonatomic,assign)__unsafe_unretained UIView           *magazineSearchBarSupperView;

+(LYGlobalManager *)sharedInstance;
-(void)intoSearchModel;
-(void)quitSearchModel;

@end
