//
//  SubNavigationBar.m
//  GoodSui
//
//  Created by 龙源 on 13-6-18.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "OWSubNavigationBar.h"
#import "PathStyleGestureController.h"
#import "UIStyleManager.h"
#import "OWImage.h"

@implementation OWSubNavigationItem
@end


@implementation OWSubNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];

    }
    return self;
}

- (void)setup
{
    style = [[UIStyleManager sharedInstance] getStyle:@"分类子导航"];
    self.backgroundColor = style.background;
}

- (void)dealloc
{
    _scrollView.delegate = Nil;
}

- (void)createScrollView
{
    if (_scrollView) {
        [_scrollView removeFromSuperview];
        _scrollView.delegate = nil;
        _scrollView = nil;
    }
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.scrollEnabled = YES;
    _scrollView.bounces = YES;
    _scrollView.alwaysBounceHorizontal = NO;
    _scrollView.alwaysBounceVertical  = NO;
    
    CGRect frame = self.bounds;
    frame.size.height -= 1;
    [_scrollView setFrame:frame];
    _scrollView.backgroundColor = self.backgroundColor;
    _scrollView.contentInset = [self.delegate subNavigationBarEdgeInsets];
    
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_scrollView];
}

- (void)renderItems:(NSArray *)array
{
    dataSource = [array copy];
    
    [self createScrollView];
    
    __block float offSetX = 0,
    width = [self.delegate navigationBarItemWidth],
    height = CGRectGetHeight(_scrollView.bounds);
    
    __block int index = 0;

    if (buttons) {
        while (buttons.count > 0) {
            UIButton *bt = buttons.lastObject;
            [bt removeFromSuperview];
            [bt removeTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [buttons removeObject:bt];
        }
        selectedButton = nil;
    }
    buttons = [[NSMutableArray alloc] init];
    
    void(^generateButton)(NSString *) = ^(NSString *title){
        offSetX = width *index;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        [button setFrame:CGRectMake(offSetX, 0, width, height)];
        [_scrollView addSubview:button];
        [button setTitle:title forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTitleColor:style.fontColor forState:UIControlStateNormal];
        [button setTitleColor:style.fontColor_selected forState:UIControlStateSelected];
        [button setBackgroundImage:[OWImage imageWithName:@"subCat_button_selected"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttons addObject:button];
    };
    
    for (OWSubNavigationItem *cat in array) {
        generateButton(cat.catName);
        index ++;
    }
    _scrollView.contentSize = CGSizeMake(width * array.count, height);
    if (selectedCategoryID) {
        for (int i=0; i<dataSource.count; i++) {
            OWSubNavigationItem *cat = dataSource[i];
            if ([cat.catID isEqualToString:selectedCategoryID]) {
                UIButton *button = buttons[i];
                [self buttonTapped:button];
                return;
            }
        }
    }
    if (buttons && buttons.count > 0) {
        UIButton *button = buttons[0];
        [self buttonTapped:button]; 
    }
}

- (void)renderItems:(NSArray *)array selectedIndex:(NSInteger)index
{
    selectedCategoryID = ((OWSubNavigationItem *)array[index]).catID;
    [self renderItems:array];
}

- (void)setSelectedIndex:(NSInteger)index
{
    [selectedButton setSelected:NO];
    UIButton *button = buttons[index];
    [button setSelected:YES];
    selectedButton = button;
    selectedCategoryID = ((OWSubNavigationItem *)dataSource[button.tag]).catID;

    [self changeOffsetByCurrentItem:button];
}

- (void)autoTapByIndex:(NSInteger)index
{
    [self setSelectedIndex:index];
    
    if (self.delegate) {
        [self.delegate navigationBarSelectedItem:selectedCategoryID itemIndex:index];
    }
}

- (void)buttonTapped:(UIButton *)sender
{
    self.userInteractionEnabled = NO;
    [self autoTapByIndex:sender.tag];
    
    [self performSelector:@selector(interactionEnabled) withObject:nil afterDelay:1.0];
}

- (void)interactionEnabled
{
    self.userInteractionEnabled = YES;
}

- (void)changeOffsetByCurrentItem:(UIButton *)sender
{
    if (!sender) return;
    
    CGRect frame = self.bounds;
    frame.size.width -=  _scrollView.contentInset.right;
    
    float centerX = CGRectGetMidX(frame);

    float maxOffsetX = _scrollView.contentSize.width - (CGRectGetWidth(frame));
    if (maxOffsetX < 0) {
        maxOffsetX = 0;
    }
    
    if (sender.center.x < centerX) {
        [_scrollView setContentOffset:CGPointZero animated:YES];
    }
    else {
        float distanceX = sender.center.x - centerX;
        CGRect vFrame = frame;
        
        if (distanceX < maxOffsetX) {
            vFrame.origin.x = distanceX;
        }
        else {
            vFrame.origin.x = maxOffsetX;
        }
        [_scrollView setContentOffset:vFrame.origin animated:YES];
    }
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, style.hLineWidth);
    CGContextSetStrokeColorWithColor(context, style.hLineColor.CGColor);
    CGContextMoveToPoint(context, 0, CGRectGetHeight(self.bounds) - style.hLineWidth/2.0f);
    CGContextAddLineToPoint(context, rect.size.width,  CGRectGetHeight(self.bounds)- style.hLineWidth/2.0f);
    CGContextDrawPath(context, kCGPathStroke );
}

#pragma mark scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[PathStyleGestureController sharedInstance] cancelAnyGestureRecognize];
}

@end
