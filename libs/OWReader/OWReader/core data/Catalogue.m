//
//  Catelogue.m
//  LYBookStore
//
//  Created by grenlight on 14/7/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "Catalogue.h"
#import <OWKit/OWKit.h> 

@implementation Catalogue

@dynamic bookID;
@dynamic children;
@dynamic cID;
@dynamic cName;
@dynamic depth;
@dynamic filePath;
@dynamic isAlbum;
@dynamic navIndex;
@dynamic pageCounts;
@dynamic startPages;

- (float)cellHeight:(float)width
{
    if (_cellHeight == 0) {
        CGSize titleSize = [self.cName sizeWithFont:[UIFont systemFontOfSize:16] width:width];
        
        _cellHeight = titleSize.height + 14*2;
        if (_cellHeight < 40)
            _cellHeight = 40;
    }
    return _cellHeight;
}

@end
