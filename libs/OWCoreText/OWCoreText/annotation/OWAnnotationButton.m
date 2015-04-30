//
//  OWAnnotationButton.m
//  OWCoreText
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.


#import "OWAnnotationButton.h"
#import "OWAnnotationView.h"
#import <OWKit/OWImage.h>
#import <OWKit/OWColor.h> 

@implementation OWAnnotationButton

- (id)initWithFrame:(CGRect)frame content:(NSString *)cnt
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        content = cnt;
       
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"annotation_icon"]];
        imgV.contentMode = UIViewContentModeCenter;
        [imgV setCenter:CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2)];
        [self addSubview:imgV];
        
        tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapped)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withDigestNoteContent:(NSString *)cnt
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        content = cnt;
        
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"digestNote"]];
        imgV.frame = CGRectMake(0, 0, 10, 10);
        [imgV setCenter:CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2)];
        [self addSubview:imgV];
        
        tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapped)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
    }
    return self;
}


- (void)dealloc
{
    tapGesture.delegate = nil;
    [self removeGestureRecognizer:tapGesture];
    tapGesture = nil;
}

-(void)singleTapped
{
    CGPoint p = [self.superview convertPoint:self.center toView:[UIApplication sharedApplication].keyWindow];
    OWAnnotationView *annotationV = [[OWAnnotationView alloc] init];
    annotationV.layouter = self.layouter;
    
    [annotationV setContent:content andAnglePoint:p];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

@end
