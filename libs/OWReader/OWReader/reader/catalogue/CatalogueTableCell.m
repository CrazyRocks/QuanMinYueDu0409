//
//  CategoryItemView.m
//  DragonSourceReader
//
//  Created by iMac001 on 11-12-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CatalogueTableCell.h"
#import "BSGlobalAttri.h"
#import "LYBookRenderManager.h"
#import "Catalogue.h"
#import "BSConfig.h"
#import "GLGradientView.h"
#import <POP/POP.h>
//#import "GLNotificationName.h"

#import "JRReaderNotificationName.h"

#import "LYBookSceneManager.h"
#import "LYBookHelper.h"


//顶边距
#define PADDING_TOP 14


@interface CatalogueTableCell()
{
     IBOutlet UILabel *textLB;
    
    UIFont *font;
    CGRect tFrame;
    
    UIStyleObject *style;
}
@end

@implementation CatalogueTableCell

@synthesize delegate;

- (void)awakeFromNib
{
    [self loadSceneMode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSceneMode) name:BOOK_SCENE_CHANGED object:nil];
}

-(void)dealloc
{
    delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)renderContent:(Catalogue *)aCat
{
    cat = aCat;
    if ([BSConfig sharedInstance].isHierarchyStyle) {
        int depth = [aCat.depth intValue];
        if (depth==0) {
            font = [UIFont systemFontOfSize:style.fontSize];
            tFrame = CGRectMake(15, PADDING_TOP, self.frame.size.width - 30, 20);
        }
        else if (depth == 1) {
            font = [UIFont systemFontOfSize:(style.fontSize-2)];
            tFrame = CGRectMake(30, PADDING_TOP, self.frame.size.width - 46, 20);
        }
        else if(depth == 2) {
            font = [UIFont systemFontOfSize:(style.fontSize-2)];
            tFrame = CGRectMake(15, PADDING_TOP, self.frame.size.width - 62, 20);
        }
    }
    else {
        font = [UIFont systemFontOfSize:style.fontSize];
        tFrame = CGRectMake(15, PADDING_TOP, self.frame.size.width - 30, 20);
    }
   
    textLB.numberOfLines = 0;
    [textLB setFont:font];

    [textLB setText: cat.cName];
}

-(void)loadSceneMode
{
    style = [[LYBookSceneManager manager].styleManager getStyle:@"目录列表cell"];

    textLB.textColor = style.fontColor;
    textLB.highlightedTextColor = style.fontColor_selected;
    
    [splitLine drawByStyle:style];

    self.selectedBackgroundView = [[GLGradientView alloc]init];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = self.backgroundColor;
    
}

- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView
{
	return 35.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        textLB.textColor = style.fontColor_selected;
        [delegate tableCellSelected:self];
    }
    else {
        textLB.textColor = style.fontColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (self.highlighted) {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration = 0.1;
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.95, 0.95)];
        [textLB pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    } else {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        scaleAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        scaleAnimation.springBounciness = 20.f;
        [textLB pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    }
}



@end
