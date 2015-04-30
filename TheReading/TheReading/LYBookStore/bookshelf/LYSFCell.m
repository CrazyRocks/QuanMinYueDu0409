//
//  LYSFCell.m
//  LYBookStore
//
//  Created by grenlight on 14/6/18.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYSFCell.h"
#import <OWKit/OWKit.h>
#import <POP/POP.h>
#import "LYBookSceneManager.h"

@implementation LYSFCell

- (void)awakeFromNib
{
//    selectedIcon.hidden = YES;
    UIView *selectedBG = [[UIView alloc] init];
    selectedBG.backgroundColor = [OWColor colorWithHex:0xf9f9f9];
    self.selectedBackgroundView = selectedBG;
    
    selectedIcon.image = [UIImage imageNamed:@"listselected"];
}

- (void)setInfo:(NSString *)title
{
    titleLabel.text = title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        //selectedIcon.hidden = NO;
        [self showIcon];
       
    }
    else {
       // selectedIcon.hidden = YES;
        [self hideIcon];
    }
    
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (self.highlighted) {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration = 0.1;
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.95, 0.95)];
        [titleLabel pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        [self showIcon];
    }
    else {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        scaleAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        scaleAnimation.springBounciness = 20.f;
        [titleLabel pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        if (!self.selected)
            [self hideIcon];
    }
}

- (void)showIcon
{
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    scaleAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
    scaleAnimation.springBounciness = 20.f;
    [selectedIcon pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

- (void)hideIcon
{
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleAnimation.duration = 0.1;
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    [selectedIcon pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

@end
