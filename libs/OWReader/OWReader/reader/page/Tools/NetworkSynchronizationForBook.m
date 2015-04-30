//
//  NetworkSynchronizationForBook.m
//  LYBookStore
//
//  Created by grenlight on 14/11/10.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "NetworkSynchronizationForBook.h"
#import "JRBookDigestManager.h"
#import "LYBookmarkManager.h"
#import "MyBooksManager.h"

@implementation NetworkSynchronizationForBook

+ (NetworkSynchronizationForBook *)manager
{
    static NetworkSynchronizationForBook *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NetworkSynchronizationForBook alloc] init];
    });
    return(instance);
}

//复制用户模型
-(void)setUserModel:(UserInformation *)userModel
{
    if (_userModel != nil) {
        if (![_userModel.authToken isEqualToString:userModel.authToken]) {
            _userModel = userModel;
        }
    }else{
        _userModel = userModel;
    }
}

#pragma mark 网络获取笔记
-(void)getBookDigestListFromSever
{

}

//判断是否需要同步笔记，看没有个数
-(NSMutableArray *)reformingTheNotesData:(NSMutableArray *)array
{
    
    NSMutableArray *tmp = [[NSMutableArray alloc]init];
    
    NSMutableArray *arr = [JRBookDigestManager sharedInstance].currentBookDigest;
    
    for (BookDigestNetModel *model in array) {
        
        int k = 0;
        for (BookDigest *obj in arr) {
            
            if ([obj.noteID intValue] == [model.noteID intValue]) {
                k++;
                break;
            }
        }
        
        if (k == 0) {
            [tmp addObject:model];
        }
        
    }
    
    return tmp;
}

#pragma mark 书签方法
-(void)getBookMarkListFromSever
{
    
}

-(NSMutableArray *)reformingTheMarksData:(NSMutableArray *)array
{
    NSMutableArray *tmp = [[NSMutableArray alloc]init];
    
    NSArray *list = [[LYBookmarkManager sharedInstance] getBookmarkList];
    
    for (BookMarkNetModel *model in array) {
        
        
        int k = 0;
        
        for (Bookmark *obj in list) {
            
            if ([obj.bookmarkid intValue] == [model.bookmarkid intValue]) {
                k++;
                break;
            }
            
            
        }
        
        if (k == 0) {
            [tmp addObject:model];
        }
        
    }
    return tmp;
}

#pragma mark 退出时上传阅读进度
-(void)sendReadProgressToSever
{
    
}

#pragma mark 获取上次阅读的进度
-(void)getCurrentBookProgressFromSever
{
    
}

#pragma mark alertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }else if (buttonIndex == 1){
        
        NSLog(@"跳转");
        
        if ([MyBooksManager sharedInstance].currentReadBook.pageCounts == nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage) name:@"The_synchronization_schedule" object:nil];
        }else{
            [[LYBookRenderManager sharedInstance] intoBookLastReadWithReadNetModel:currentReadNetModel];
        }
    }
}

-(void)changePage
{
        [[LYBookRenderManager sharedInstance] intoBookLastReadWithReadNetModel:currentReadNetModel];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"The_synchronization_schedule" object:nil];
        _isCalculation = NO;
}



#pragma mark 退出是调用的方法
-(void)cancelRequest
{
    if (op) {
        [op cancel];
        op = nil;
    }
    
    if (opMark) {
        [opMark cancel];
        op = nil;
    }
    
    if (currentReadNetModel) {
        currentReadNetModel = nil;
    }
}

/*
 添加删除笔记、书签功能在远 + 方法 整合过来使用单例去做 以免多个线程同时访问数据库
*/


#pragma mark 整合过来的添加、删除功能
-(void)saveBookDigestToSever:(BookDigest *)model
{
  
}

-(void)deleteBookDigestToSever:(BookDigest *)model
{
    
    
}

#pragma mark 删除

-(void)saveBookMarkToSever:(Bookmark *)model
{
    
}

//删除书签
-(void)deleteBookMarkToSever:(Bookmark *)model
{
    
}



@end
