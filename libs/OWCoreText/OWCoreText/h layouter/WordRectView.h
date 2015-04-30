//
//  WordRectView.h
//  OWCoreText
//
//  Created by grenlight on 14/10/27.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordRectView : UIView
{
    NSMutableArray *rects;
    NSMutableArray *allRunRect;
    
    NSInteger start;
    NSInteger end;
    
    UIEdgeInsets edgeInsets;
}

-(void)drawRectChooseWordWithStart:(NSInteger)startNumber End:(NSInteger)endNumber;

-(void)setAllRunRect:(NSMutableArray *)array withEdgeInsets:(UIEdgeInsets)edge;

-(void)clearChooseLine;

-(void)drawBookDigest:(NSMutableArray *)array;

@end
