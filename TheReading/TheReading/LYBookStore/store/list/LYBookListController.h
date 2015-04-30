//
//  LYBookListController.h
//  LYBookStore
//
//  Created by grenlight on 14-5-7.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <OWKit/OWKit.h>

@interface LYBookListController : OWCollectionViewController
{
    NSString    *categoryID;
    
    NSString    *noDataMessage;
}

- (void)requestLocalData:(NSString *)cid;
- (void)requestList:(NSString *)cid;

@end
