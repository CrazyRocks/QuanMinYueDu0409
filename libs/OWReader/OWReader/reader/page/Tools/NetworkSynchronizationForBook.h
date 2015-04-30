//
//  NetworkSynchronizationForBook.h
//  LYBookStore
//
//  Created by grenlight on 14/11/10.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LYService/LYService.h>
#import "BookDigestNetModel.h"
#import "ModelTransformationTool.h"
#import "ReadProessNetModel.h"
#import "UserInformation.h"

#import "Bookmark.h"
#import "LYBookSceneManager.h"
#import "LYBookmarkManager.h"
#import "JRReaderNotificationName.h"

@interface NetworkSynchronizationForBook : NSObject<UIAlertViewDelegate>
{
    AFHTTPRequestOperation *op;
    
    AFHTTPRequestOperation *opMark;
    
    //书签
    NSMutableArray *needSaveList;
    
    //标签
    NSMutableArray *needSaveMarkList;
    
    ReadProessNetModel *currentReadNetModel;
}

@property (nonatomic, retain) UserInformation *userModel;

@property BOOL isCalculation;

+ (NetworkSynchronizationForBook *)manager;

-(void)getBookDigestListFromSever;

//需要在退出时候调用
-(void)cancelRequest;


-(void)getBookMarkListFromSever;


-(void)sendReadProgressToSever;


-(void)getCurrentBookProgressFromSever;


#pragma mark 复制过来的方法

//笔记的添加与删除
-(void)saveBookDigestToSever:(BookDigest *)model;

-(void)deleteBookDigestToSever:(BookDigest *)model;


//书签的添加与删除
-(void)saveBookMarkToSever:(Bookmark *)model;

-(void)deleteBookMarkToSever:(Bookmark *)model;



@end
