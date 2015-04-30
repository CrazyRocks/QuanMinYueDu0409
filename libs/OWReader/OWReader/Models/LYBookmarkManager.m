//
//  GLBookmarkManager.m
//  LogicBook
//
//  Created by iMac001 on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LYBookmarkManager.h"
#import "Bookmark.h"
#import "BSCoreDataDelegate.h"
#import <OWCoreText/GLCTPageInfo.h>
#import "MyBooksManager.h"

#import "BookMarkNetModel.h"
#import "NetworkSynchronizationForBook.h"


@implementation LYBookmarkManager

static LYBookmarkManager *instance;

-(void)setUp{
    BSCoreDataDelegate *cdd = [BSCoreDataDelegate sharedInstance];
    managedObjectContext = [NSManagedObjectContext new];
    [managedObjectContext setPersistentStoreCoordinator:cdd.persistentStoreCoordinator];
    
}

+(LYBookmarkManager *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYBookmarkManager alloc]init];
        [instance setUp];
    });
    
    return instance;
}

- (Bookmark *)getBookmarkByCatIndex:(NSNumber *)cid position:(NSInteger)pos
{
    MyBook *book = [MyBooksManager sharedInstance].currentReadBook;
    BSCoreDataDelegate *cdd = [BSCoreDataDelegate sharedInstance];
    
    NSPredicate *first = [NSPredicate predicateWithFormat:@"catIndex=%@ and bookID=%@",cid, book.bookName];
    
//    NSLog(@"cid ==========  %@",cid);
    
    NSPredicate *second = [NSPredicate predicateWithFormat:@"position=%@",[NSNumber numberWithInteger:pos]];

    NSArray *subpredicates = [NSArray arrayWithObjects:first, second, nil];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    NSArray *mutableFetchResults;
    mutableFetchResults =[cdd getCoreDataList:@"Bookmark" byContext:managedObjectContext  fetchLimit:1 predicate:predicate];
    if( mutableFetchResults.count > 0){
        return mutableFetchResults[0];
    }
    return nil;
}

- (NSArray *)getbookmarkByPageInfo:(GLCTPageInfo *)pageInfo
{
    MyBook *book = [MyBooksManager sharedInstance].currentReadBook;
    BSCoreDataDelegate *cdd = [BSCoreDataDelegate sharedInstance];
    
    NSPredicate *first = [NSPredicate predicateWithFormat:@"catIndex=%@ and bookID=%@",pageInfo.catIndex, book.bookName];
    NSPredicate *second = [NSPredicate predicateWithFormat:@"position>=%li and position<%li",(long)pageInfo.location,(long)(pageInfo.location+pageInfo.lenght)];
    
    NSArray *subpredicates = [NSArray arrayWithObjects:first, second, nil];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    return [cdd getCoreDataList:@"Bookmark" byPredicate:predicate sort:nil];
}

//书签方法添加
-(void)addBookmarkBySummary:(NSString *)summary catName:(NSString *)cat catIndex:(NSNumber *)cid position:(NSInteger)pos
{
    
    //拿到当先书本对象
    MyBook *book = [MyBooksManager sharedInstance].currentReadBook;
    
    //获取
    Bookmark *alreadyBM = [self getBookmarkByCatIndex:cid position:pos];
    if(alreadyBM != nil){
        return;
    }
    
    Bookmark *bm = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Bookmark"
                        inManagedObjectContext:managedObjectContext];
    
    bm.bookID = book.bookName; //书名
    bm.summary = summary; //摘要
    bm.catName = cat; //章节名称
    bm.catIndex = cid; //章节数目
    bm.position = [NSNumber numberWithInteger:pos];
    
//    NSLog(@"bm.position == %@",bm.position);
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval]; 
    bm.addDate = localeDate;
    
    self.needToSeverMark = bm;
    
//    [bm.managedObjectContext save:nil];
    [managedObjectContext save:nil];
//    NSLog(@"bookmark: %@ /r/n %@",cat, summary);
}

-(void)addBookmarkFromSever:(NSMutableArray *)array
{
    
    for (BookMarkNetModel *model in array) {
        
        Bookmark *bm = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Bookmark"
                        inManagedObjectContext:managedObjectContext];
        
        MyBook *book = [MyBooksManager sharedInstance].currentReadBook;
        
        bm.bookID = book.bookName; //书名
        
        bm.bookmarkid = model.bookmarkid; //摘要
        bm.catName = model.catName; //章节名称
        bm.catIndex = [[NSNumber alloc]initWithInteger:[model.catIndex integerValue]]; //章节数目
        bm.position = [NSNumber numberWithInteger:[model.position integerValue]];
        bm.addDate = model.addDate;
        bm.summary = model.summary;
    }
    
    NSError *error;
    
    if (![managedObjectContext save:&error]) {
        NSLog(@"存储书签失败 %@",error);
    }else{
        NSLog(@"存储成功");
    }
    
}





-(void)bookmarkUpdate:(Bookmark *)model andID:(NSNumber *)markid
{
    self.needToSeverMark.bookmarkid = markid;
    
    [managedObjectContext save:nil];
}



- (void)deleteBookmark:(GLCTPageInfo *)info
{
    BSCoreDataDelegate *cdd = [BSCoreDataDelegate sharedInstance];
    [cdd.parentMOC performBlockAndWait:^{
        NSArray *fetchResults = [self getbookmarkByPageInfo:info];
        for (id item in fetchResults) {
            
            
#pragma mark 删除书签
//            self.needToDeleteMark = (Bookmark *)item;
            
            [[NetworkSynchronizationForBook manager] deleteBookMarkToSever:(Bookmark *)item];
            
            [cdd.parentMOC deleteObject:item];
        }
        [cdd.parentMOC save:nil];
    }];
}

- (NSArray *)getBookmarkList
{
    MyBook *book = [MyBooksManager sharedInstance].currentReadBook;
    BSCoreDataDelegate *cdd = [BSCoreDataDelegate sharedInstance];
    
    __block NSArray *fetchResults;
    [cdd.parentMOC performBlockAndWait:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookID=%@",book.bookName];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"addDate" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        fetchResults =[cdd getCoreDataList:@"Bookmark" byPredicate:predicate sort:sortDescriptors];
    }];

    return fetchResults;
}

-(BOOL)IsBookmarked:(GLCTPageInfo *)info
{
    if(info == nil) return NO;
    
    __block NSArray *fetchResult ;
    [[BSCoreDataDelegate sharedInstance].parentMOC performBlockAndWait:^{
        fetchResult = [self getbookmarkByPageInfo:info];
    }];
    
    if (fetchResult && fetchResult.count > 0)
        return YES;
    else
        return NO;
}







@end
