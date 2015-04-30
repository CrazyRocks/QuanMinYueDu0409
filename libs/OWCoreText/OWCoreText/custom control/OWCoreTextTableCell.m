//
//  OWCoreTextTableCell.m
//  OWUIKit
//
//  Created by  iMac001 on 13-2-1.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import "OWCoreTextTableCell.h"
#import <OWKit/OWTiledView.h>
#import "OWCoreText.h"

@implementation OWCoreTextTableCell

@synthesize cellData, contentViewOffset;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)renderContent
{
    if(!contentView)
    {
        contentView = [[OWTiledView alloc] initWithFrame:CGRectMake(contentViewOffset.x, contentViewOffset.y, CGRectGetWidth(self.bounds)-contentViewOffset.x, CGRectGetHeight(self.bounds))];
        [self insertSubview:contentView atIndex:1];
        
        __unsafe_unretained OWCoreTextTableCell *weakSelf = self;
        [contentView setDrawBlock:^(CGContextRef context) {
            if(!weakSelf) return ;
            CGRect bounds = weakSelf.bounds ;
            CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
            CGContextFillRect(context, bounds);
            
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextTranslateCTM(context, 0, -CGRectGetHeight(bounds));
            
            if(!weakSelf) return ;
            
            NSArray *textLines = weakSelf->cellData.textLines;
            for (OWCoreTextLayoutLine *oneLine  in  textLines)
            {
                CGPoint textPosition = CGPointMake(oneLine.frame.origin.x + 10, bounds.size.height- (oneLine.frame.origin.y + oneLine.ascent + 10));
                CGContextSetTextPosition(context, textPosition.x, textPosition.y);
                [oneLine drawInContext:context];
            }
        }];
    }
    else{
        contentView.layer.contents = nil;
    }
    [contentView drawLayer];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
