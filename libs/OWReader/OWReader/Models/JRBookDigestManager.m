//
//  JRBookDigestManager.m
//  LYBookStore
//
//  Created by grenlight on 14-10-14.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#define SQLLISTNAME @"BookDigest"

#import "JRBookDigestManager.h"
#import "MyBooksManager.h"
#import "MyBook.h"
#import "BookDigestNetModel.h"

@implementation JRBookDigestManager

+(JRBookDigestManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static JRBookDigestManager *instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[JRBookDigestManager alloc] init];
    });
    
    return instance;
}

#pragma mark 添加书摘数据
-(BOOL)saveBookDigestsendRange:(NSRange)range DigestString:(NSString *)digestString PageInfo:(GLCTPageInfo *)pageInfo Catalogue:(NSString *)cat CatIndex:(NSNumber *)cid NumbersArray:(NSMutableArray *)numbersArray Note:(NSString *)note
{
    
    
    BSCoreDataDelegate *bookDelegate = [BSCoreDataDelegate sharedInstance];
    
    NSManagedObjectContext *managedObjectContext = bookDelegate.parentMOC;
    
    BookDigest *digest = [NSEntityDescription insertNewObjectForEntityForName:SQLLISTNAME inManagedObjectContext:managedObjectContext];
    
    MyBook *book = [MyBooksManager sharedInstance].currentReadBook;
    
    digest.range = NSStringFromRange(range);
    digest.bookID = book.bookID;
    digest.summary = digestString;
    digest.pos = [NSNumber numberWithInteger:pageInfo.location];
    digest.catName = cat;
    digest.catIndex = cid;
    digest.lineColor = nil;
    
    if (note != nil && ![note isEqualToString:@""]) {
        digest.digestNote = note;
    }
    
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:numbersArray];
    
    digest.numbers = arrayData;
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    digest.addDate = localeDate;
    
    _currentNeedSaveBookDigest = digest;
    
    NSError *error;
    
    if (![managedObjectContext save:&error]) {
        
        NSLog(@"%@",[error localizedDescription]);
        
        return NO;
    }
    else
    {
        return YES;
    }
    
}

#pragma mark 获取当前阅读图书摘要笔记方法
-(NSMutableArray *)loadThisBookDigestsAndNotes:(MyBook *)book
{
    
    BSCoreDataDelegate *bookDelegate = [BSCoreDataDelegate sharedInstance];
    
    NSManagedObjectContext *managedObjectContext = bookDelegate.parentMOC;

    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entityDes = [NSEntityDescription entityForName:SQLLISTNAME inManagedObjectContext:managedObjectContext];
    [request setEntity:entityDes];
    
    NSArray *digests = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSMutableArray *loadDigests = [[NSMutableArray alloc]init];
    
    for (BookDigest *obj in digests)
    {
        if ([obj.bookID isEqualToString:book.bookID])
        {
            [loadDigests addObject:obj];
        }
    }
    
    _currentBookDigest = loadDigests;
    
    return loadDigests;
}

#pragma mark 删除被覆盖的重复的书摘
- (BOOL)delegateThisBookDigestAndNotes:(BookDigest *)digest
{
    BSCoreDataDelegate *bsdd = [BSCoreDataDelegate sharedInstance];
    [bsdd.parentMOC performBlockAndWait:^{
        [bsdd.parentMOC deleteObject:digest];
        [bsdd.parentMOC save:nil];
    }];
    
    return YES;
}



- (void)updateData:(BookDigest *)model
{
    BSCoreDataDelegate *bookDelegate = [BSCoreDataDelegate sharedInstance];
    
    NSManagedObjectContext *managedObjectContext = bookDelegate.parentMOC;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:SQLLISTNAME inManagedObjectContext:managedObjectContext];
    
    //首先你需要建立一个request
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:entity];
    NSError *error = nil;
    
    NSArray *datas = [managedObjectContext executeFetchRequest:request error:&error];
    
    for (BookDigest *info in datas) {
        if ([info.description isEqualToString: model.description]) {
            info.lineColor = model.lineColor;
            info.noteID = model.noteID;
        }
        
    }
    
    //保存
    if ([managedObjectContext save:&error]) {
        //更新成功
        NSLog(@"更新成功");
    }
}


#pragma mark 同步网络数据使用
-(BOOL)BookDigestModelsToSave:(NSMutableArray *)array
{
    BSCoreDataDelegate *bookDelegate = [BSCoreDataDelegate sharedInstance];
    
    NSManagedObjectContext *managedObjectContext = bookDelegate.parentMOC;
    
    for (BookDigestNetModel *model in array) {
    
        BookDigest *digest = [NSEntityDescription insertNewObjectForEntityForName:SQLLISTNAME inManagedObjectContext:managedObjectContext];
        
        digest.bookID = model.bookID;
        digest.noteID = model.noteID;
        digest.range = model.range;
        digest.addDate = model.addDate;
        digest.catIndex = [[NSNumber alloc]initWithLongLong:[model.catIndex integerValue]];
        digest.catName = model.catName;
        digest.summary = model.summary;
        digest.digestNote = model.digestNote;
        digest.pos = model.pos;
        digest.numbers = model.numbers;
        digest.lineColor = model.lineColor;
        
    }
    
    NSError *error;
    
    if (![managedObjectContext save:&error]) {
        
        return NO;
        
    }else{
        
        return YES;
    }
    
}




@end
