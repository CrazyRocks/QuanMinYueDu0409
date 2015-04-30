//
//  ModelTransformationTool.m
//  LYBookStore
//
//  Created by grenlight on 14-10-15.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "ModelTransformationTool.h"

@implementation ModelTransformationTool

+(JRDigestModel *)coreDataTransformationUseModel:(BookDigest *)bookDigest
{
    JRDigestModel *model = [[JRDigestModel alloc]init];
    
    if (bookDigest) {
        
        model.range = bookDigest.range;
        model.addDate = bookDigest.addDate;
        model.bookID = bookDigest.bookID;
        model.catIndex = bookDigest.catIndex;
        model.catName = bookDigest.catName;
        model.summary = bookDigest.summary;
        model.lineColor = bookDigest.lineColor;
        
        if (bookDigest.noteID) {
            model.noteID = bookDigest.noteID;
        }
//        NSLog(@"model.lineColor ====== %@",model.lineColor);
        
        
        if (bookDigest.digestNote) {
            model.digestNote = bookDigest.digestNote;
        }
        model.pos = bookDigest.pos;
        
        NSArray *newArray = [NSKeyedUnarchiver unarchiveObjectWithData:bookDigest.numbers];
        
        model.numbers = newArray;
    }
    
    return model;
}


+(BookDigestNetModel *)changeInfoToBookDigestNetModel:(NSDictionary *)info
{
    BookDigestNetModel *model = [[BookDigestNetModel alloc]init];
    
    if ([info objectForKey:@"adddate"]) {
        
        NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateformatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
        [dateformatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString * str = [NSString stringWithFormat:@"%@:00",[info objectForKey:@"adddate"]];
        NSDate * enddate = [dateformatter dateFromString:str];
        
        model.addDate = enddate;
    }
    
    if ([info objectForKey:@"catindex"]) {
        model.catIndex = [info objectForKey:@"catindex"];
    }
    
    if ([info objectForKey:@"catname"]) {
        model.catName = [info objectForKey:@"catname"];
    }
    
    if ([info objectForKey:@"digestnote"] && ![[info objectForKey:@"digestnote"] isEqualToString:@""]) {
        model.digestNote = [info objectForKey:@"digestnote"];
    }
    
    if ([info objectForKey:@"id"]) {
        model.noteID = [info objectForKey:@"id"];
    }
    
    if ([info objectForKey:@"line_color"] && ![[info objectForKey:@"line_color"] isEqualToString:@""]) {
        model.lineColor = [info objectForKey:@"line_color"];
    }
    
    if ([info objectForKey:@"numbers"]) {
        
        NSString *numberString = [info objectForKey:@"numbers"];
        
        NSArray *arr = [numberString componentsSeparatedByString:@","];
        
        NSMutableArray *numbers = [[NSMutableArray alloc]init];
        
        NSString *first = [arr firstObject];
        
        NSString *last = [arr lastObject];
        
        long long k = [first longLongValue];
        long long j = [last longLongValue];
        
        
        for (long long i = k; i < j; i++) {
            [numbers addObject:[NSNumber numberWithLongLong:i]];
        }
        
        NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:numbers];
        
        model.numbers =  arrayData;
    }
    
    if ([info objectForKey:@"ranges"]) {
        model.range = [info objectForKey:@"ranges"];
    }
    
    if ([info objectForKey:@"summary"]) {
        model.summary = [info objectForKey:@"summary"];
    }
    
    model.bookID = [MyBooksManager sharedInstance].currentReadBook.bookID;
    
    return model;
}

+(BookMarkNetModel *)changeInfoToBookMarkNetModel:(NSDictionary *)info
{
    BookMarkNetModel *model = [[BookMarkNetModel alloc]init];
    
    if ([info objectForKey:@"adddate"]) {
        
        NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateformatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
        [dateformatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString * str = [NSString stringWithFormat:@"%@:00",[info objectForKey:@"adddate"]];
        NSDate * enddate = [dateformatter dateFromString:str];
        
        model.addDate = enddate;
        
    }
    
    if ([info objectForKey:@"bookid"]) {
        
        model.bookID = [MyBooksManager sharedInstance].currentReadBook.bookID;
        
    }
    
    if ([info objectForKey:@"catindex"]) {
        model.catIndex = [info objectForKey:@"catindex"];
    }
    
    if ([info objectForKey:@"catname"]) {
        model.catName = [info objectForKey:@"catname"];
    }
    
    if ([info objectForKey:@"id"]) {
        model.bookmarkid = [info objectForKey:@"id"];
    }
    
    if ([info objectForKey:@"positions"]) {
        model.position = [info objectForKey:@"positions"];
    }
    
    if ([info objectForKey:@"summary"]) {
        model.summary = [info objectForKey:@"summary"];
    }
    
    return model;
}

@end
