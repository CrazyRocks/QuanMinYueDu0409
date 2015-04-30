//
//  GLBookmarkManager.h
//  LogicBook
//
//  Created by iMac001 on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bookmark.h"

@class GLCTPageInfo;

@interface LYBookmarkManager : NSObject{
     NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) Bookmark *needToSeverMark;
@property (nonatomic, retain) Bookmark *needToDeleteMark;


+(LYBookmarkManager *)sharedInstance;

-(void)addBookmarkBySummary:(NSString *)summary catName:(NSString *)cat catIndex:(NSNumber *)cid position:(NSInteger)pos;

-(void)deleteBookmark:(GLCTPageInfo *)info;

//书签列表
-(NSArray *)getBookmarkList;

//判断当前页是否加了书签
-(BOOL)IsBookmarked:(GLCTPageInfo *)info;

-(void)bookmarkUpdate:(Bookmark *)model andID:(NSNumber *)markid;



//网络更新书签
-(void)addBookmarkFromSever:(NSMutableArray *)array;






@end
