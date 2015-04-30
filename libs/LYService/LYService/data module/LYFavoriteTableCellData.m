//
//  FavoriteTableCellData.m
//  PublicLibrary
//
//  Created by 龙源 on 13-11-5.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "LYFavoriteTableCellData.h"

@implementation LYFavoriteTableCellData

- (NSString *)generateHTML
{
    if (!self.title) {
        return nil;
    }
    NSMutableString *html = [[NSMutableString alloc] init];
    
    [html appendFormat:@"<h3 class='fav_title'>%@</h3>", self.title];

    if (self.summary && self.summary.length > 0) {
        NSString *str;
        str = [self.summary stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];

        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        [html appendFormat:@"<p class='fav_summary'>%@</p>", str];
    }
    return html;
}

@end
