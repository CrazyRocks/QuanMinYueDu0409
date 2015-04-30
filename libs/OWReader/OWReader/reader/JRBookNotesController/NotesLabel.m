//
//  NotesLabel.m
//  OWReader
//
//  Created by grenlight on 15/1/23.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import "NotesLabel.h"

@implementation NotesLabel


- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect tf = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    return CGRectInset(tf, 15, 10);
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect: CGRectInset(self.bounds, 15, 10)];
}

@end
